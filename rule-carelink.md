# rule-carelink.md
# Aturan Arsitektur Sistem — Aplikasi Mobile Ibu CareLink
# Kesehatan Maternal dan Pediatrik

---

## 1. Identitas Proyek

| Atribut | Nilai |
|---|---|
| Nama Aplikasi | Ibu CareLink |
| Platform Target | Flutter (Android & iOS — Cross-Platform) |
| Backend & Database | Firebase (Authentication + Cloud Firestore) |
| State Management | BLoC / Cubit (flutter_bloc) |
| Dependency Injection | GetIt |
| Local Storage | Hive atau SQLite |
| Notifikasi | Firebase Cloud Messaging (FCM) |
| Arsitektur Utama | Clean Architecture + Feature-First Folder Structure |
| Bahasa Pemrograman | Dart |
| Konteks Regulasi | Kementerian Kesehatan RI, IDAI, WHO Growth Standards |

---

## 2. Prinsip Arsitektur Wajib

### 2.1 Clean Architecture — Tiga Lapisan Utama

Seluruh basis kode WAJIB diorganisasi dalam tiga lapisan dengan batas tanggung jawab yang tegas. Ketergantungan kode hanya boleh mengarah ke dalam (inward dependency), tidak boleh ada lapisan luar yang mengimpor lapisan dalam secara terbalik.

| Lapisan | Komponen | Aturan Ketat |
|---|---|---|
| **Presentation** | Widget, BLoC, Cubit, State, Event | DILARANG mengimpor Firebase SDK atau HTTP client secara langsung. Hanya bergantung pada abstraksi Domain Layer. Widget tidak boleh mengandung logika bisnis apapun. |
| **Domain** | Entities, Use Cases, Repository Interfaces | Ditulis dalam Dart murni tanpa referensi ke Flutter UI, Firebase, atau library pihak ketiga apapun. Ini adalah jantung logika medis aplikasi. |
| **Data** | Repository Implementations, Data Models (DTO), Remote & Local Data Sources | Bertugas mengonversi JSON ↔ Dart Object. Berkomunikasi langsung dengan Firestore SDK dan penyimpanan lokal (Hive/SQLite). |

### 2.2 Folder Structure — Feature-First

Setiap fitur utama memiliki struktur lapisan arsitekturnya sendiri secara independen. Struktur ini mencegah konflik merge pada tim besar dan memungkinkan setiap modul dicabut atau diganti tanpa merusak sistem lain.

```
lib/
├── core/
│   ├── di/                  # GetIt service locator registration
│   ├── errors/              # Failure & Exception classes
│   ├── usecases/            # Base UseCase abstract class
│   └── utils/               # Constants, extensions, helpers
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── pregnancy/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── child_growth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── vaccination/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── kick_counter/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── contraction_timer/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── milestones/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── emergency/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

### 2.3 Dependency Injection — GetIt

Seluruh instansiasi objek dikelola secara terpusat melalui GetIt service locator. Urutan pendaftaran WAJIB mengikuti alur berikut tanpa penyimpangan:

```
FirebaseAuth / FirebaseFirestore (Singleton)
    ↓
Remote Data Source & Local Data Source (Singleton)
    ↓
Repository Implementation (Singleton)
    ↓
Use Cases (Factory / Singleton)
    ↓
BLoC / Cubit (Factory — dibuat baru per halaman)
```

Firebase SDK instances (FirebaseAuth, FirebaseFirestore, FirebaseMessaging) WAJIB didaftarkan sebagai singleton agar tidak terjadi inisialisasi ganda yang memboroskan memori.

---

## 3. Alur Interaksi BLoC — Aturan State Machine

### 3.1 Pola Komunikasi Wajib

Setiap interaksi pengguna (tap tombol, input form, dll.) WAJIB dikemas sebagai objek **Event** yang dikirim ke BLoC. BLoC memproses event, memanggil Use Case di Domain Layer, lalu memancarkan **State** baru. Widget hanya bertugas mendengarkan perubahan State melalui `BlocBuilder` atau `BlocListener`.

```
Widget (UI)
    │── dispatch Event ──▶ BLoC
                              │── call Use Case ──▶ Repository Interface
                                                         │── (impl) Remote/Local Data Source
                                                         └── return Either<Failure, Entity>
                              └── emit State ──▶ Widget re-render
