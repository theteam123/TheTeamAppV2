import { ref } from 'vue';

export type NotificationType = 'success' | 'error' | 'warning' | 'info';
export type Notification = {
  type: NotificationType;
  message: string;
  id?: string;
  timeout?: number;
};

export const useNotification = () => {
  const notifications = ref<Notification[]>([]);

  const showNotification = (
    type: NotificationType,
    message: string,
    options: { timeout?: number } = {}
  ) => {
    const id = Math.random().toString(36).substr(2, 9);
    const notification: Notification = {
      type,
      message,
      id,
      timeout: options.timeout || 3000
    };

    notifications.value.push(notification);

    if (notification.timeout) {
      setTimeout(() => {
        removeNotification(id);
      }, notification.timeout);
    }

    return id;
  };

  const removeNotification = (id: string) => {
    notifications.value = notifications.value.filter(n => n.id !== id);
  };

  const clearNotifications = () => {
    notifications.value = [];
  };

  return {
    notifications,
    showNotification,
    removeNotification,
    clearNotifications
  };
}; 