import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  base: '/admin/',
  plugins: [react(), tailwindcss()],  server: {
    port: 5173,
    proxy: {
      '/v1': { target: 'http://localhost:3000', changeOrigin: true },
    },
    // Dev convenience: /login → /admin/login (Vite base is /admin/)
    open: '/admin/login',
  },
});
