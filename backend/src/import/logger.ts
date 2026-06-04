type LogLevel = 'info' | 'warn' | 'error' | 'debug';

function timestamp(): string {
  return new Date().toISOString();
}

function log(level: LogLevel, message: string, meta?: object): void {
  const prefix = `[${timestamp()}] [import:${level}]`;
  if (meta && Object.keys(meta).length > 0) {
    console[level === 'debug' ? 'log' : level](`${prefix} ${message}`, meta);
  } else {
    console[level === 'debug' ? 'log' : level](`${prefix} ${message}`);
  }
}

export const logger = {
  info: (message: string, meta?: object) => log('info', message, meta),
  warn: (message: string, meta?: object) => log('warn', message, meta),
  error: (message: string, meta?: object) => log('error', message, meta),
  debug: (message: string, meta?: object) => log('debug', message, meta),
};
