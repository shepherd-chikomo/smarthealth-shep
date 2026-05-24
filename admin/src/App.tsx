import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import type { ReactNode } from 'react';
import { AuthProvider, useAuth } from './lib/auth';
import { ThemeProvider } from './lib/theme';
import { AdminLayout } from './components/Layout';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';
import { UserManagementPage } from './pages/UserManagementPage';
import { FacilityAdminsPage } from './pages/FacilityAdminsPage';
import { QueuePage } from './pages/QueuePage';
import { ProvidersPage } from './pages/ProvidersPage';
import { AppointmentsPage } from './pages/AppointmentsPage';
import { HoursPage } from './pages/HoursPage';
import { ContentPage } from './pages/ContentPage';
import { SettingsPage } from './pages/SettingsPage';
import { ReportsPage } from './pages/ReportsPage';
import { AnalyticsPage } from './pages/AnalyticsPage';
import { SecurityPage } from './pages/SecurityPage';
import { ClaimsPage } from './pages/ClaimsPage';
import { ImportPage } from './pages/ImportPage';

const qc = new QueryClient({ defaultOptions: { queries: { retry: 1, staleTime: 30_000 } } });

function Protected({ children }: { children: ReactNode }) {
  const { profile, loading } = useAuth();
  if (loading) return <div className="flex min-h-screen items-center justify-center">Loading…</div>;
  if (!profile) return <Navigate to="/login" replace />;
  return children;
}

export function App() {
  return (
    <QueryClientProvider client={qc}>
      <ThemeProvider>
        <AuthProvider>
          <BrowserRouter basename="/admin">
            <Routes>
              <Route path="/login" element={<LoginPage />} />
              <Route
                element={
                  <Protected>
                    <AdminLayout />
                  </Protected>
                }
              >
                <Route index element={<DashboardPage />} />
                <Route path="users" element={<UserManagementPage />} />
                <Route path="facility-admins" element={<FacilityAdminsPage />} />
                <Route path="queue" element={<QueuePage />} />
                <Route path="providers" element={<ProvidersPage />} />
                <Route path="claims" element={<ClaimsPage />} />
                <Route path="import" element={<ImportPage />} />
                <Route path="appointments" element={<AppointmentsPage />} />
                <Route path="hours" element={<HoursPage />} />
                <Route path="content" element={<ContentPage />} />
                <Route path="settings" element={<SettingsPage />} />
                <Route path="reports" element={<ReportsPage />} />
                <Route path="analytics" element={<AnalyticsPage />} />
                <Route path="security" element={<SecurityPage />} />
              </Route>
            </Routes>
          </BrowserRouter>
        </AuthProvider>
      </ThemeProvider>
    </QueryClientProvider>
  );
}
