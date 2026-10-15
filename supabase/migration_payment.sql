-- MENOVA pembayaran: Tunai di kasir + QRIS manual
-- Jalankan SEKALI di Supabase Dashboard > SQL Editor, lalu tidak perlu lagi.

alter table public.orders
  add column if not exists payment_method text not null default 'tunai'
  check (payment_method in ('tunai','qris'));
alter table public.orders
  add column if not exists payment_status text not null default 'belum_bayar'
  check (payment_status in ('belum_bayar','menunggu_verifikasi','lunas','ditolak'));
alter table public.orders
  add column if not exists proof_url text;

-- Bucket bukti transfer (public agar kasir bisa buka via URL)
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
