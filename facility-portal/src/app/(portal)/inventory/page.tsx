'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { api } from '@/lib/api';
import { useFacility } from '@/lib/facility-context';
import { ErrorState, LoadingState, PageHeader, PaginationBar, SearchBar } from '@/components/ui';

export default function InventoryPage() {
  const { facilityId } = useFacility();
  const qc = useQueryClient();
  const [page, setPage] = useState(1);
  const [q, setQ] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ sku: '', name: '', category: 'pharmacy', reorderLevel: 10, currentStock: 0 });

  const alerts = useQuery({
    queryKey: ['inventory-alerts', facilityId],
    queryFn: () => api.inventoryAlerts(facilityId!),
    enabled: !!facilityId,
  });

  const inventory = useQuery({
    queryKey: ['inventory', facilityId, page, q],
    queryFn: () => api.inventory(facilityId!, { page, limit: 20, q }),
    enabled: !!facilityId,
  });

  const create = useMutation({
    mutationFn: () => api.createProduct(facilityId!, form),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['inventory', facilityId] });
      setShowForm(false);
    },
  });

  return (
    <div>
      <PageHeader title="Inventory" description="Pharmacy stock, consumables, and low-stock alerts" />

      {(alerts.data?.alerts as unknown[])?.length ? (
        <div className="mb-4 rounded-lg border border-amber-300 bg-amber-50 p-4 dark:border-amber-800 dark:bg-amber-950">
          <p className="font-medium text-amber-800 dark:text-amber-200">
            {(alerts.data!.alerts as unknown[]).length} low-stock alert(s)
          </p>
          <ul className="mt-2 text-sm text-amber-700 dark:text-amber-300">
            {(alerts.data!.alerts as Record<string, unknown>[]).slice(0, 5).map((a) => (
              <li key={String(a.id)}>{String(a.name)} — {String(a.current_stock)} left (reorder at {String(a.reorder_level)})</li>
            ))}
          </ul>
        </div>
      ) : null}

      <div className="mb-4 flex flex-wrap gap-2">
        <SearchBar value={q} onChange={(v) => { setQ(v); setPage(1); }} placeholder="Search products…" />
        <button type="button" className="btn-primary" onClick={() => setShowForm(!showForm)}>Add product</button>
      </div>

      {showForm && (
        <form className="card mb-4 grid gap-3 sm:grid-cols-2" onSubmit={(e) => { e.preventDefault(); create.mutate(); }}>
          <input className="input" placeholder="SKU" required value={form.sku} onChange={(e) => setForm({ ...form, sku: e.target.value })} />
          <input className="input" placeholder="Name" required value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
          <input className="input" placeholder="Category" value={form.category} onChange={(e) => setForm({ ...form, category: e.target.value })} />
          <input type="number" className="input" placeholder="Reorder level" value={form.reorderLevel}
            onChange={(e) => setForm({ ...form, reorderLevel: Number(e.target.value) })} />
          <button type="submit" className="btn-primary sm:col-span-2" disabled={create.isPending}>Create product</button>
        </form>
      )}

      {inventory.isLoading && <LoadingState />}
      {inventory.error && <ErrorState message={(inventory.error as Error).message} />}
      {inventory.data && (
        <>
          <div className="table-wrap">
            <table className="data-table">
              <thead><tr><th>SKU</th><th>Name</th><th>Category</th><th>Stock</th><th>Reorder</th><th>Price</th></tr></thead>
              <tbody>
                {(inventory.data.products as Record<string, unknown>[]).map((p) => (
                  <tr key={String(p.id)}>
                    <td>{String(p.sku)}</td>
                    <td>{String(p.name)}</td>
                    <td>{String(p.category ?? '—')}</td>
                    <td className={Number(p.current_stock) <= Number(p.reorder_level) ? 'text-amber-600 font-medium' : ''}>
                      {String(p.current_stock)}
                    </td>
                    <td>{String(p.reorder_level)}</td>
                    <td>{p.unit_price_cents ? `$${(Number(p.unit_price_cents) / 100).toFixed(2)}` : '—'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <PaginationBar page={inventory.data.pagination.page} totalPages={inventory.data.pagination.totalPages} onPage={setPage} />
        </>
      )}
    </div>
  );
}