```

### 3.2 State Standar per Fitur

Setiap BLoC WAJIB memiliki minimal empat state:

| State | Keterangan |
|---|---|
| `Initial` | State awal sebelum ada interaksi |
| `Loading` | Proses async sedang berjalan |
| `Success<T>` | Operasi berhasil, membawa data entity |
| `Failure` | Operasi gagal, membawa pesan error |

### 3.3 Aturan Khusus Fitur Real-Time

Fitur yang membutuhkan siklus pelacakan aktif (Kick Counter, Contraction Timer) WAJIB dikelola menggunakan **state machine internal BLoC**. Data TIDAK boleh dikirim ke Firestore secara sepotong-sepotong per-event. Keseluruhan sesi baru dikirim sebagai satu dokumen utuh ke Firestore setelah sesi dinyatakan selesai atau dihentikan pengguna.

---

## 4. Pemodelan Basis Data Cloud Firestore

### 4.1 Aturan Struktural Wajib

Firestore mengunduh seluruh isi dokumen setiap kali dokumen diminta. Oleh karena itu berlaku aturan mutlak berikut:

- DILARANG menyimpan array atau map yang terus bertumbuh tanpa batas di dalam satu dokumen tunggal.
- Data historis (log harian, catatan kontraksi, log pertumbuhan) WAJIB disimpan sebagai dokumen individual di dalam subkoleksi, bukan sebagai field array di dokumen induk.
- Arsitektur WAJIB memanfaatkan **shallow query** sehingga pengambilan dokumen induk tidak otomatis mengunduh seluruh subkoleksinya.

### 4.2 Hierarki Koleksi dan Subkoleksi

```
firestore/
│
└── users/                          ← Koleksi Tingkat 1 (Root)
    └── {userId}/                   ← ID dokumen = Firebase Auth UID
        ├── [fields: name, email, createdAt, language, theme]
        │
        ├── pregnancies/            ← Subkoleksi Tingkat 2
        │   └── {pregnancyId}/
        │       ├── [fields: status, estimatedDueDate, prePregnancyWeight, isActive]
        │       │
        │       ├── kick_counts/    ← Subkoleksi Tingkat 3
        │       │   └── {sessionId}/
        │       │       └── [fields: startTime, sessionDuration, totalKicks, isCompleted]
        │       │
        │       ├── contractions/   ← Subkoleksi Tingkat 3
        │       │   └── {contractionId}/
        │       │       └── [fields: startTime, endTime, intervalSeconds, intensityLevel]
        │       │
        │       └── symptom_logs/   ← Subkoleksi Tingkat 3
        │           └── {logId}/
        │               └── [fields: date, nauseaLevel, fatigueLevel, moodNote, triggers]
        │
        └── children/               ← Subkoleksi Tingkat 2
            └── {childId}/
                ├── [fields: name, gender, dateOfBirth, birthWeight, birthLength, childOrder]
                │
                ├── growth_logs/          ← Subkoleksi Tingkat 3
                │   └── {logId}/
                │       └── [fields: measurementDate, weightKg, heightCm, headCircumferenceCm]
                │
                ├── vaccinations/         ← Subkoleksi Tingkat 3
                │   └── {vaccinationId}/
                │       └── [fields: vaccineName, status, scheduledDate, actualDate, batchNumber, nextReminderAt]
                │
                └── developmental_milestones/  ← Subkoleksi Tingkat 3
                    └── {milestoneId}/
                        └── [fields: ageMonths, domain, description, isAchieved, achievedDate]
