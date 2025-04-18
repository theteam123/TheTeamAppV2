import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useDebounce } from '../useDebounce';

describe('useDebounce', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  it('initializes with the given value', () => {
    const { value } = useDebounce('initial');
    expect(value.value).toBe('initial');
  });

  it('updates value after delay', () => {
    const { value } = useDebounce('initial', 1000);
    
    value.value = 'updated';
    expect(value.value).toBe('initial'); // Should not update immediately
    
    vi.advanceTimersByTime(1000);
    expect(value.value).toBe('updated');
  });

  it('cancels pending update', () => {
    const { value, cancel } = useDebounce('initial', 1000);
    
    value.value = 'updated';
    cancel();
    
    vi.advanceTimersByTime(1000);
    expect(value.value).toBe('initial');
  });

  it('handles multiple rapid updates', () => {
    const { value } = useDebounce('initial', 1000);
    
    value.value = 'first';
    value.value = 'second';
    value.value = 'third';
    
    expect(value.value).toBe('initial');
    
    vi.advanceTimersByTime(1000);
    expect(value.value).toBe('third');
  });

  afterEach(() => {
    vi.useRealTimers();
  });
}); 