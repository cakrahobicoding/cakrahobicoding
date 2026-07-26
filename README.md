# 🚀 Ranzx - VPS Tools Dashboard

<div align="center">

![Bash](https://x.xcute.workers.dev/f/images/ef9c10520a79.gif)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Linux%20VPS-orange?style=for-the-badge&logo=linux)
![Version](https://img.shields.io/badge/Version-2.0-brightgreen?style=for-the-badge)

![Stars](https://img.shields.io/github/stars/USERNAME/ranzx?style=social)
![Forks](https://img.shields.io/github/forks/USERNAME/ranzx?style=social)
![Issues](https://img.shields.io/github/issues/USERNAME/ranzx)
![Last Commit](https://img.shields.io/github/last-commit/USERNAME/ranzx)

**Dashboard interaktif untuk cek spesifikasi VPS & install tools populer dengan sekali klik**

[Fitur](#-fitur) • [Instalasi](#-instalasi) • [Cara Pakai](#-cara-pakai) • [Menu](#-daftar-menu) • [Kontribusi](#-kontribusi)

</div>

---

## 📋 Tentang

**Ranzx** adalah tools dashboard berbasis bash script yang memudahkan kamu untuk:
- Mengecek spesifikasi VPS (CPU, RAM, Disk, Uptime) dengan tampilan yang rapi
- Install web server, runtime, dan tools populer tanpa perlu hafal command satu-satu
- Semua proses interaktif — tinggal pilih menu, tekan `y`, selesai

Cocok buat kamu yang baru mulai kelola VPS dan males ngetik command panjang berkali-kali.

## ✨ Fitur

- 📊 Cek informasi sistem lengkap (OS, kernel, CPU, RAM, disk, load average)
- 🌐 Install Nginx web server otomatis
- 📦 Install Git & clone repository langsung dari menu
- ⚡ Install Node.js (pilihan versi 16/18/20)
- 📦 Install NVM (Node Version Manager)
- 🎮 Install Pterodactyl Panel
- 🎨 Install Neofetch
- 🔧 Install banyak tools sekaligus dalam satu perintah
- 🎬 Animasi loading & progress bar biar nggak bosen nunggu

## 🛠️ Requirement

- OS: Ubuntu / Debian (atau turunannya)
- Akses `root` atau `sudo`
- Koneksi internet aktif

## 📥 Instalasi

Clone repository ini ke VPS kamu:

```bash
git clone https://github.com/cakrahobicoding/ranzx.git
cd ranzx
chmod +x ranzx.sh
```

Atau download langsung tanpa clone:

```bash
curl -O https://raw.githubusercontent.com/cakrahobicoding/ranzx/main/ranzx.sh
chmod +x ranzx.sh
```

## ▶️ Cara Pakai

Jalankan dengan akses root:

```bash
sudo bash ranzx.sh
```

Setelah dijalankan, kamu akan melihat menu interaktif. Tinggal ketik angka menu yang diinginkan lalu tekan Enter.

## 📜 Daftar Menu

| No | Menu | Keterangan |
|----|------|------------|
| 1 | 📊 Cek System Information | Lihat spesifikasi lengkap VPS |
| 2 | 🌐 Install Nginx | Install & jalankan web server Nginx |
| 3 | 📦 Install Git & Clone Repository | Install Git dan clone repo pilihan |
| 4 | ⚡ Install Node.js | Install Node.js versi 16/18/20 |
| 5 | 📦 Install NVM | Install Node Version Manager |
| 6 | 🎮 Install Pterodactyl Panel | Install game server panel |
| 7 | 🎨 Install Neofetch | Install tools tampilan system info |
| 8 | 🔧 Install Multiple Tools | Install beberapa tools sekaligus |
| 0 | ❌ Exit | Keluar dari dashboard |

## ⚠️ Catatan

- Script ini akan menjalankan perintah `sudo apt install`, jadi pastikan kamu paham tools apa yang akan diinstall sebelum konfirmasi `y`
- Untuk Pterodactyl Panel, pastikan PHP, MySQL/MariaDB, dan Composer sudah tersedia
- Setelah install NVM, buka terminal baru sebelum menjalankan `nvm`

## 🤝 Kontribusi

Pull request selalu diterima! Untuk perubahan besar, buka issue dulu buat diskusi mau diubah apa.

1. Fork repo ini
2. Buat branch baru (`git checkout -b fitur-baru`)
3. Commit perubahan (`git commit -m 'Menambahkan fitur X'`)
4. Push ke branch (`git push origin fitur-baru`)
5. Buka Pull Request

## 📄 Lisensi

Distributed under the MIT License.

## 👤 About Me

<!-- Ganti bagian ini dengan info kamu -->

**Nama Kamu**

- GitHub: [@USERNAME](https://github.com/USERNAME)
- Instagram: [@username](https://instagram.com/username)
- Telegram: [@username](https://t.me/username)

---

<div align="center">

⭐ Kalau tools ini membantu, jangan lupa kasih **star** ya!

</div>
