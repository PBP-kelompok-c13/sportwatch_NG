# ⚽ Sportwatch_NG (Aplikasi Mobile)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-TAHAP%20II%20(25%25)-yellow?style=for-the-badge)
[![Bitrise Build Status](https://app.bitrise.io/app/YOUR_APP_SLUG/status.svg?token=YOUR_API_TOKEN)](https://app.bitrise.io/app/YOUR_APP_SLUG)
![CI/CD Status](https://img.shields.io/badge/CI%2FCD-Not%20Started-red?style=for-the-badge)

Platform digital terpadu berbasis aplikasi mobile (Flutter/Dart) yang memungkinkan pengguna membaca berita olahraga, memantau skor pertandingan, berdiskusi, hingga membeli merchandise tim favorit mereka.

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

Arsitektur aplikasi ini menggunakan model **Client-Server**.

* **Backend (Server):** Proyek Django yang telah dibuat (Proyek Tengah Semester) berfungsi sebagai **API Server**. Menggunakan **Django REST Framework (DRF)**, *backend* tidak lagi mengirimkan HTML, melainkan menyediakan *endpoints* (URL) yang mengirimkan dan menerima data murni dalam format **JSON**.
* **Frontend (Client):** Aplikasi mobile Flutter ini bertindak sebagai **client**. Flutter tidak memiliki akses langsung ke database, melainkan berkomunikasi dengan *backend* Django melalui **HTTP Requests** (GET, POST, PUT, DELETE) untuk mengonsumsi *endpoints* API tersebut.

Alur integrasi fungsional adalah sebagai berikut:

* **Autentikasi:**
    * Flutter mengirimkan *request* `POST` ke *endpoint* `/api/login/` (contoh) dengan kredensial pengguna (JSON).
    * Server Django memvalidasi data dan mengembalikan *token* (misal, JWT) dalam respons JSON.
    * Flutter menyimpan *token* ini di *local storage* (misal: `flutter_secure_storage`) untuk digunakan di *header* *request* selanjutnya.

* **Pengambilan Data (Berita, Produk, Skor):**
    * Flutter mengirimkan *request* `GET` ke *endpoint* yang relevan (misal, `/api/berita/`).
    * Server Django (via *Serializer*) mengambil data dari database, mengubahnya menjadi JSON, dan mengirimkannya kembali.
    * Flutter menerima JSON, mem-parsing-nya menjadi *List* objek Dart, dan menampilkannya di UI (misal: `ListView`).

* **Pengiriman Data (Checkout, CRUD Admin):**
    * Flutter mengirimkan *request* `POST` atau `PUT` ke *endpoint* yang sesuai (misal, `/api/checkout/`) dengan membawa *payload* data (JSON) dan *token* autentikasi.
    * Server Django memvalidasi data, memprosesnya ke database, dan mengembalikan status sukses atau error dalam format JSON.

## 📋 Tahapan Pengerjaan

Secara garis besar, yang akan kita lakukan adalah (sementara):

1. Memetakan fitur web → fitur mobile  
2. Memutuskan pola autentikasi untuk mobile  
3. Merapikan layer API per app 
4. Mengatur struktur URL API supaya rapi  
5. Melakukan standarisasi format response API  
6. Membangun mobile app sebagai client API  
7. Menangani keamanan & environment  
8. Menguji end-to-end  
9. Melakukan penyempurnaan UI untuk setiap modul  

## 🎨 Link Figma

* [https://www.figma.com/make/h1deASIz7IL8uZRctJkKYl/SportWatch-Web-App-Design?node-id=0-1&p=f&t=2bJs6hW6aXSqO6Cg-0](https://www.figma.com/make/h1deASIz7IL8uZRctJkKYl/SportWatch-Web-App-Design?node-id=0-1&p=f&t=2bJs6hW6aXSqO6Cg-0)
