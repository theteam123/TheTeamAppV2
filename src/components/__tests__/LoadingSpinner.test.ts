import { describe, it, expect } from 'vitest';
import { mount } from '@vue/test-utils';
import LoadingSpinner from '../LoadingSpinner.vue';

describe('LoadingSpinner', () => {
  it('renders with default props', () => {
    const wrapper = mount(LoadingSpinner);
    
    expect(wrapper.find('.animate-spin').exists()).toBe(true);
    expect(wrapper.find('.border-indigo-500').exists()).toBe(true);
    expect(wrapper.find('span').exists()).toBe(false);
  });

  it('renders with text', () => {
    const wrapper = mount(LoadingSpinner, {
      props: {
        text: 'Loading...'
      }
    });

    expect(wrapper.find('span').exists()).toBe(true);
    expect(wrapper.text()).toContain('Loading...');
  });

  it('applies full height class when fullHeight is true', () => {
    const wrapper = mount(LoadingSpinner, {
      props: {
        fullHeight: true
      }
    });

    expect(wrapper.find('.min-h-\\[200px\\]').exists()).toBe(true);
  });

  it('applies correct color class for each variant', () => {
    const variants = ['primary', 'secondary', 'success', 'danger'] as const;
    const colorClasses = {
      primary: 'border-indigo-500',
      secondary: 'border-gray-500',
      success: 'border-green-500',
      danger: 'border-red-500'
    };

    variants.forEach(variant => {
      const wrapper = mount(LoadingSpinner, {
        props: { variant }
      });
      expect(wrapper.find(`.${colorClasses[variant]}`).exists()).toBe(true);
    });
  });
}); 