# ⚽ Sportwatch_NG (Aplikasi Mobile)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-TAHAP%20II%20%2841%25%29-yellow?style=for-the-badge)

[![Flutter CI](https://github.com/PBP-kelompok-c13/sportwatch_NG/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/PBP-kelompok-c13/sportwatch_NG/actions/workflows/flutter-ci.yml)
[![Build Status](https://app.bitrise.io/app/88c9ea2b-d5f8-4446-9a5e-10f95db28c33/status.svg?token=B73M8_agenC2FZWZQA1MqA&branch=master)](https://app.bitrise.io/app/88c9ea2b-d5f8-4446-9a5e-10f95db28c33)

Platform digital terpadu berbasis aplikasi mobile (Flutter/Dart) yang memungkinkan pengguna membaca berita olahraga, memantau skor pertandingan, berdiskusi, hingga membeli merchandise tim favorit mereka.

---

## 👥 Daftar Anggota Kelompok

| Nama Lengkap                              | NPM          | 
| :---                                      | :---         |
| **Faiz Yusuf Ridwan**                     | `2406434292` |
| **Muhammad Fadhil Al Afifi Fajar**        | `2406430104` |
| **Edward Jeremy Worang**                  | `2406359475` |
| **Kadek Ngurah Septyawan Chandra Diputra**| `2406420772` |
| **Dzaki Abrar Fatihul Ihsan**             | `2306275241` |

## 📝 Deskripsi Aplikasi

**SportWatch** adalah aplikasi mobile berbasis Flutter/Dart yang
menghadirkan ekosistem olahraga *all-in-one* dalam satu platform.
Aplikasi ini dikembangkan untuk mengatasi permasalahan fragmentasi
layanan olahraga, di mana pengguna harus mengakses berbagai aplikasi
terpisah untuk membaca berita, memantau skor pertandingan, dan
mencari merchandise olahraga.

SportWatch menyediakan portal berita olahraga terkini, tampilan skor
pertandingan secara *real-time*, fitur pencarian lintas modul, serta
marketplace yang memungkinkan pengguna untuk menjual, membeli, dan
memberikan ulasan terhadap produk olahraga. Dengan pendekatan ini,
SportWatch bertujuan memberikan pengalaman terpadu bagi penggemar
olahraga melalui satu aplikasi yang terintegrasi dan mudah digunakan.

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
* **Deskripsi:** Halaman *marketplace* yang memungkinkan **admin** mengelola seluruh data produk, serta **user terdaftar** untuk menambahkan, mengubah, dan menghapus produk miliknya sendiri. Modul ini juga mencakup model produk, sistem *filtering*, dan fitur *rating*.

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
    * Dapat memberikan review terhadap produk yang dibeli.
    * Dapat menambahkan produk miliknya sendiri ke dalam *shop* sebagai penjual.
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

Secara garis besar, tahapan pengerjaan proyek ini adalah sebagai berikut:

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
## CI/CD

### GitHub Actions workflow
1. File `./.github/workflows/flutter-ci.yml` menyiapkan Flutter channel stabil di runner Ubuntu, menjalankan `flutter pub get`, kemudian `flutter test --no-pub` untuk setiap push/pull request menuju branch `main` atau `master`.
2. Setelah push, buka tab **Actions** di repositori [`PBP-kelompok-c13/sportwatch_NG`](https://github.com/PBP-kelompok-c13/sportwatch_NG) untuk memantau log, artefak, atau mengulang workflow bila gagal.
3. Jalankan `flutter test` secara lokal sebelum membuat commit agar hasilnya konsisten dengan CI di GitHub.

### Bitrise pipeline
1. Status badge Bitrise di atas menunjukan hasil dari app `88c9ea2b-d5f8-4446-9a5e-10f95db28c33`; hubungkan repositori GitHub publik ini agar setiap push otomatis memicu build.
2. Gunakan langkah `Flutter Install` di awal workflow Bitrise, ikuti dengan `Flutter Test` (yang akan menjalankan widget test baru) serta langkah build tambahan sesuai kebutuhan rilis.
3. Jika mengganti branch utama atau token badge, perbarui URL badge pada README sehingga status Bitrise tetap akurat.

## Otomasi Status Tahap

### Cara Kerja
1. Seluruh deliverable tahapan dicatat di `progress.json` lengkap dengan bobot persentase (Tahap I = 20%, Tahap II = 80%) sehingga sesuai daftar “Tahapan dan deliverables”.
2. Mengganti nilai `done` menjadi `true` pada sebuah task menambah progres sesuai bobotnya.
3. Jalankan `python scripts/update_tahap_status.py` setiap kali mengubah `progress.json` untuk memperbarui badge status secara lokal.
4. Workflow `.github/workflows/update-progress.yml` menjalankan skrip yang sama saat ada push ke `main`/`master` (atau ketika dipicu manual melalui `workflow_dispatch`). Jika badge berubah, workflow otomatis membuat commit `chore: update tahap status badge [skip ci]` menggunakan `GITHUB_TOKEN`.

> Instruksi bonus pembuatan video promosi diabaikan sesuai permintaan, sehingga tidak mempengaruhi perhitungan progress.

### Tahap I – 20% (deadline: Senin, 24 November 2025, 23.59 WIB)
| Deliverable | Bobot | Status awal |
| --- | --- | --- |
| Pembuatan GitHub kelompok | 5% | ✅ (`github_repo`) |
| Codebase Flutter kelompok | 5% | ✅ (`codebase`) |
| README lengkap (anggota, deskripsi, modul, peran, alur web service, link Figma) | 5% | ✅ (`readme`) |
| Pengumpulan tautan repo ke SCELE | 5% | ✅ (`submission`) |

Tahap I selesai penuh sehingga menyumbang 20% ke badge.

### Tahap II – 80% (deadline: Minggu, 21 Desember 2025, 23.59 WIB + toleransi 30 menit)
| Deliverable | Bobot | Status awal |
| --- | --- | --- |
| Widget modul Portal Berita (Faiz) | 5% | ✅ (`widget-faiz`) |
| Widget modul Scoreboard (Fadhil) | 15% | ⏳ |
| Widget modul Shop (Edward) | 15% | ⏳ |
| Widget modul Fitur Pencarian (Kadek) | 15% | ⏳ |
| Widget modul Checkout (Dzaki) | 15% | ⏳ |
| Integrasi seluruh modul | 5% | ⏳ |
| Fungsionalitas sesuai desain | 5% | ⏳ |
| Pengolahan JSON web service Django | 3% | ⏳ |
| Menambahkan tautan APK ke README | 1% | ⏳ |
| Presentasi & demo ke dosen | 1% | ⏳ |

Progress awal `Tahap II (25%)` = 20% (Tahap I) + 5% (widget modul Faiz). Saat deliverable lain diselesaikan, badge akan otomatis naik tanpa perlu mengedit README secara manual.
