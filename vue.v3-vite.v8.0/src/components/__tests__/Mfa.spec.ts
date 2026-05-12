import { mount, flushPromises } from '@vue/test-utils';
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import Mfa from '../Mfa.vue'; // Adjust path
import axios from 'axios';

const { mockPatch } = vi.hoisted(() => {
  return {
    mockPatch: vi.fn(),
  };
});

vi.mock('axios', () => {
  return {
    default: {
      create: vi.fn(() => ({
        patch: mockPatch, 
      })),
    },
  };
});

vi.mock('jquery', () => {
    return {
        default: vi.fn(() => ({
            trigger: vi.fn(),
        })),
    };
});

const mockedAxios = vi.mocked(axios, true);
(mockedAxios.create as any).mockReturnValue({ patch: mockPatch });

describe('Mfa.vue', () => {
  let wrapper: any;

  beforeEach(() => {
    sessionStorage.clear();
    vi.clearAllMocks();
    
    mockPatch.mockResolvedValue({
      data: { message: 'Success', username: 'testuser' },
    });

    wrapper = mount(Mfa);
  });

  afterEach(() => {
    wrapper.unmount();
  });

  it('renders the MFA form', () => {
    expect(wrapper.find('#staticMfa').exists()).toBe(true);
    expect(wrapper.find('input[type="text"]').exists()).toBe(true);
  });

  it('submits OTP and handles success', async () => {
    sessionStorage.setItem('USERID', '123');
    sessionStorage.setItem('TOKEN', 'fake-token');

    mockPatch.mockResolvedValueOnce({
      data: { message: 'Success', username: 'testuser' },
    });

    await wrapper.find('input').setValue('123456');
    await wrapper.find('form').trigger('submit.prevent');
    await flushPromises();

    expect(mockPatch).toHaveBeenCalledWith(
      'api/mfa/verifytotp/123',
      JSON.stringify({ otp: '123456' }),
      expect.any(Object)
    );
    expect(wrapper.vm.OtpMessage).toBe('Success');
    expect(sessionStorage.getItem('USERNAME')).toBe('testuser');
  });

  it('handles API error', async () => {
    mockPatch.mockRejectedValueOnce({
      response: { data: { message: 'Invalid OTP' } },
    });

    await wrapper.find('input').setValue('000000');
    await wrapper.find('form').trigger('submit.prevent');
    await flushPromises();

    expect(wrapper.vm.OtpMessage).toBe('Invalid OTP');
  });

  it('calls closeMfa and clears session', async () => {
    sessionStorage.setItem('USERID', '123');
    await wrapper.find('.btn-close').trigger('click');
    expect(sessionStorage.getItem('USERID')).toBeNull();
    expect(window.location.reload);
  });
});
