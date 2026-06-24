const ACCESS_TOKEN_KEY = 'sh_admin_access_token';
const REFRESH_TOKEN_KEY = 'sh_admin_refresh_token';

function storage(): Storage {
  return sessionStorage;
}

export function getAccessToken(): string | null {
  return storage().getItem(ACCESS_TOKEN_KEY);
}

export function getRefreshToken(): string | null {
  return storage().getItem(REFRESH_TOKEN_KEY);
}

export function setTokens(accessToken: string | null, refreshToken?: string | null) {
  if (accessToken) {
    storage().setItem(ACCESS_TOKEN_KEY, accessToken);
  } else {
    storage().removeItem(ACCESS_TOKEN_KEY);
  }
  if (refreshToken !== undefined) {
    if (refreshToken) storage().setItem(REFRESH_TOKEN_KEY, refreshToken);
    else storage().removeItem(REFRESH_TOKEN_KEY);
  }
}

export function clearTokens() {
  storage().removeItem(ACCESS_TOKEN_KEY);
  storage().removeItem(REFRESH_TOKEN_KEY);
  localStorage.removeItem('sh_admin_token');
}

/** @deprecated Use setTokens */
export function setToken(token: string | null) {
  setTokens(token);
}

/** @deprecated Use getAccessToken */
export function getToken(): string | null {
  return getAccessToken();
}
