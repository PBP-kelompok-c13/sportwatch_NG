# ⚽ SportWatch (Aplikasi Mobile)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-Tahap%20I%20(20%25)-brightgreen?style=for-the-badge)

Platform digital terpadu berbasis aplikasi mobile (Flutter/Dart) yang memungkinkan pengguna membaca berita olahraga, memantau skor pertandingan, berdiskusi, hingga membeli merchandise tim favorit mereka.

---

### 🔗 Tautan Penting
* **GitHub Repository:** `[Link ke GitHub Kelompok]`
* **Codebase:** `[Link ke Codebase Kelompok]`

---

## 👥 Daftar Anggota Kelompok

| Nama Lengkap | NPM |
| :--- | :--- |
| **Faiz Yusuf Ridwan** | `2406434292` |
| **Muhammad Fadhil Al Afifi Fajar** | `2406430104` |
| **Edward Jeremy Worang** | `2406359475` |
| **Kadek Ngurah Septyawan Chandra Diputra**| `2406420772` |
| **Dzaki Abrar Fatihul Ihsan** | `2306275241` |

## 📝 Deskripsi Aplikasi

* **Nama Aplikasi:** SportWatch
* **Fungsi Aplikasi:** SportWatch adalah portal olahraga *all-in-one* di saku Anda. Aplikasi ini menyediakan berita terkini, skor pertandingan *real-time*, dan marketplace khusus untuk merchandise olahraga.

## 🚀 Daftar Modul & Pembagian Kerja

### 1. Portal Berita (`portal-berita`)
* **Penanggung Jawab:** Faiz Yusuf Ridwan
* **Deskripsi:** Menyediakan halaman berita olahraga terkini, fungsionalitas CRUD berita oleh admin, dan filter berita berdasarkan kategori.

### 2. Scoreboard (`scoreboard`)
* **Penanggung Jawab:** Muhammad Fadhil Al Afifi Fajar
* **Deskripsi:** Menampilkan skor pertandingan olahraga secara *real-time* atau melalui *update* manual oleh admin.

### 3. Fitur Pencarian (`search`)
* **Penanggung Jawab:** Kadek Ngurah Septyawan Chandra Diputra
* **Deskripsi:** Mengimplementasikan fungsionalitas filter dan pencarian untuk modul Berita dan Shop.

### 4. Shop (`shop`)
* **Penanggung Jawab:** Edward Jeremy Worang
* **Deskripsi:** Halaman *marketplace* untuk melihat merchandise olahraga. Termasuk model produk, sistem filtering, dan rating.

### 5. Fitur Belanja (`checkout`)
* **Penanggung Jawab:** Dzaki Abrar Fatihul Ihsan
* **Deskripsi:** Mengatur logika bisnis untuk pembelian, seperti tambah/hapus keranjang, kalkulasi total harga, dan simulasi proses *checkout*.

## 🧑‍💻 Peran Pengguna (Aktor)

Aplikasi ini memiliki tiga peran utama:

1.  **Guest (Tamu):**
    * Dapat membaca berita.
    * Dapat melihat skor pertandingan.
    * Dapat melihat produk di *shop*.
    * *Tidak dapat* berinteraksi (komentar) atau bertransaksi.
2.  **User (Pengguna Terdaftar):**
    * Memiliki semua hak **Guest**.
    * Dapat melakukan transaksi pembelian di *shop*.
    * Dapat berinteraksi di aplikasi (jika fitur dikembangkan).
3.  **Admin:**
    * Memiliki hak istimewa untuk mengelola konten aplikasi (CRUD Berita, Produk, dan Skor Pertandingan).

## 🔌 Alur Pengintegrasian Web Service

Aplikasi mobile Flutter ini akan berinteraksi penuh dengan Web Service (API) yang telah dibuat saat Proyek Tengah Semester.

* *(Placeholder: Jelaskan alur autentikasi pengguna via API)*
* *(Placeholder: Jelaskan alur pengambilan (GET) data berita dari API)*
* *(Placeholder: Jelaskan alur pengambilan (GET) data scoreboard dari API)*
* *(Placeholder: Jelaskan alur pengambilan (GET) data produk/shop dari API)*
* *(Placeholder: Jelaskan alur pengiriman (POST) data transaksi/checkout ke API)*

## 🎨 Link Figma

* [https://exit-upload-30788858.figma.site/](https://exit-upload-30788858.figma.site/) (Referensi Desain)
