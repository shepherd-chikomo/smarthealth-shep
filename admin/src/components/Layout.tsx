import {
  BarChart3,
  Activity,
  Calendar,
  Clock,
  FileText,
  LayoutDashboard,
  LogOut,
  Settings,
  Shield,
  Stethoscope,
  UserCog,
  Users,
  Building2,
  Bell,
  BadgeCheck,
  Upload,
} from 'lucide-react';
import { NavLink, Outlet } from 'react-router-dom';
import clsx from 'clsx';
import { useAuth } from '../lib/auth';
import { ThemeToggle } from './ThemeToggle';

const nav = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/users', label: 'User Management', icon: UserCog, superOnly: true },
  { to: '/facility-admins', label: 'Facility Admins', icon: Users, superOnly: true },
  { to: '/queue', label: 'Queue', icon: Activity },
  { to: '/providers', label: 'Providers', icon: Stethoscope },
  { to: '/facilities', label: 'Facilities', icon: Building2, superOnly: true },
  { to: '/registry-changes', label: 'Registry Changes', icon: FileText, superOnly: true },
  { to: '/claims', label: 'Claims', icon: BadgeCheck },
  { to: '/import', label: 'Data Import', icon: Upload, superOnly: true },
  { to: '/appointments', label: 'Appointments', icon: Calendar },
  { to: '/hours', label: 'Operating Hours', icon: Clock },
  { to: '/content', label: 'Content', icon: Bell },
  { to: '/settings', label: 'System Settings', icon: Settings },
  { to: '/analytics', label: 'Analytics', icon: BarChart3, superOnly: true },
  { to: '/reports', label: 'Reports', icon: FileText },
  { to: '/security', label: 'Audit Log', icon: Shield },
];

export function AdminLayout() {
  const { profile, logout } = useAuth();
  const isSuper = profile?.role === 'super_admin';

  return (
    <div className="min-h-screen lg:flex">
      <aside className="flex w-full flex-col border-b border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900 lg:fixed lg:h-screen lg:w-64 lg:border-b-0 lg:border-r">
        <div className="flex shrink-0 items-center justify-between px-4 py-4">
          <div>
            <p className="text-lg font-bold text-teal-600">SmartHealth</p>
            <p className="text-xs text-slate-500">Admin Dashboard</p>
          </div>
          <div className="flex items-center gap-2 lg:hidden">
            <ThemeToggle />
            <button type="button" className="btn-secondary" onClick={logout} aria-label="Logout">
              <LogOut className="h-4 w-4" />
            </button>
          </div>
        </div>
        <nav className="flex min-h-0 flex-1 gap-1 overflow-x-auto overflow-y-auto px-2 pb-3 lg:flex-col lg:overflow-x-visible lg:px-3">
          {nav.filter((n) => !n.superOnly || isSuper).map(({ to, label, icon: Icon }) => (
            <NavLink
              key={to}
              to={to}
              end={to === '/'}
              className={({ isActive }) =>
                clsx(
                  'flex shrink-0 items-center gap-2 rounded-lg px-3 py-2 text-sm font-medium',
                  isActive
                    ? 'bg-teal-50 text-teal-700 dark:bg-teal-950 dark:text-teal-300'
                    : 'text-slate-600 hover:bg-slate-100 dark:text-slate-300 dark:hover:bg-slate-800',
                )
              }
            >
              <Icon className="h-4 w-4" />
              {label}
            </NavLink>
          ))}
        </nav>
        <div className="mt-auto shrink-0 border-t border-slate-200 p-4 dark:border-slate-800">
          <div className="mb-3 hidden text-sm lg:block">
            <p className="font-medium">{profile?.firstName} {profile?.lastName}</p>
            <p className="text-xs text-slate-500 capitalize">{profile?.role?.replace('_', ' ')}</p>
          </div>
          <div className="hidden gap-2 lg:flex">
            <ThemeToggle />
            <button type="button" className="btn-secondary flex flex-1 items-center justify-center gap-2" onClick={logout}>
              <LogOut className="h-4 w-4" />
              Logout
            </button>
          </div>
        </div>
      </aside>

      <main className="flex-1 p-4 lg:ml-64 lg:p-8">
        <Outlet />
      </main>
    </div>
  );
}

export function BuildingIcon() {
  return <Building2 className="h-4 w-4" />;
}
