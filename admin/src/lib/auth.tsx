import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { api, type AdminProfile, type OtpVerifyRequest } from './api';
import { redirectToLogin } from './paths';
import { clearTokens, setTokens } from './token-storage';

interface AuthContextValue {
  profile: AdminProfile | null;
  loading: boolean;
  login: (body: OtpVerifyRequest) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [profile, setProfile] = useState<AdminProfile | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.me()
      .then((r) => setProfile(r.profile))
      .catch(() => setProfile(null))
      .finally(() => setLoading(false));
  }, []);

  async function login(body: OtpVerifyRequest) {
    const tokens = await api.login({ ...body, context: body.context ?? 'staff' });
    setTokens(tokens.accessToken, tokens.refreshToken);
    const { profile: p } = await api.me();
    if (!['super_admin', 'facility_admin', 'doctor', 'receptionist'].includes(p.role)) {
      clearTokens();
      throw new Error('Not authorized for admin access');
    }
    setProfile(p);
  }

  function logout() {
    clearTokens();
    setProfile(null);
    redirectToLogin();
  }

  return (
    <AuthContext.Provider value={{ profile, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
