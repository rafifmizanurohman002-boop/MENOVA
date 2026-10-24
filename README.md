# MENOVA

Simulator pemesanan kafe via QR — Scan QR → Pesan → Dashboard.

Demo statis single-file (`index.html`). Deploy ke Vercel untuk URL publik.
Data tersimpan di Supabase (realtime, multi-device). Kredensial ada di `index.html` (anon key, aman untuk demo).

## Jalankan lokal
Buka `index.html` di browser, atau:
```bash
npx serve .
```

## Deploy Vercel (sudah terhubung Git)
Repo ini terhubung ke 2 project Vercel, keduanya auto-deploy setiap push ke `main`:

| Project | Root Directory | URL produksi | Isi |
|---|---|---|---|
| `menova` | `./` (root repo) | https://menova.vercel.app | Aplikasi menu + kasir (Supabase realtime) |
| `marketing` | `./marketing` | https://marketing-dusky-two.vercel.app | Landing page marketing |

Update lokal → commit → `git push origin main` → Vercel deploy otomatis.

## Pembayaran (Tunai + QRIS manual)
Alur: Keranjang → Bayar → pesanan tercatat Belum Bayar / Menunggu Verifikasi → kasir konfirmasi di tab Bayar → masuk dapur. Stok berkurang saat Lunas.
Yang perlu disiapkan: jalankan `supabase/migration_payment.sql` sekali di SQL Editor, dan taruh gambar QRIS sebagai `qris.png` di root repo.
