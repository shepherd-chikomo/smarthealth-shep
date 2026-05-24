-- SmartHealth: inventory (products, stock, suppliers, purchase orders)

begin;

create table public.suppliers (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  name text not null,
  contact_name text,
  phone text,
  email text,
  address text,
  tax_number text,
  payment_terms text,
  is_active boolean not null default true,
  search_vector tsvector,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint suppliers_tenant_match_chk check (tenant_id = facility_id)
);

create index suppliers_tenant_idx on public.suppliers (tenant_id) where deleted_at is null;
create index suppliers_search_idx on public.suppliers using gin (search_vector);

create trigger suppliers_set_updated_at
  before update on public.suppliers
  for each row execute function public.set_updated_at();

create table public.products (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  sku text not null,
  name text not null,
  description text,
  category text,
  unit_of_measure text not null default 'each',
  unit_cost_cents bigint check (unit_cost_cents is null or unit_cost_cents >= 0),
  unit_price_cents bigint check (unit_price_cents is null or unit_price_cents >= 0),
  reorder_level numeric(10, 2) not null default 0,
  current_stock numeric(10, 2) not null default 0 check (current_stock >= 0),
  is_prescription_required boolean not null default false,
  is_active boolean not null default true,
  search_vector tsvector,
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint products_tenant_match_chk check (tenant_id = facility_id),
  unique (tenant_id, sku)
);

create index products_tenant_idx on public.products (tenant_id) where deleted_at is null;
create index products_low_stock_idx on public.products (tenant_id, current_stock)
  where is_active = true and deleted_at is null;
create index products_search_idx on public.products using gin (search_vector);

create trigger products_set_updated_at
  before update on public.products
  for each row execute function public.set_updated_at();

create table public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products (id) on delete restrict,
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  movement_type public.stock_movement_type not null,
  quantity numeric(10, 2) not null check (quantity > 0),
  unit_cost_cents bigint,
  reference_type text,
  reference_id uuid,
  notes text,
  performed_by uuid references public.profiles (id),
  movement_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now())
);

create index stock_movements_product_idx on public.stock_movements (product_id, movement_at desc);
create index stock_movements_tenant_idx on public.stock_movements (tenant_id);

-- Update product stock on movement
create or replace function public.apply_stock_movement()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_delta numeric(10, 2);
begin
  v_delta := case
    when new.movement_type in ('purchase', 'transfer_in', 'returned') then new.quantity
    when new.movement_type in ('sale', 'transfer_out', 'expired', 'damaged') then -new.quantity
    when new.movement_type = 'adjustment' then new.quantity
    else 0
  end;

  update public.products
  set
    current_stock = greatest(0, current_stock + v_delta),
    updated_at = timezone('utc', now())
  where id = new.product_id;

  return new;
end;
$$;

create trigger stock_movements_apply
  after insert on public.stock_movements
  for each row execute function public.apply_stock_movement();

create table public.purchase_orders (
  id uuid primary key default gen_random_uuid(),
  facility_id uuid not null references public.facilities (id) on delete restrict,
  tenant_id uuid not null references public.facilities (id) on delete restrict,
  supplier_id uuid not null references public.suppliers (id) on delete restrict,
  po_number text not null,
  status public.purchase_order_status not null default 'draft',
  currency_code char(3) not null default 'USD',
  subtotal_cents bigint not null default 0,
  tax_cents bigint not null default 0,
  total_cents bigint not null default 0,
  ordered_at timestamptz,
  expected_at timestamptz,
  received_at timestamptz,
  notes text,
  created_by uuid references public.profiles (id),
  metadata jsonb not null default '{}'::jsonb,
  deleted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint purchase_orders_tenant_match_chk check (tenant_id = facility_id),
  unique (tenant_id, po_number)
);

create index purchase_orders_tenant_status_idx
  on public.purchase_orders (tenant_id, status)
  where deleted_at is null;
create index purchase_orders_supplier_idx on public.purchase_orders (supplier_id);

create trigger purchase_orders_set_updated_at
  before update on public.purchase_orders
  for each row execute function public.set_updated_at();

create table public.purchase_order_items (
  id uuid primary key default gen_random_uuid(),
  purchase_order_id uuid not null references public.purchase_orders (id) on delete cascade,
  tenant_id uuid not null references public.facilities (id) on delete cascade,
  product_id uuid not null references public.products (id) on delete restrict,
  quantity_ordered numeric(10, 2) not null check (quantity_ordered > 0),
  quantity_received numeric(10, 2) not null default 0 check (quantity_received >= 0),
  unit_cost_cents bigint not null check (unit_cost_cents >= 0),
  line_total_cents bigint generated always as (
    round(quantity_ordered * unit_cost_cents)::bigint
  ) stored,
  created_at timestamptz not null default timezone('utc', now())
);

create index purchase_order_items_po_idx on public.purchase_order_items (purchase_order_id);

commit;
