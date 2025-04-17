import { describe, it, expect } from 'vitest';
import { mount } from '@vue/test-utils';
import TeamLogo from './TeamLogo.vue';
import { createRouter, createWebHistory } from 'vue-router';

const router = createRouter({
  history: createWebHistory(),
  routes: [{ path: '/', component: {} }]
});

describe('TeamLogo', () => {
  it('renders with default props', () => {
    const wrapper = mount(TeamLogo, {
      global: {
        plugins: [router]
      }
    });
    
    expect(wrapper.find('img').exists()).toBe(true);
    expect(wrapper.find('img').attributes('src')).toBe('/TeamLogo.png');
    expect(wrapper.find('img').attributes('alt')).toBe('Team Logo');
    expect(wrapper.find('img').attributes('style')).toContain('height: 32px');
  });

  it('shows fallback text when image fails to load', async () => {
    const wrapper = mount(TeamLogo, {
      global: {
        plugins: [router]
      }
    });
    
    await wrapper.find('img').trigger('error');
    expect(wrapper.find('span').text()).toBe('TheTeam');
  });

  it('accepts custom props', () => {
    const wrapper = mount(TeamLogo, {
      props: {
        height: 48,
        src: '/custom-logo.png',
        alt: 'Custom Logo',
        link: '/dashboard',
        fallbackText: 'Custom Text'
      },
      global: {
        plugins: [router]
      }
    });
    
    expect(wrapper.find('img').attributes('src')).toBe('/custom-logo.png');
    expect(wrapper.find('img').attributes('alt')).toBe('Custom Logo');
    expect(wrapper.find('img').attributes('style')).toContain('height: 48px');
    expect(wrapper.find('a').attributes('href')).toBe('/dashboard');
  });
});