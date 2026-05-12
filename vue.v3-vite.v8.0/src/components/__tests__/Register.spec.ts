import { mount } from '@vue/test-utils';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import Register from '../Register.vue';

const { mockPost } = vi.hoisted(() => {
    return { mockPost: vi.fn() };
  });
  
  vi.mock('axios', () => {
    return {
      default: {
        create: vi.fn(() => ({
          post: mockPost,
        })),
      },
    };
  });
  
vi.mock('jquery', () => {
    const mockJquery = vi.fn(() => ({
        trigger: vi.fn(),
        modal: vi.fn(),
    }));
    return { default: mockJquery };
});

describe('Register.vue', () => {
  let wrapper: any;

  beforeEach(() => {
    vi.clearAllMocks();
    wrapper = mount(Register);
  });

  it('renders form elements', () => {
    expect(wrapper.find('input[placeholder="enter First Name"]').exists()).toBe(true);
    expect(wrapper.find('button[type="submit"]').text()).toBe('register');
  });

  it('updates v-model data on input', async () => {
    const emailInput = wrapper.find('input[type="email"]');
    await emailInput.setValue('test@example.com');
    expect(wrapper.vm.email).toBe('test@example.com');
  });

  it('submits form data via axios', async () => {
    mockPost.mockResolvedValueOnce({ data: { message: 'Success' } });

    await wrapper.find('input[placeholder="enter First Name"]').setValue('John');
    await wrapper.find('input[placeholder="enter Last Name"]').setValue('Doe');
    await wrapper.find('input[type="email"]').setValue('john@example.com');
    await wrapper.find('input[placeholder="enter Mobile No."]').setValue('123456');
    await wrapper.find('input[placeholder="enter User Name"]').setValue('johnd');
    await wrapper.find('input[placeholder="enter Password"]').setValue('password');
    await wrapper.find('form').trigger('submit.prevent');

    expect(mockPost).toHaveBeenCalledWith(
        'api/signup', 
        expect.stringContaining('"email_address":"john@example.com"')
      );      
  });

  it('displays success message on successful registration', async () => {
    mockPost.mockResolvedValueOnce({ data: { message: 'Registration Successful' } });

    await wrapper.find('form').trigger('submit.prevent');
    
    await new Promise(process.nextTick);
    
    expect(wrapper.vm.registerMsg).toBe('Registration Successful');
    expect(wrapper.find('.text-danger').text()).toBe('Registration Successful');
  });

  it('displays error message on failed registration', async () => {
    const errorResponse = { response: { data: { message: 'Email taken' } } };
    mockPost.mockRejectedValueOnce(errorResponse);

    await wrapper.find('form').trigger('submit.prevent');
    
    await new Promise(process.nextTick);
    
    expect(wrapper.vm.registerMsg).toBe('Email taken');
  });

  it('resets form when close button is clicked', async () => {
    // Fill data
    await wrapper.find('input[type="email"]').setValue('test@example.com');
    
    // Click close
    await wrapper.find('.btn-close').trigger('click');

    // Assert data cleared
    expect(wrapper.vm.email).toBe('');
    expect(wrapper.vm.registerMsg).toBe('');
  });
});
