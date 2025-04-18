import { describe, it, expect, vi } from 'vitest';
import { mount } from '@vue/test-utils';
import ErrorBoundary from '../ErrorBoundary.vue';

describe('ErrorBoundary', () => {
  it('renders slot content when there is no error', () => {
    const wrapper = mount(ErrorBoundary, {
      slots: {
        default: '<div>Test Content</div>'
      }
    });

    expect(wrapper.text()).toContain('Test Content');
    expect(wrapper.find('.bg-red-50').exists()).toBe(false);
  });

  it('renders error message when there is an error', async () => {
    const wrapper = mount(ErrorBoundary, {
      slots: {
        default: '<div>Test Content</div>'
      }
    });

    // Simulate an error
    const error = new Error('Test error');
    await wrapper.vm.$options.onErrorCaptured.call(wrapper.vm, error);

    expect(wrapper.text()).toContain('Something went wrong');
    expect(wrapper.text()).toContain('Test error');
    expect(wrapper.find('.bg-red-50').exists()).toBe(true);
  });

  it('resets error when try again button is clicked', async () => {
    const wrapper = mount(ErrorBoundary, {
      slots: {
        default: '<div>Test Content</div>'
      }
    });

    // Simulate an error
    const error = new Error('Test error');
    await wrapper.vm.$options.onErrorCaptured.call(wrapper.vm, error);

    // Click try again button
    await wrapper.find('button').trigger('click');

    expect(wrapper.text()).toContain('Test Content');
    expect(wrapper.find('.bg-red-50').exists()).toBe(false);
  });
}); 