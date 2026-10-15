# MENOVA

Simulator pemesanan kafe via QR — Scan QR → Pesan → Dashboard.

Demo statis single-file (`index.html`). Deploy ke Vercel untuk URL publik.
Data saat ini masih `localStorage` (per-browser). Tahap berikutnya: migrasi ke Supabase agar multi-device realtime.

## Jalankan lokal
Buka `index.html` di browser, atau:
```bash
npx serve .
```

## Deploy Vercel
Import repo ini di Vercel, framework: Other, root: `./`.
