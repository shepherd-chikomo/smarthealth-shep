type LogLevel = 'info' | 'warn' | 'error' | 'debug';

function timestamp(): string {
  return new Date().toISOString();
}

function log(level: LogLevel, message: string, meta?: Record<string, unknown>): void {
  const prefix = `[${timestamp()}] [import:${level}]`;
  if (meta && Object.keys(meta).length > 0) {
    console[level === 'debug' ? 'log' : level](`${prefix} ${message}`, meta);
  } else {
    console[level === 'debug' ? 'log' : level](`${prefix} ${message}`);
  }
}

export const logger = {
  info: (message: string, meta?: Record<string, unknown>) => log('info', message, meta),
  warn: (message: string, meta?: Record<string, unknown>) => log('warn', message, meta),
  error: (message: string, meta?: Record<string, unknown>) => log('error', message, meta),
  debug: (message: string, meta?: Record<string, unknown>) => log('debug', message, meta),
};
