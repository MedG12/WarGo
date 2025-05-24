# wargo

WarGo merupakan sebuah platform yang dirancang untuk mendukung pertumbuhan UMKM kuliner lokal dengan menyediakan layanan rekomendasi makanan di toko hingga pedagang asongan sekitar Anda secara cepat dan mudah. Melalui aplikasi ini, pengguna dapat menjelajahi berbagai pilihan kuliner yang tersedia di sekitarnya, melihat menu makanan lengkap beserta harga, hingga mendapatkan petunjuk arah secara langsung menuju lokasi toko yang dipilih. Dengan WarGo, Anda tidak hanya menemukan tempat makan terbaik di sekitar, tetapi juga turut serta dalam membantu pelaku usaha kecil untuk berkembang dan dikenal lebih luas oleh masyarakat. Temukan cita rasa lokal favorit Anda dan dukung UMKM kuliner bersama WarGo!
# User Flow WarGo
1. Onboarding & Autentikasi
   Pengguna membuka aplikasi
   Menampilkan intro singkat tentang WarGo (tujuan mendukung UMKM lokal)
   Opsi:
     - Login (email/nomor HP/akun Google)
     - Daftar (registrasi dengan data dasar)
2. Homepage (Pencarian Cepat)
   Tampilkan rekomendasi UMKM kuliner terdekat berdasarkan lokasi pengguna (GPS).
   Fitur utama:
    - Search Bar: Cari berdasarkan nama warung/makanan.
    - Detail Toko dan jarak berdasarkan lokasi
3. Eksplorasi Menu & Detail UMKM
   Pengguna memilih salah satu UMKM dari daftar/peta.
   Tampilkan:
   - Profil Toko (nama, foto, rating, jam buka).
   - Daftar Menu lengkap dengan harga dan foto.
   - Tombol Arah untuk navigasi rute
5. Real Time Maps
   Pengguna dapat melihat live location pedagang yang terdafatar dalam aplikasi WarGo 
7. Profile Page
   Pengguna dapat mengatur email, username, password dan profile picture

## Getting Started
  This document will guide you through setting up and running the WarGo Flutter project on your local machine. The app uses Firebase Realtime Database, Firebase Storage, and several mapping/location dependencies for   UMKM culinary recommendation.

# 🚀 Prerequisites
  Before you begin, ensure you have the following installed:
  - Flutter SDK (latest stable version)
  - Dart SDK (comes with Flutter)
  - Firebase Account (for backend setup)
  - Android Studio / Xcode (for emulator/simulator)
# 🔧 Firebase Setup
  WarGo uses Firebase Realtime Database and Firebase Storage. Follow these steps:
  1. Create a Firebase Project
  2. Set Up Firebase for Flutter
  3. Enable Firebase Services
     - Realtime Database
     - Firebase Storage
# 🔌 Running the Project
  1. Clone the Repository and install all dependencies
  2. Set Up Environment Variables
     Create a .env file (if used) for Firebase API keys (add to .gitignore).
  3. Run the App
