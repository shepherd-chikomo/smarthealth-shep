/** Login URL respecting Vite `base` (e.g. `/admin/login` in dev and Docker). */
export const loginPath = `${import.meta.env.BASE_URL}login`.replace(/\/{2,}/g, '/');

export function redirectToLogin(): void {
  window.location.href = loginPath;
}
