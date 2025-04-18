import { ref, watch } from 'vue';

/**
 * Creates a debounced ref that updates after a specified delay
 * @param value - The initial value
 * @param delay - The delay in milliseconds (default: 300ms)
 * @returns A debounced ref and its update function
 */
export function useDebounce<T>(value: T, delay = 300) {
  const debouncedValue = ref<T>(value);
  let timeoutId: number | null = null;

  watch(
    () => value,
    (newValue) => {
      if (timeoutId) {
        clearTimeout(timeoutId);
      }

      timeoutId = window.setTimeout(() => {
        debouncedValue.value = newValue;
      }, delay);
    },
    { immediate: true }
  );

  return {
    value: debouncedValue,
    cancel: () => {
      if (timeoutId) {
        clearTimeout(timeoutId);
        timeoutId = null;
      }
    }
  };
} 