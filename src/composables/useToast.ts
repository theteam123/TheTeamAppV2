import { ref } from 'vue';

type ToastType = 'success' | 'error' | 'info' | 'warning';

interface ToastOptions {
  type?: ToastType;
  duration?: number;
}

export function useToast() {
  const message = ref('');
  const type = ref<ToastType>('info');
  const show = ref(false);

  function showToast(msg: string, options: ToastOptions = {}) {
    message.value = msg;
    type.value = options.type || 'info';
    show.value = true;

    setTimeout(() => {
      show.value = false;
    }, options.duration || 3000);
  }

  return {
    message,
    type,
    show,
    showToast
  };
} 