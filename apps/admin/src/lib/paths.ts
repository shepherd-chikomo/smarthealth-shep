/** Login URL respecting Vite `base` (e.g. `/admin/login` in dev and Docker). */
export const loginPath = `${import.meta.env.BASE_URL}login`.replace(/\/{2,}/g, '/');

export function redirectToLogin(): void {
  if (window.location.pathname === loginPath) return;
  window.location.href = loginPath;
}
