import { mount } from '@vue/test-utils';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import Login from '../Login.vue';
import axios from 'axios';

vi.mock('axios', () => {
    const mockAxiosInstance = {
      post: vi.fn(),
    };
    return {
      default: {
        create: vi.fn(() => mockAxiosInstance),
      },
    };
  });

vi.mock('jquery', () => {
    return {
        default: vi.fn(() => ({
            trigger: vi.fn(),
            hide: vi.fn()
        }))
    };
});

describe('Login.vue', () => {
    let mockPost: any;
    let wrapper: any;

    beforeEach(() => {
        vi.clearAllMocks();        
        mockPost = vi.mocked(axios.create()).post;        
        wrapper = mount(Login);
    });
    

    const sessionStorageMock = (() => {
        let store = {} as Record<string, string>;
        return {
          getItem: vi.fn((key: string) => store[key] || null),
          setItem: vi.fn((key: string, value: string) => {
            store[key] = value?.toString() || ''; 
          }),
          clear: vi.fn(() => {
            store = {};
          }),
          removeItem: vi.fn((key: string) => {
            delete store[key];
          }),
        };
    })();
      
    Object.defineProperty(window, 'sessionStorage', {
        value: sessionStorageMock,
        configurable: true,
        writable: true,
    });
      
    beforeEach(() => {
        vi.clearAllMocks();
        sessionStorageMock.clear();
        
        mockPost = vi.mocked(axios.create()).post;
        wrapper = mount(Login);
    });


    it('renders signin title and inputs', () => {
        expect(wrapper.find('h1').text()).toBe("User's SignIn");
        expect(wrapper.find('#uname').exists()).toBe(true);
        expect(wrapper.find('#pword').exists()).toBe(true);
    });

    it('submits login data and handles success', async () => {
        mockPost.mockResolvedValueOnce({
            data: { 
                token: 'token123',
                userpic: 'pic.jpg'
            }
        });
        
        await wrapper.find('#uname').setValue('testuser');
        await wrapper.find('#pword').setValue('password');        
        await wrapper.find('form').trigger('submit.prevent');
        
        expect(mockPost).toHaveBeenCalledWith("api/signin", '{"username":"testuser","password":"password"}');
        expect(sessionStorageMock.setItem).toHaveBeenCalledWith('TOKEN', 'token123');
    });

    it('handles login error', async () => {
        mockPost.mockRejectedValueOnce({
            response: { data: { message: 'Invalid Credentials' } }
        });
    
        await wrapper.find('#uname').setValue('wrong');
        await wrapper.find('#pword').setValue('wrong');        
        await wrapper.find('form').trigger('submit.prevent');
        
        await vi.waitFor(() => {
            expect(wrapper.vm.message).toBe('Invalid Credentials');
        });        
    });
});
