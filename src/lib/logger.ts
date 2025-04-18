import { supabase } from './supabase';

interface LogEntry {
  level: 'info' | 'warn' | 'error';
  module: string;
  message: string;
  data?: any;
  error?: any;
}

class Logger {
  private context: string;

  constructor(context: string) {
    this.context = context;
  }

  private async logToSupabase(entry: LogEntry) {
    try {
      const { error } = await supabase
        .from('system_logs')
        .insert({
          level: entry.level,
          module: entry.module,
          message: entry.message,
          data: entry.data,
          error: entry.error ? {
            message: entry.error.message,
            stack: entry.error.stack,
            name: entry.error.name
          } : null
        });

      if (error) {
        console.error('[Logger] Failed to write to Supabase:', error);
      }
    } catch (e) {
      console.error('[Logger] Error logging to Supabase:', e);
    }
  }

  private formatMessage(message: string): string {
    return `[${this.context}] ${message}`;
  }

  info(message: string, data?: any) {
    const entry = {
      level: 'info' as const,
      module: this.context,
      message,
      data
    };
    console.info(this.formatMessage(message), data || '');
    this.logToSupabase(entry);
  }

  warn(message: string, data?: any) {
    const entry = {
      level: 'warn' as const,
      module: this.context,
      message,
      data
    };
    console.warn(this.formatMessage(message), data || '');
    this.logToSupabase(entry);
  }

  error(message: string, error?: any, data?: any) {
    const entry = {
      level: 'error' as const,
      module: this.context,
      message,
      data,
      error
    };
    console.error(this.formatMessage(message), error, data || '');
    this.logToSupabase(entry);
  }
}

export function createLogger(context: string): Logger {
  return new Logger(context);
} 