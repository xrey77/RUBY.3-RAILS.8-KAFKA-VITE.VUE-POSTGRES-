import { mount } from '@vue/test-utils';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import ProductCatalogs from '../../pages/Catalogs.vue';
import axios from 'axios';
import { flushPromises } from '@vue/test-utils';

vi.mock('axios', () => {
  return {
    default: {
      create: vi.fn(() => ({
        get: vi.fn(),
      })),
    },
  };
});

describe('ProductCatalogs.vue', () => {
  let mockGet: any;

  beforeEach(() => {
    vi.clearAllMocks();
    mockGet = vi.fn();
    (axios.create as any).mockReturnValue({
      get: mockGet,
    });
  });

  it('shows empty message when totpage is 0', async () => {
    mockGet.mockResolvedValueOnce({
      data: { products: [], page: 1, totpage: 0, totalrecords: 0 },
    });

    const wrapper = mount(ProductCatalogs);
    
    await new Promise(process.nextTick); 
    await wrapper.vm.$nextTick();

    expect(wrapper.text()).toContain('Products is empty....');
  });

  it('renders products and pagination correctly', async () => {
    const mockProducts = [
      { id: 1, productpicture: 'p1.jpg', descriptions: 'Test Product 1', sellprice: 100 },
      { id: 2, productpicture: 'p2.jpg', descriptions: 'Test Product 2', sellprice: 200 },
    ];

    mockGet.mockResolvedValueOnce({
      data: { products: mockProducts, page: 1, totpage: 2, totalrecords: 4 },
    });

          
    const wrapper = mount(ProductCatalogs);
    await flushPromises();    
    await wrapper.vm.$nextTick();

    const cards = wrapper.findAll('.card');
    expect(cards.length).toBe(2);
    expect(wrapper.text()).toContain('Test Product 1');
    expect(wrapper.text()).toContain('₱100.00');

    expect(wrapper.text()).toMatch(/Page\s+1\s+of\s+2/);    
  });

  it('navigates to next page', async () => {
    mockGet.mockResolvedValueOnce({
      data: { products: [], page: 1, totpage: 2, totalrecords: 4 },
    });

    const wrapper = mount(ProductCatalogs);
    await new Promise(process.nextTick);
    await wrapper.vm.$nextTick();

    mockGet.mockResolvedValueOnce({
      data: { products: [], page: 2, totpage: 2, totalrecords: 4 },
    });

    const links = wrapper.findAll('.page-link');
    await links[2]?.trigger('click');    

    await new Promise(process.nextTick);
    await wrapper.vm.$nextTick();

    expect(mockGet).toHaveBeenCalledWith('api/products/list/2');
    expect(wrapper.text()).toMatch(/Page\s+2\s+of\s+2/);    
  });

  it('handles API error', async () => {
    mockGet.mockRejectedValueOnce(new Error('Network Error'));

    const wrapper = mount(ProductCatalogs);
    await flushPromises();
    await wrapper.vm.$nextTick();
  
    expect(wrapper.text()).toContain('Network Error');    
  });

});
