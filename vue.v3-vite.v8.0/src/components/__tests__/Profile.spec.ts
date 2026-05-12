import { shallowMount, mount, flushPromises } from '@vue/test-utils';
import { describe, it, expect, vi, beforeEach, beforeAll } from 'vitest';
import Profile from '../../pages/Profile.vue';


const { mockGet, mockPatch } = vi.hoisted(() => {
    return { 
        mockGet: vi.fn(),
        mockPatch: vi.fn() 
    };
});

vi.mock('axios', () => {
    return {
        default: {
            create: vi.fn(() => ({
                get: mockGet,
                patch: mockPatch,
                interceptors: {
                    request: { use: vi.fn(), eject: vi.fn() },
                    response: { use: vi.fn(), eject: vi.fn() },
                },
            })),
        },
    };
});

if (typeof global.URL.createObjectURL === 'undefined') {
    global.URL.createObjectURL = vi.fn(() => 'mock-url');
}
  
if (typeof global.URL.revokeObjectURL === 'undefined') {
    global.URL.revokeObjectURL = vi.fn();
}


describe('Profile.vue', () => {
    let wrapper: any;
    let setItemSpy: any;

    beforeEach(() => {
        vi.clearAllMocks();
        sessionStorage.clear();

        // setItemSpy = vi.spyOn(sessionStorage, 'setItem');
        setItemSpy = vi.spyOn(window.sessionStorage.__proto__, 'setItem');

        sessionStorage.setItem('USERID', '123');
        sessionStorage.setItem('TOKEN', 'eyJhbGciOiJIUzI1NiJ9...');

        mockGet.mockResolvedValue({
            data: {
                message: 'Profile loaded',
                firstname: 'John',
                lastname: 'Doe',
                email_address: 'john@example.com',
            },            
        });

        Object.defineProperty(window, 'location', {
            value: { reload: vi.fn() },
            writable: true
        });        

        mockPatch.mockResolvedValue({ data: {} });        

        wrapper = shallowMount(Profile, {
            global: {
                stubs: ['Footer'],
            },
        });
        
    });

    it('fetches profile data on mount and populates fields', async () => {
        const wrapper = mount(Profile);
        await flushPromises();

        expect(mockGet).toHaveBeenCalledWith(
            'api/getuserid/123',
            expect.objectContaining({
                headers: { 
                    Authorization: 'Bearer eyJhbGciOiJIUzI1NiJ9...'
                },
            })
        );

        const firstNameInput = wrapper.find<HTMLInputElement>('#firstname');
        expect(firstNameInput.element.value).toBe('John');

        expect(wrapper.text()).toContain('Profile loaded');
    });




    // 2nd TEST


    it('submits profile data and updates profileMsg on success', async () => {
        // Now mockPatch is defined
        mockPatch.mockResolvedValueOnce({
            data: { message: 'Profile updated successfully' },
        });

        wrapper.vm.firstname = 'John';
        wrapper.vm.lastname = 'Doe';
        wrapper.vm.mobile = '1234567890';

        await wrapper.vm.submitProfile();

        expect(mockPatch).toHaveBeenCalledWith(
            '/api/updateprofile/123',
            expect.anything(), 
            expect.objectContaining({
                headers: { Authorization: 'Bearer eyJhbGciOiJIUzI1NiJ9...' },
            })
        );

        await flushPromises();
        expect(wrapper.vm.profileMsg).toBe('Profile updated successfully');
    });

    it('updates profileMsg on API error', async () => {
        mockPatch.mockRejectedValueOnce({
            response: {
                data: { message: 'Update failed' },
            },
        });

        await wrapper.vm.submitProfile();

        await flushPromises();
        expect(wrapper.vm.profileMsg).toBe('Update failed');
    });        


    // 3rd TEST


    it('shows error if new password is empty', async () => {
        wrapper.setData({ password: '', confpassword: '' });
        await wrapper.vm.changePassword();
        expect(wrapper.vm.profileMsg).toBe('Please enter New Password.');
    });

    it('shows error if passwords do not match', async () => {
        wrapper.setData({ password: 'new', confpassword: 'wrong' });
        await wrapper.vm.changePassword();
        expect(wrapper.vm.profileMsg).toBe('New Password does not matched.');
    });

    it('calls API and shows success message', async () => {
        wrapper.setData({ password: 'new', confpassword: 'new' });
        
        mockPatch.mockResolvedValueOnce({ data: { message: 'Password Updated' } });
    
        await wrapper.vm.changePassword();
        await flushPromises();
    
        expect(mockPatch).toHaveBeenCalledWith(
            'api/changepassword/123',
            JSON.stringify({ password: 'new' }),
            expect.objectContaining({
                headers: { 
                    Authorization: 'Bearer eyJhbGciOiJIUzI1NiJ9...' 
                }
            })
        );
        expect(wrapper.vm.profileMsg).toBe('Password Updated');
    });
    

    it('handles API error', async () => {
        wrapper.setData({ password: 'new', confpassword: 'new' });
        
        mockPatch.mockRejectedValueOnce({
            response: { data: { message: 'Old password invalid' } }
        });

        await wrapper.vm.changePassword();
        await flushPromises();

        expect(wrapper.vm.profileMsg).toBe('Old password invalid');
    });


    // 4th TEST

    it('successfully uploads a picture and handles response', async () => {

        const mockResponse = { data: { message: 'Success', userpic: 'new.jpg' } };
        mockPatch.mockResolvedValueOnce(mockResponse);
        setItemSpy.mockClear(); 

        const file = new File([''], 'test.png', { type: 'image/png' });
        const event = {
            preventDefault: vi.fn(),
            target: { files: [file] }
        };
    
        await wrapper.vm.changePicture(event);
        await flushPromises();
    
        expect(mockPatch).toHaveBeenCalled();
        expect(wrapper.vm.profileMsg).toBe('Success');
        
    });

    it('handles upload errors', async () => {
        mockPatch.mockRejectedValueOnce({
            response: { data: { message: 'Upload Failed' } }
        });

        const file = new File([''], 'test.png', { type: 'image/png' });
        const event = {
            preventDefault: vi.fn(),
            target: { files: [file] }
        };

        await wrapper.vm.changePicture(event);

        expect(wrapper.vm.profileMsg).toBe('Upload Failed');
    });    

});