```

### 4.3 Aturan Kunci Dokumen

Dokumen pada koleksi `users` WAJIB menggunakan Firebase Authentication UID sebagai ID dokumen. Hal ini memungkinkan pengambilan data profil secara instan tanpa query pencarian, sekaligus menjadi landasan validasi aturan keamanan Firestore.

---

## 5. Aturan Keamanan Firestore (Security Rules)

### 5.1 Prinsip Utama

Karena arsitektur Flutter + Firebase memungkinkan klien mengakses Firestore secara langsung tanpa server perantara, Firestore Security Rules adalah **satu-satunya penghalang** antara data privat pengguna dan akses tidak sah. Kegagalan mendefinisikan rules yang benar berpotensi membocorkan data rekam medis ibu dan anak.

### 5.2 User-Based Access Control

Seluruh dokumen di bawah `users/{userId}` dan subkoleksi turunannya HANYA boleh diakses jika kedua kondisi ini terpenuhi secara bersamaan:

1. `request.auth != null` — pengguna sudah terautentikasi.
2. `request.auth.uid == userId` — UID token autentikasi persis sama dengan variabel `{userId}` di path dokumen.

Rules dieksekusi di sisi server Firebase secara atomik sebelum transaksi data diproses, sehingga tidak dapat dielakkan oleh manipulasi kode sisi klien.

### 5.3 Validasi Skema pada Operasi Write

Karena Firestore bersifat schemaless secara bawaan, rules WAJIB bertindak sebagai penjaga gerbang pada setiap operasi `create` dan `update`. Contoh validasi wajib:

| Koleksi | Field yang Divalidasi | Aturan Validasi |
|---|---|---|
| `growth_logs` | `weightKg` | Harus ada (`exists`), bertipe `number`, nilai dalam rentang fisiologis wajar (misal: 0.5 – 300 kg) |
| `growth_logs` | `heightCm` | Harus ada, bertipe `number`, nilai dalam rentang wajar (misal: 30 – 300 cm) |
| `contractions` | `startTime`, `endTime` | Harus ada, bertipe `timestamp`, `endTime > startTime` |
| `kick_counts` | `totalKicks` | Harus ada, bertipe `number`, nilai >= 0 |
| `vaccinations` | `status` | Harus ada, nilai hanya boleh `'completed'` atau `'pending'` |

### 5.4 Catatan Penting Rules

Firestore **tidak menerapkan rules secara menurun berjenjang** untuk evaluasi query (rules are not filters). Rules harus sanggup membuktikan keabsahan akses secara proaktif sebelum query mengunduh dokumen. Hindari pola rules yang bergantung pada struktur data yang belum divalidasi.

---

## 6. Arsitektur Offline-First

### 6.1 Strategi Cache

Setiap kali aplikasi diluncurkan, UI WAJIB dirender dari **local cache terlebih dahulu** menggunakan Hive atau SQLite untuk memastikan antarmuka muncul dalam hitungan milidetik tanpa tergantung pada latensi jaringan. Sinkronisasi ke Firestore berjalan di latar belakang setelah UI sudah ditampilkan.

### 6.2 Operasi Luring Wajib Didukung

Fitur-fitur berikut WAJIB dapat beroperasi penuh meski perangkat sedang offline:

| Fitur | Operasi Luring yang Didukung |
|---|---|
| Kick Counter | Menghitung dan menyimpan sesi tendangan janin ke local storage |
| Symptom Log | Mencatat gejala harian ke local storage |
| Contraction Timer | Merekam sesi kontraksi ke local storage |
| Growth Log Viewing | Membaca data pertumbuhan dari cache |

Sinkronisasi ke Firestore WAJIB dilanjutkan secara otomatis di latar belakang begitu koneksi internet kembali tersedia, menggunakan mekanisme Firestore offline persistence yang sudah tersedia secara native.

---

## 7. Modul Fitur dan Aturan Fungsional

### 7.1 Modul Autentikasi

- Mendukung dua metode login: Email/Password tradisional dan Google Sign-In (OAuth).
- Pasca-autentikasi, sistem menampilkan kuesioner pemrofilan untuk menetapkan status pengguna: **hamil**, **memiliki anak balita**, atau **keduanya**.
- Status awal pengguna disimpan ke Firestore dan digunakan untuk mengkonfigurasi routing adaptif pada dashboard — antarmuka beranda dirender berbeda tergantung profil aktif pengguna.

### 7.2 Modul Kick Counter (Penghitung Tendangan Janin)

- Aktif di Trimester 3 (Pekan 28 hingga persalinan).
- Implementasi **Wake Lock API** wajib diaktifkan agar layar tidak mati selama sesi penghitungan berlangsung.
- Implementasi **Haptic Feedback** wajib diaktifkan sebagai konfirmasi taktil setiap kali ibu mengetuk tombol rekam tendangan, tanpa perlu melihat layar.
- Target medis: 10 ketukan dalam 2 jam. Sistem WAJIB menampilkan peringatan visual jika target tidak tercapai dalam jendela waktu tersebut.
- Seluruh sesi (startTime, totalKicks, sessionDuration, isCompleted) disimpan sebagai satu dokumen ke subkoleksi `kick_counts` setelah sesi selesai.

### 7.3 Modul Contraction Timer (Pengatur Waktu Kontraksi)

- Aktif di Trimester 3.
- BLoC mengelola siklus kontraksi menggunakan **state machine internal** — state: `idle → contractionStarted → contractionEnded → intervalRunning → contractionStarted (loop)`.
- Sistem menghitung: durasi setiap kontraksi dan interval antar kontraksi.
- Sistem memberikan **peringatan visual** berbasis ambang batas klinis: misalnya pola kontraksi 5-1-1 (setiap 5 menit, durasi 1 menit, berlangsung 1 jam) sebagai indikasi untuk segera menuju fasilitas kesehatan.
- Data sesi lengkap dikirim ke Firestore sebagai satu dokumen setelah sesi dihentikan.

### 7.4 Modul Pemantauan Pertumbuhan Anak

- Input wajib per sesi pengukuran: `weightKg` (berat badan), `heightCm` (panjang/tinggi badan), `headCircumferenceCm` (lingkar kepala).
- Algoritma Use Case WAJIB menghitung **Z-Score** berdasarkan tiga indeks WHO:
  - BB/U (Berat Badan terhadap Umur)
  - TB/U (Tinggi Badan terhadap Umur)
  - BB/TB (Berat Badan terhadap Tinggi Badan)
- Kurva pertumbuhan ditampilkan dalam grafik pita warna: hijau (normal), kuning (waspada), merah (perlu intervensi).
- Kurva dasar algoritma WAJIB dibedakan berdasarkan **jenis kelamin biologis** anak sejak profil dibuat.
- Sistem WAJIB memicu notifikasi kewaspadaan medis apabila lintasan grafik memotong garis **-2 SD** ke bawah, menginstruksikan rujukan ke konselor kesehatan.

### 7.5 Modul Jadwal Imunisasi (IDAI 2024)

- Mesin penjadwalan dikonfigurasi berdasarkan **Kalender Imunisasi IDAI 2024**.
- Jadwal dibangun secara dinamis berdasarkan tanggal lahir anak dari profil.
- Notifikasi FCM WAJIB dikirim berminggu-minggu sebelum jendela waktu optimal vaksin.
- Status vaksin hanya boleh bernilai `'completed'` atau `'pending'`.
- Jadwal rujukan sistem per fase:

| Fase Usia | Vaksin yang Dijadwalkan |
|---|---|
| 0 Bulan (Pasca-Lahir) | Hepatitis B Dosis 0, Polio Oral 0, BCG |
| Bulan 2, 3, 4 | DTP, Polio, Hepatitis B, Hib, PCV, Rotavirus (kombinasi Pentavalen direkomendasikan) |
| 6 Bulan | PCV penutup dosis dasar, Rotavirus, Influenza (dosis ganda inisial), HFMD (Flu Singapore — wajib baru 2024) |
| 9 Bulan | MR (Measles-Rubella), Japanese Encephalitis (wilayah rentan) |
| 12 – 18 Bulan | Booster PCV, Varicella, Hepatitis A, Booster DTP, MMR |
| 2 Tahun ke Atas | Tifoid (ulang tiap 3 tahun), Dengue (usia sekolah), HPV (praremaja perempuan) |

### 7.6 Modul Tonggak Perkembangan Anak (Developmental Milestones)

- Checklist bersifat dinamis dan berevolusi sesuai usia kronologis anak.
- Empat domain observasi wajib:
  1. Motorik Kasar dan Halus
  2. Bahasa dan Komunikasi
  3. Adaptasi Sosial-Emosional
  4. Kognitif Abstrak
- Acuan standar: CDC Milestone Tracker dan otoritas pediatrik terkait.
- Apabila tonggak kritis tidak tercapai pada jendela usia yang ditentukan, sistem WAJIB menampilkan peringatan dan mendorong konsultasi ke ahli rehabilitasi pediatrik.

### 7.7 Modul Kedaruratan (Emergency SOS)

- Tombol SOS WAJIB selalu dapat diakses dari antarmuka utama (persistent di semua halaman).
- Saat diaktifkan, alur sistem adalah:
  1. Presentation Layer mengambil koordinat GPS perangkat.
  2. Use Case mengeksekusi pembaruan status kedaruratan berprioritas tinggi ke Firestore.
  3. FCM memicu notifikasi push mendesak ke perangkat anggota keluarga yang terdaftar dan/atau fasilitas layanan kesehatan primer.
- Seluruh transmisi, pencatatan luring, dan pemulihan latensi jaringan WAJIB diimplementasikan agar fitur ini tetap berfungsi dalam kondisi jaringan tidak stabil.

---

## 8. Notifikasi — Firebase Cloud Messaging (FCM)

Seluruh notifikasi dikirim melalui FCM. Jenis notifikasi yang WAJIB diimplementasikan:

| Trigger Notifikasi | Keterangan |
|---|---|
| Konsumsi vitamin prenatal | Pengingat harian terjadwal |
| Jadwal USG / ANC | Sinkronisasi dengan jadwal kunjungan antenatal |
| Parameter pemantauan tidak diperbarui | Notifikasi jika tidak ada update data dalam N hari |
| Jadwal vaksinasi mendekati | Peringatan berminggu-minggu sebelum jendela vaksin |
| Peringatan pertumbuhan anomali | Notifikasi saat Z-score memotong ambang -2 SD |
| Tonggak perkembangan belum tercapai | Peringatan pada milestone kritis yang terlewat |
| Emergency SOS | Notifikasi darurat berprioritas tinggi ke kontak terdaftar |

---

## 9. Parameter Klinis yang Dienkodekan ke Dalam Sistem

### 9.1 Parameter Taksiran Persalinan

Kalkulasi Taksiran Persalinan (HPL) menggunakan **Hukum Naegele** berdasarkan Hari Pertama Haid Terakhir (HPHT), atau dapat di-override dengan data pemindaian USG pertama.

### 9.2 Parameter Antropometri Rujukan (WHO)

Nilai-nilai ini menjadi acuan algoritma evaluasi pertumbuhan anak:

| Usia | Panjang/Tinggi Bayi Laki-Laki | Panjang/Tinggi Bayi Perempuan |
|---|---|---|
| Lahir (0 bulan) | 46,1 – 55,6 cm | 45,4 – 54,7 cm |
| 6 bulan | 63,3 – 71,9 cm | 61,2 – 70,3 cm |
| 12 bulan | 71,0 – 80,5 cm | 68,9 – 79,2 cm |
| 24 bulan | 81,0 – 93,2 cm | 80,0 – 92,9 cm |
| 36 bulan | 88,7 – 103,5 cm | 87,4 – 102,7 cm |
| 60 bulan | 100,7 – 119,2 cm | 99,9 – 118,9 cm |

Catatan: Rentang di atas adalah panduan visual. Algoritma evaluasi internal WAJIB menggunakan kalkulasi Z-score berdasarkan tabel WHO yang dipresisikan, bukan perbandingan rentang sederhana.

### 9.3 Parameter Pemantauan Kehamilan per Trimester

| Trimester | Rentang Pekan | Fitur Aktif |
|---|---|---|
| Trimester 1 | Pekan 1 – 12 | Kalkulasi HPL, symptom log (mual/pola tidur), pengingat asam folat, panduan kunjungan ANC pertama |
| Trimester 2 | Pekan 13 – 27 | Pelacak berat badan berbasis BMI pra-hamil, visualisasi ukuran janin 3D (metafora buah), pencatatan hasil USG anatomi |
| Trimester 3 | Pekan 28 – Persalinan | Kick counter ber-haptik, contraction timer dengan alert klinis, persiapan checklist kelahiran |

---

## 10. Aturan Teknis Tambahan

### 10.1 Serialisasi Data

Setiap Data Model (DTO) WAJIB memiliki dua metode:
- `fromFirestore(Map<String, dynamic> map)` — deserialisasi dari format Firestore.
- `toFirestore()` — serialisasi ke `Map<String, dynamic>` untuk dikirim ke Firestore.

Entitas di Domain Layer TIDAK boleh memiliki metode serialisasi. Konversi antara Entity dan Data Model dilakukan di lapisan Data.

### 10.2 Error Handling

Seluruh operasi async WAJIB mengembalikan tipe `Either<Failure, T>` (menggunakan package `dartz` atau implementasi custom). Use Case tidak boleh melempar exception secara langsung — seluruh error dikemas sebagai objek `Failure` bertipe spesifik.

### 10.3 Unit Testing

Karena Domain Layer ditulis dalam Dart murni tanpa ketergantungan eksternal, seluruh Use Case WAJIB dapat diuji unit secara terisolasi tanpa perlu mocking koneksi Firebase. Ini adalah salah satu keuntungan utama Clean Architecture yang harus dimanfaatkan, terutama untuk validasi presisi algoritma medis (Z-score, kalkulasi HPL, ambang batas kontraksi).

### 10.4 Keamanan Tambahan

- Tidak ada API key atau credential sensitif yang boleh di-hardcode di dalam source code. Gunakan file konfigurasi environment yang dikecualikan dari version control (`.gitignore`).
- Seluruh komunikasi ke Firebase menggunakan koneksi HTTPS secara default (tidak perlu konfigurasi tambahan).
- Token FCM disimpan di Firestore di bawah dokumen pengguna dan dikelola pembaruannya setiap kali token diperbarui oleh Firebase SDK.

---

## 11. Ringkasan Aturan Larangan Mutlak

| No. | Larangan |
|---|---|
| 1 | Widget UI DILARANG mengimpor atau memanggil Firebase SDK secara langsung |
| 2 | Domain Layer DILARANG bergantung pada Flutter framework, Firebase, atau library pihak ketiga apapun |
| 3 | DILARANG menyimpan array/map yang terus bertumbuh tanpa batas dalam satu dokumen Firestore |
| 4 | Data historis (log harian) DILARANG disimpan sebagai field array dalam dokumen induk |
| 5 | Fitur Kick Counter & Contraction Timer DILARANG mengirim data ke Firestore per-event — hanya boleh setelah sesi selesai |
| 6 | Aturan Keamanan Firestore WAJIB ada — tidak boleh ada koleksi yang berjalan tanpa rules |
| 7 | Algoritma evaluasi pertumbuhan WAJIB menggunakan Z-score, BUKAN perbandingan rentang sederhana |
| 8 | API key dan credential Firebase DILARANG di-hardcode dalam source code |
| 9 | BLoC DILARANG mengakses Data Layer secara langsung — harus melalui Use Case di Domain Layer |
| 10 | Tombol SOS DILARANG hanya tersedia di satu halaman — harus persistent dan selalu dapat diakses |

---

*rule-carelink.md — Dokumen ini adalah blueprint arsitektur pra-implementasi untuk tim pengembang Ibu CareLink. Versi ini disusun berdasarkan spesifikasi dokumen desain arsitektur sistem versi awal. Seluruh parameter klinis bersifat referensial dan harus divalidasi ulang dengan profesional medis berlisensi sebelum rilis produksi.*
