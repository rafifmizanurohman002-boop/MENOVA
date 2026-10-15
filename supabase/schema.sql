-- MENOVA Supabase schema (demo: akses anon terbuka)
-- Jalankan di Supabase Dashboard > SQL Editor

create table if not exists public.menus (
  id bigint primary key,
  name text not null,
  category text not null default 'Lainnya',
  price integer not null default 0,
  stock integer not null default 0,
  emoji text not null default '🍽️'
);

create table if not exists public.orders (
  id bigint generated always as identity primary key,
  table_number integer not null,
  customer_name text default '',
  note text default '',
  status text not null default 'Diterima'
    check (status in ('Diterima','Diproses','Selesai')),
  total integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id bigint generated always as identity primary key,
  order_id bigint not null references public.orders(id) on delete cascade,
  menu_id bigint references public.menus(id) on delete set null,
  name text not null,
  price integer not null,
  qty integer not null check (qty > 0)
);

alter table public.menus enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Kebijakan demo: siapa pun (anon) bisa baca/tulis.
-- Ketatkan nanti setelah login kasir ditambahkan.
drop policy if exists "demo all menus" on public.menus;
create policy "demo all menus" on public.menus
  for all to anon using (true) with check (true);

drop policy if exists "demo all orders" on public.orders;
create policy "demo all orders" on public.orders
  for all to anon using (true) with check (true);

drop policy if exists "demo all order_items" on public.order_items;
create policy "demo all order_items" on public.order_items
  for all to anon using (true) with check (true);

-- Seed awal (sama dengan DEF.menu di index.html)
insert into public.menus (id, name, category, price, stock, emoji) values
  (1,'Espresso','Kopi',18000,20,'☕'),
  (2,'Americano','Kopi',20000,20,'☕'),
  (3,'Kopi Susu Gula Aren','Kopi',24000,25,'🧋'),
  (4,'Latte','Kopi',26000,15,'🥛'),
  (5,'Matcha Latte','Non-Kopi',28000,12,'🍵'),
  (6,'Teh Tarik','Non-Kopi',18000,20,'🫖'),
  (7,'Coklat Panas','Non-Kopi',24000,10,'🍫'),
  (8,'Roti Bakar','Makanan',20000,12,'🍞'),
  (9,'Nasi Goreng','Makanan',32000,10,'🍳'),
  (10,'Kentang Goreng','Makanan',22000,3,'🍟')
on conflict (id) do nothing;

-- Pembayaran: Tunai + QRIS manual (idempoten, aman di-run ulang)
alter table public.orders
  add column if not exists payment_method text not null default 'tunai'
  check (payment_method in ('tunai','qris'));
alter table public.orders
  add column if not exists payment_status text not null default 'belum_bayar'
  check (payment_status in ('belum_bayar','menunggu_verifikasi','lunas','ditolak'));
alter table public.orders
  add column if not exists proof_url text;
insert into storage.buckets (id, name, public)
values ('payment-proofs','payment-proofs', true)
on conflict (id) do update set public = true;
drop policy if exists "anon upload proofs" on storage.objects;
create policy "anon upload proofs" on storage.objects
  for insert to anon with check (bucket_id='payment-proofs');
drop policy if exists "anon read proofs" on storage.objects;
create policy "anon read proofs" on storage.objects
  for select to anon using (bucket_id='payment-proofs');
drop policy if exists "anon update proofs" on storage.objects;
create policy "anon update proofs" on storage.objects
  for update to anon using (bucket_id='payment-proofs') with check (bucket_id='payment-proofs');
