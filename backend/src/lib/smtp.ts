import net from 'node:net';

export interface SmtpSendResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

function readCode(buffer: string): number {
  return Number.parseInt(buffer.slice(0, 3), 10);
}

/** Minimal SMTP client for dev Inbucket (plain, no auth). */
export async function sendSmtpEmail(options: {
  host: string;
  port: number;
  from: string;
  to: string;
  subject: string;
  html: string;
}): Promise<SmtpSendResult> {
  return new Promise((resolve) => {
    const messageId = `smtp-${Date.now()}@${options.host}`;
    const commands = [
      `EHLO smarthealth-api\r\n`,
      `MAIL FROM:<${options.from}>\r\n`,
      `RCPT TO:<${options.to}>\r\n`,
      `DATA\r\n`,
      [
        `From: ${options.from}`,
        `To: ${options.to}`,
        `Subject: ${options.subject}`,
        `Content-Type: text/html; charset=utf-8`,
        '',
        options.html,
      ].join('\r\n') + '\r\n.\r\n',
      `QUIT\r\n`,
    ];

    let step = 0;
    let buffer = '';

    const socket = net.createConnection(
      { host: options.host, port: options.port },
      () => {},
    );

    const fail = (error: string) => {
      socket.destroy();
      resolve({ success: false, error });
    };

    const next = () => {
      if (step >= commands.length) {
        socket.end();
        resolve({ success: true, messageId });
        return;
      }
      socket.write(commands[step]);
      step += 1;
    };

    socket.on('data', (chunk) => {
      buffer += chunk.toString();
      while (buffer.includes('\n')) {
        const lineEnd = buffer.indexOf('\n');
        const line = buffer.slice(0, lineEnd).trim();
        buffer = buffer.slice(lineEnd + 1);
        if (!line) continue;

        const code = readCode(line);
        if (Number.isNaN(code) || code >= 400) {
          fail(`SMTP error ${code}: ${line}`);
          return;
        }

        // Multi-line replies use hyphen after code (e.g. 250-).
        if (line.length > 3 && line[3] === '-') continue;
        next();
      }
    });

    socket.on('error', (err) => fail(err.message));
    socket.setTimeout(10_000, () => fail('SMTP timeout'));
  });
}
