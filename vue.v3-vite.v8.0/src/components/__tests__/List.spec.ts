import { mount, flushPromises } from '@vue/test-utils';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import ProductList from '../../pages/List.vue';

const mockAxiosInstance = {
  get: vi.fn(),
};

vi.mock('axios', () => {
  return {
    default: {
      create: vi.fn(() => mockAxiosInstance),
    },
  };
});

describe('ProductList.vue', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  const mockProducts = [
    { id: 1, descriptions: 'Item 1', qty: 10, unit: 'pcs', sellprice: 100 },
    { id: 2, descriptions: 'Item 2', qty: 5, unit: 'kg', sellprice: 250.5 },
  ];

  it('renders table and loads products on mount', async () => {
    mockAxiosInstance.get.mockResolvedValueOnce({
      data: {
        products: mockProducts,
        totalrecords: 2,
        page: 1,
        totpage: 1,
      },
    });

    const wrapper = mount(ProductList);
    
    await flushPromises();

    expect(mockAxiosInstance.get).toHaveBeenCalledWith('api/products/list/1');
    expect(wrapper.find('h1').text()).toBe('Product List');
    expect(wrapper.findAll('tbody tr')).toHaveLength(2);
  });

  it('handles empty product list with message', async () => {
    mockAxiosInstance.get.mockResolvedValueOnce({
      data: { products: [], totalrecords: 0, page: 1, totpage: 0 },
    });

    const wrapper = mount(ProductList);
    await flushPromises();

    expect(wrapper.find('.text-danger').text()).toBe('');
  });

  it('navigates to next page', async () => {
    mockAxiosInstance.get.mockResolvedValueOnce({
      data: { products: [mockProducts[0]], totalrecords: 2, page: 1, totpage: 2 },
    });

    const wrapper = mount(ProductList);
    await flushPromises();

    mockAxiosInstance.get.mockResolvedValueOnce({
      data: { products: [mockProducts[1]], totalrecords: 2, page: 2, totpage: 2 },
    });


    const links = wrapper.findAll('.page-link');
    await links[2]?.trigger('click');    

    await flushPromises();

    expect(mockAxiosInstance.get).toHaveBeenCalledWith('api/products/list/2');
    expect(wrapper.find('tbody tr td:nth-child(2)').text()).toBe('Item 2');
  });

  it('handles API error', async () => {
    mockAxiosInstance.get.mockRejectedValueOnce({
      response: { data: { message: 'Error loading products' } },
    });

    const wrapper = mount(ProductList);
    await flushPromises();

    expect(wrapper.find('.text-danger').text()).toBe('Error loading products');
  });
});
