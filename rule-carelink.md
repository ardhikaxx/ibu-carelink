# rule-carelink.md
# Aturan Arsitektur Sistem — Aplikasi Mobile Ibu CareLink
# Kesehatan Maternal dan Pediatrik
# (Versi Detail — Implementation-Ready)

---

## 1. Identitas Proyek

| Atribut | Nilai |
|---|---|
| Nama Aplikasi | Ibu CareLink |
| Platform Target | Flutter 3.x (Android & iOS — Cross-Platform) |
| Backend & Database | Firebase (Authentication + Cloud Firestore + Cloud Messaging) |
| State Management | BLoC / Cubit (`flutter_bloc`) |
| Dependency Injection | GetIt (`get_it`) |
| Local Storage | Hive (NoSQL key-value, untuk dokumen ringan) atau SQLite (`sqflite`, untuk query relasional log historis) |
| Error Handling | `Either<Failure, T>` via package `dartz` atau implementasi custom |
| Notifikasi | Firebase Cloud Messaging (FCM) + `flutter_local_notifications` untuk reminder terjadwal |
| Routing | `go_router` dengan konfigurasi adaptif berbasis status profil pengguna |
| Arsitektur Utama | Clean Architecture + Feature-First Folder Structure + BLoC Pattern |
| Bahasa Pemrograman | Dart (null-safety wajib aktif) |
| Equality/Value Object | `equatable` (untuk Entity dan State comparison) |
| Code Generation | `freezed` (opsional, untuk Entity/State immutable) + `json_serializable` (untuk DTO) |
| Konteks Regulasi | Kementerian Kesehatan RI, IDAI (Ikatan Dokter Anak Indonesia) 2024, WHO Child Growth Standards, CDC Developmental Milestones |
| Lokal & Bahasa | Bahasa Indonesia sebagai bahasa utama UI, format tanggal `dd MMMM yyyy` (locale `id_ID`) |

### 1.1 Package Inti yang Wajib Ada di `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # Dependency Injection
  get_it: ^7.7.0

  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_messaging: ^15.1.3

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Error Handling
  dartz: ^0.10.1

  # Routing
  go_router: ^14.6.1

  # Hardware API
  wakelock_plus: ^1.2.8
  vibration: ^2.0.0
  geolocator: ^13.0.1

  # Local Notification (reminder terjadwal non-FCM)
  flutter_local_notifications: ^18.0.1

  # Date & Locale
  intl: ^0.19.0

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  bloc_test: ^9.1.7
  mocktail: ^1.0.4
```

---

## 2. Prinsip Arsitektur Wajib — Clean Architecture

### 2.1 Aturan Dependency Rule (Tidak Boleh Dilanggar)

Aturan emas Clean Architecture: **ketergantungan kode hanya boleh mengarah ke dalam**. Lapisan luar (Presentation) boleh mengenal lapisan dalam (Domain), tetapi lapisan dalam TIDAK PERNAH boleh mengenal lapisan luar.

```
┌─────────────────────────────────────────────────┐
│              PRESENTATION LAYER                  │
│   (Widget, BLoC, Cubit, Page, Event, State)      │
│                      │                            │
│                      ▼  depends on                │
│  ┌─────────────────────────────────────────────┐  │
│  │              DOMAIN LAYER                    │  │
│  │  (Entity, UseCase, Repository Interface)     │  │
│  │     ← TIDAK BERGANTUNG PADA APAPUN DI LUAR   │  │
│  └─────────────────────────────────────────────┘  │
│                      ▲  implements                │
│                      │                            │
│                DATA LAYER                         │
│  (Repository Impl, DTO, Remote/Local DataSource)  │
└─────────────────────────────────────────────────┘
```

Validasi arsitektur ini dapat dijalankan otomatis menggunakan package `import_lint` atau custom analyzer rule yang melarang `import 'package:cloud_firestore/...'` di dalam folder `presentation/` dan `domain/`.

### 2.2 Lapisan Presentation — Spesifikasi Detail

**Tanggung jawab:** rendering UI, menangkap input pengguna, mengelola state sesaat (loading/success/error), navigasi.

**Komponen wajib per fitur:**
- `pages/` — halaman penuh (Scaffold-level widget)
- `widgets/` — komponen UI yang dapat dipakai ulang dalam fitur tersebut
- `bloc/` — `*_bloc.dart`, `*_event.dart`, `*_state.dart`

**Aturan ketat:**
1. Widget DILARANG mengandung logika kalkulasi medis (Z-score, interval kontraksi, dll). Logika tersebut wajib berada di Use Case.
2. Widget DILARANG memanggil `FirebaseFirestore.instance` secara langsung.
3. Widget DILARANG memanipulasi struktur data mentah (`Map<String, dynamic>`) — hanya boleh menerima Entity yang sudah diproses.
4. Setiap interaksi pengguna dikemas sebagai Event dan dikirim via `context.read<XBloc>().add(EventName())`.

**Contoh kode — Event:**

```dart
// features/kick_counter/presentation/bloc/kick_counter_event.dart
import 'package:equatable/equatable.dart';

abstract class KickCounterEvent extends Equatable {
  const KickCounterEvent();

  @override
  List<Object?> get props => [];
}

class StartKickSessionRequested extends KickCounterEvent {
  const StartKickSessionRequested();
}

class KickRecorded extends KickCounterEvent {
  const KickRecorded();
}

class EndKickSessionRequested extends KickCounterEvent {
  final String pregnancyId;
  const EndKickSessionRequested({required this.pregnancyId});

  @override
  List<Object?> get props => [pregnancyId];
}
```

**Contoh kode — State:**

```dart
// features/kick_counter/presentation/bloc/kick_counter_state.dart
import 'package:equatable/equatable.dart';

abstract class KickCounterState extends Equatable {
  const KickCounterState();

  @override
  List<Object?> get props => [];
}

class KickCounterInitial extends KickCounterState {}

class KickCounterInProgress extends KickCounterState {
  final int totalKicks;
  final DateTime startTime;
  final Duration elapsed;

  const KickCounterInProgress({
    required this.totalKicks,
    required this.startTime,
    required this.elapsed,
  });

  @override
  List<Object?> get props => [totalKicks, startTime, elapsed];
}

class KickCounterTargetReached extends KickCounterInProgress {
  const KickCounterTargetReached({
    required super.totalKicks,
    required super.startTime,
    required super.elapsed,
  });
}

class KickCounterSaving extends KickCounterState {}

class KickCounterSaveSuccess extends KickCounterState {}

class KickCounterFailure extends KickCounterState {
  final String message;
  const KickCounterFailure(this.message);

  @override
  List<Object?> get props => [message];
}
```

**Contoh kode — BLoC (mengelola Wake Lock, Haptic, dan state machine sesi):**

```dart
// features/kick_counter/presentation/bloc/kick_counter_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:vibration/vibration.dart';
import '../../domain/usecases/save_kick_session.dart';
import '../../domain/entities/kick_session.dart';
import 'kick_counter_event.dart';
import 'kick_counter_state.dart';

class KickCounterBloc extends Bloc<KickCounterEvent, KickCounterState> {
  final SaveKickSession saveKickSession;

  static const int targetKicks = 10;
  static const Duration observationWindow = Duration(hours: 2);

  int _kickCount = 0;
  DateTime? _sessionStart;

  KickCounterBloc({required this.saveKickSession}) : super(KickCounterInitial()) {
    on<StartKickSessionRequested>(_onStart);
    on<KickRecorded>(_onKickRecorded);
    on<EndKickSessionRequested>(_onEndSession);
  }

  Future<void> _onStart(
    StartKickSessionRequested event,
    Emitter<KickCounterState> emit,
  ) async {
    await WakelockPlus.enable(); // layar tidak boleh mati selama sesi
    _kickCount = 0;
    _sessionStart = DateTime.now();
    emit(KickCounterInProgress(
      totalKicks: 0,
      startTime: _sessionStart!,
      elapsed: Duration.zero,
    ));
  }

  Future<void> _onKickRecorded(
    KickRecorded event,
    Emitter<KickCounterState> emit,
  ) async {
    if (_sessionStart == null) return;

    _kickCount++;
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 60); // haptic feedback tanpa perlu lihat layar
    }

    final elapsed = DateTime.now().difference(_sessionStart!);

    if (_kickCount >= targetKicks) {
      emit(KickCounterTargetReached(
        totalKicks: _kickCount,
        startTime: _sessionStart!,
        elapsed: elapsed,
      ));
    } else {
      emit(KickCounterInProgress(
        totalKicks: _kickCount,
        startTime: _sessionStart!,
        elapsed: elapsed,
      ));
    }
  }

  Future<void> _onEndSession(
    EndKickSessionRequested event,
    Emitter<KickCounterState> emit,
  ) async {
    await WakelockPlus.disable();
    emit(KickCounterSaving());

    final session = KickSession(
      startTime: _sessionStart ?? DateTime.now(),
      sessionDuration: DateTime.now().difference(_sessionStart ?? DateTime.now()),
      totalKicks: _kickCount,
      isCompleted: _kickCount >= targetKicks,
    );

    final result = await saveKickSession(
      SaveKickSessionParams(pregnancyId: event.pregnancyId, session: session),
    );

    result.fold(
      (failure) => emit(KickCounterFailure(failure.message)),
      (_) => emit(KickCounterSaveSuccess()),
    );

    _kickCount = 0;
    _sessionStart = null;
  }

  @override
  Future<void> close() {
    WakelockPlus.disable();
    return super.close();
  }
}
```

> **Catatan arsitektur penting:** BLoC di atas TIDAK mengimpor `cloud_firestore` sama sekali. Satu-satunya ketergantungan eksternal adalah `wakelock_plus` dan `vibration` — keduanya adalah API hardware-level yang secara sah berada di Presentation Layer karena berkaitan langsung dengan pengalaman UI real-time, bukan logika bisnis atau penyimpanan data.

---

## 3. Lapisan Domain — Spesifikasi Detail

**Tanggung jawab:** mendefinisikan aturan bisnis medis murni, independen dari framework apapun.

### 3.1 Entity

Entity adalah representasi objek inti bisnis. Ditulis sebagai Plain Dart Object (POJO), tidak punya method `toJson`/`fromJson`.

```dart
// features/kick_counter/domain/entities/kick_session.dart
import 'package:equatable/equatable.dart';

class KickSession extends Equatable {
  final String? id;
  final DateTime startTime;
  final Duration sessionDuration;
  final int totalKicks;
  final bool isCompleted;

  const KickSession({
    this.id,
    required this.startTime,
    required this.sessionDuration,
    required this.totalKicks,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [id, startTime, sessionDuration, totalKicks, isCompleted];
}
```

```dart
// features/child_growth/domain/entities/growth_log.dart
import 'package:equatable/equatable.dart';

enum GrowthZone { green, yellow, red }

class GrowthLog extends Equatable {
  final String? id;
  final DateTime measurementDate;
  final double weightKg;
  final double heightCm;
  final double headCircumferenceCm;
  final double weightForAgeZScore;
  final double heightForAgeZScore;
  final double weightForHeightZScore;
  final GrowthZone zone;

  const GrowthLog({
    this.id,
    required this.measurementDate,
    required this.weightKg,
    required this.heightCm,
    required this.headCircumferenceCm,
    required this.weightForAgeZScore,
    required this.heightForAgeZScore,
    required this.weightForHeightZScore,
    required this.zone,
  });

  @override
  List<Object?> get props => [
        id,
        measurementDate,
        weightKg,
        heightCm,
        headCircumferenceCm,
        weightForAgeZScore,
        heightForAgeZScore,
        weightForHeightZScore,
        zone,
      ];
}
```

### 3.2 Repository Interface (Kontrak Abstrak)

```dart
// features/child_growth/domain/repositories/growth_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/growth_log.dart';
import '../entities/child_profile.dart';

abstract class GrowthRepository {
  Future<Either<Failure, void>> addGrowthLog({
    required String childId,
    required GrowthLog log,
  });

  Future<Either<Failure, List<GrowthLog>>> getGrowthLogs({
    required String childId,
  });

  Stream<Either<Failure, List<GrowthLog>>> watchGrowthLogs({
    required String childId,
  });

  Future<Either<Failure, ChildProfile>> getChildProfile({
    required String childId,
  });
}
```

### 3.3 Use Case

Setiap Use Case mengenkapsulasi **satu** aksi bisnis spesifik. Mengikuti kontrak `UseCase<Type, Params>` agar konsisten di seluruh aplikasi.

```dart
// core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
```

**Use Case — Kalkulasi Z-Score Pertumbuhan Anak (logika medis inti):**

```dart
// features/child_growth/domain/usecases/calculate_growth_zscore.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/growth_log.dart';
import '../entities/child_profile.dart';
import '../services/who_growth_standard_service.dart';

class CalculateGrowthZScoreParams {
  final ChildProfile child;
  final double weightKg;
  final double heightCm;
  final double headCircumferenceCm;
  final DateTime measurementDate;

  const CalculateGrowthZScoreParams({
    required this.child,
    required this.weightKg,
    required this.heightCm,
    required this.headCircumferenceCm,
    required this.measurementDate,
  });
}

/// Use Case murni Dart — tidak bergantung Firebase, tidak bergantung Flutter.
/// Dapat diuji unit tanpa mocking apapun selain WhoGrowthStandardService
/// yang juga murni Dart (lookup table statis).
class CalculateGrowthZScore implements UseCase<GrowthLog, CalculateGrowthZScoreParams> {
  final WhoGrowthStandardService whoStandard;

  const CalculateGrowthZScore(this.whoStandard);

  @override
  Future<Either<Failure, GrowthLog>> call(
    CalculateGrowthZScoreParams params,
  ) async {
    final ageInMonths = _calculateAgeInMonths(
      params.child.dateOfBirth,
      params.measurementDate,
    );

    if (ageInMonths < 0) {
      return const Left(ValidationFailure('Tanggal pengukuran tidak valid.'));
    }

    final waz = whoStandard.calculateWeightForAgeZScore(
      gender: params.child.gender,
      ageInMonths: ageInMonths,
      weightKg: params.weightKg,
    );

    final haz = whoStandard.calculateHeightForAgeZScore(
      gender: params.child.gender,
      ageInMonths: ageInMonths,
      heightCm: params.heightCm,
    );

    final whz = whoStandard.calculateWeightForHeightZScore(
      gender: params.child.gender,
      heightCm: params.heightCm,
      weightKg: params.weightKg,
    );

    final zone = _determineZone(waz, haz, whz);

    return Right(GrowthLog(
      measurementDate: params.measurementDate,
      weightKg: params.weightKg,
      heightCm: params.heightCm,
      headCircumferenceCm: params.headCircumferenceCm,
      weightForAgeZScore: waz,
      heightForAgeZScore: haz,
      weightForHeightZScore: whz,
      zone: zone,
    ));
  }

  int _calculateAgeInMonths(DateTime dob, DateTime measurementDate) {
    int months = (measurementDate.year - dob.year) * 12 +
        (measurementDate.month - dob.month);
    if (measurementDate.day < dob.day) months--;
    return months;
  }

  GrowthZone _determineZone(double waz, double haz, double whz) {
    final scores = [waz, haz, whz];
    if (scores.any((z) => z < -3)) return GrowthZone.red;
    if (scores.any((z) => z < -2)) return GrowthZone.red;
    if (scores.any((z) => z < -1)) return GrowthZone.yellow;
    return GrowthZone.green;
  }
}
```

**Use Case — Kalkulasi Taksiran Persalinan (Hukum Naegele):**

```dart
// features/pregnancy/domain/usecases/calculate_due_date.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

class CalculateDueDateParams {
  final DateTime lastMenstrualPeriod;
  final int averageCycleLength; // default 28 hari

  const CalculateDueDateParams({
    required this.lastMenstrualPeriod,
    this.averageCycleLength = 28,
  });
}

/// Implementasi Hukum Naegele: HPL = HPHT + 280 hari,
/// disesuaikan dengan deviasi panjang siklus menstruasi dari 28 hari standar.
class CalculateDueDate implements UseCase<DateTime, CalculateDueDateParams> {
  @override
  Future<Either<Failure, DateTime>> call(CalculateDueDateParams params) async {
    if (params.lastMenstrualPeriod.isAfter(DateTime.now())) {
      return const Left(
        ValidationFailure('Tanggal HPHT tidak boleh di masa depan.'),
      );
    }

    final cycleAdjustment = params.averageCycleLength - 28;
    final dueDate = params.lastMenstrualPeriod
        .add(const Duration(days: 280))
        .add(Duration(days: cycleAdjustment));

    return Right(dueDate);
  }
}
```

**Use Case — Evaluasi Pola Kontraksi Persalinan Aktif (5-1-1 Rule):**

```dart
// features/contraction_timer/domain/usecases/evaluate_labor_pattern.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/contraction.dart';

enum LaborStatus { earlyLabor, activeLabor, goToHospital }

class EvaluateLaborPatternParams {
  final List<Contraction> recentContractions;
  const EvaluateLaborPatternParams(this.recentContractions);
}

/// Mengevaluasi pola 5-1-1: kontraksi setiap 5 menit,
/// berdurasi 1 menit, konsisten selama 1 jam — indikasi klinis
/// untuk segera menuju fasilitas kesehatan.
class EvaluateLaborPattern implements UseCase<LaborStatus, EvaluateLaborPatternParams> {
  @override
  Future<Either<Failure, LaborStatus>> call(
    EvaluateLaborPatternParams params,
  ) async {
    final contractions = params.recentContractions;
    if (contractions.length < 4) {
      return const Right(LaborStatus.earlyLabor);
    }

    final lastHour = contractions.where((c) =>
        DateTime.now().difference(c.startTime) <= const Duration(hours: 1));

    if (lastHour.length < 6) {
      return const Right(LaborStatus.earlyLabor);
    }

    final sorted = lastHour.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    bool matchesPattern = true;
    for (int i = 1; i < sorted.length; i++) {
      final interval = sorted[i].startTime.difference(sorted[i - 1].startTime);
      final duration = sorted[i - 1].endTime.difference(sorted[i - 1].startTime);

      final intervalOk = interval <= const Duration(minutes: 5, seconds: 30);
      final durationOk = duration >= const Duration(seconds: 45);

      if (!intervalOk || !durationOk) {
        matchesPattern = false;
        break;
      }
    }

    return Right(matchesPattern ? LaborStatus.goToHospital : LaborStatus.activeLabor);
  }
}
```

---

## 4. Lapisan Data — Spesifikasi Detail

**Tanggung jawab:** implementasi konkret kontrak Repository, konversi JSON↔Entity, eksekusi CRUD aktual ke Firestore dan storage lokal.

### 4.1 Data Transfer Object (DTO / Model)

Model adalah ekstensi dari Entity yang dilengkapi method serialisasi. Entity TIDAK PERNAH tahu tentang format JSON — hanya Model yang tahu.

```dart
// features/child_growth/data/models/growth_log_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/growth_log.dart';

class GrowthLogModel extends GrowthLog {
  const GrowthLogModel({
    super.id,
    required super.measurementDate,
    required super.weightKg,
    required super.heightCm,
    required super.headCircumferenceCm,
    required super.weightForAgeZScore,
    required super.heightForAgeZScore,
    required super.weightForHeightZScore,
    required super.zone,
  });

  factory GrowthLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GrowthLogModel(
      id: doc.id,
      measurementDate: (data['measurementDate'] as Timestamp).toDate(),
      weightKg: (data['weightKg'] as num).toDouble(),
      heightCm: (data['heightCm'] as num).toDouble(),
      headCircumferenceCm: (data['headCircumferenceCm'] as num).toDouble(),
      weightForAgeZScore: (data['weightForAgeZScore'] as num).toDouble(),
      heightForAgeZScore: (data['heightForAgeZScore'] as num).toDouble(),
      weightForHeightZScore: (data['weightForHeightZScore'] as num).toDouble(),
      zone: GrowthZone.values.firstWhere(
        (e) => e.name == data['zone'],
        orElse: () => GrowthZone.green,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'measurementDate': Timestamp.fromDate(measurementDate),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'headCircumferenceCm': headCircumferenceCm,
      'weightForAgeZScore': weightForAgeZScore,
      'heightForAgeZScore': heightForAgeZScore,
      'weightForHeightZScore': weightForHeightZScore,
      'zone': zone.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory GrowthLogModel.fromEntity(GrowthLog entity) {
    return GrowthLogModel(
      id: entity.id,
      measurementDate: entity.measurementDate,
      weightKg: entity.weightKg,
      heightCm: entity.heightCm,
      headCircumferenceCm: entity.headCircumferenceCm,
      weightForAgeZScore: entity.weightForAgeZScore,
      heightForAgeZScore: entity.heightForAgeZScore,
      weightForHeightZScore: entity.weightForHeightZScore,
      zone: entity.zone,
    );
  }
}
```

### 4.2 Remote Data Source

```dart
// features/child_growth/data/datasources/growth_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/growth_log_model.dart';

abstract class GrowthRemoteDataSource {
  Future<void> addGrowthLog({required String userId, required String childId, required GrowthLogModel log});
  Future<List<GrowthLogModel>> getGrowthLogs({required String userId, required String childId});
  Stream<List<GrowthLogModel>> watchGrowthLogs({required String userId, required String childId});
}

class GrowthRemoteDataSourceImpl implements GrowthRemoteDataSource {
  final FirebaseFirestore firestore;

  GrowthRemoteDataSourceImpl({required this.firestore});

  CollectionReference _growthLogsRef(String userId, String childId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('children')
        .doc(childId)
        .collection('growth_logs');
  }

  @override
  Future<void> addGrowthLog({
    required String userId,
    required String childId,
    required GrowthLogModel log,
  }) async {
    try {
      await _growthLogsRef(userId, childId).add(log.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Gagal menyimpan data pertumbuhan');
    }
  }

  @override
  Future<List<GrowthLogModel>> getGrowthLogs({
    required String userId,
    required String childId,
  }) async {
    try {
      final snapshot = await _growthLogsRef(userId, childId)
          .orderBy('measurementDate', descending: true)
          .get();
      return snapshot.docs.map((doc) => GrowthLogModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Gagal mengambil data pertumbuhan');
    }
  }

  @override
  Stream<List<GrowthLogModel>> watchGrowthLogs({
    required String userId,
    required String childId,
  }) {
    return _growthLogsRef(userId, childId)
        .orderBy('measurementDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => GrowthLogModel.fromFirestore(d)).toList());
  }
}
```

### 4.3 Local Data Source (Offline-First Cache)

```dart
// features/child_growth/data/datasources/growth_local_datasource.dart
import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/growth_log_model.dart';

abstract class GrowthLocalDataSource {
  Future<void> cacheGrowthLogs(String childId, List<GrowthLogModel> logs);
  Future<List<GrowthLogModel>> getCachedGrowthLogs(String childId);
}

class GrowthLocalDataSourceImpl implements GrowthLocalDataSource {
  final Box hiveBox;

  GrowthLocalDataSourceImpl({required this.hiveBox});

  @override
  Future<void> cacheGrowthLogs(String childId, List<GrowthLogModel> logs) async {
    try {
      final jsonList = logs.map((l) => l.toFirestore()).toList();
      await hiveBox.put('growth_logs_$childId', jsonList);
    } catch (e) {
      throw CacheException('Gagal menyimpan cache lokal pertumbuhan');
    }
  }

  @override
  Future<List<GrowthLogModel>> getCachedGrowthLogs(String childId) async {
    final cached = hiveBox.get('growth_logs_$childId');
    if (cached == null) throw CacheException('Cache tidak ditemukan');
    // parsing manual karena Hive tidak menyimpan DocumentSnapshot
    return (cached as List).map((e) => GrowthLogModel(
          measurementDate: e['measurementDate'],
          weightKg: e['weightKg'],
          heightCm: e['heightCm'],
          headCircumferenceCm: e['headCircumferenceCm'],
          weightForAgeZScore: e['weightForAgeZScore'],
          heightForAgeZScore: e['heightForAgeZScore'],
          weightForHeightZScore: e['weightForHeightZScore'],
          zone: GrowthZone.values.firstWhere((z) => z.name == e['zone']),
        )).toList();
  }
}
```

### 4.4 Repository Implementation — Menjahit Remote + Local

```dart
// features/child_growth/data/repositories/growth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/growth_log.dart';
import '../../domain/repositories/growth_repository.dart';
import '../datasources/growth_remote_datasource.dart';
import '../datasources/growth_local_datasource.dart';
import '../models/growth_log_model.dart';

class GrowthRepositoryImpl implements GrowthRepository {
  final GrowthRemoteDataSource remoteDataSource;
  final GrowthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final FirebaseAuth firebaseAuth;

  GrowthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.firebaseAuth,
  });

  String get _uid => firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, void>> addGrowthLog({
    required String childId,
    required GrowthLog log,
  }) async {
    final model = GrowthLogModel.fromEntity(log);
    try {
      // Offline-first: tulis lokal lebih dulu agar UI responsif,
      // lalu sinkron ke remote jika ada koneksi.
      if (await networkInfo.isConnected) {
        await remoteDataSource.addGrowthLog(userId: _uid, childId: childId, log: model);
        return const Right(null);
      } else {
        // Antrekan untuk sinkronisasi nanti (lihat 6.3 Sync Queue)
        await localDataSource.cacheGrowthLogs(childId, [model]);
        return const Right(null);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<GrowthLog>>> getGrowthLogs({
    required String childId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteLogs = await remoteDataSource.getGrowthLogs(userId: _uid, childId: childId);
        await localDataSource.cacheGrowthLogs(childId, remoteLogs);
        return Right(remoteLogs);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cachedLogs = await localDataSource.getCachedGrowthLogs(childId);
        return Right(cachedLogs);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Stream<Either<Failure, List<GrowthLog>>> watchGrowthLogs({required String childId}) {
    return remoteDataSource.watchGrowthLogs(userId: _uid, childId: childId).map(
          (logs) => Right<Failure, List<GrowthLog>>(logs),
        );
  }

  @override
  Future<Either<Failure, ChildProfile>> getChildProfile({required String childId}) {
    // implementasi serupa — dipersingkat untuk keterbacaan dokumen
    throw UnimplementedError();
  }
}
```

### 4.5 WHO Growth Standard Service — Lookup Table Z-Score

Service ini berada di Domain Layer (`domain/services/`) karena murni berisi tabel referensi dan formula matematis tanpa dependency eksternal apapun — bukan implementasi infrastruktur.

```dart
// features/child_growth/domain/services/who_growth_standard_service.dart
enum ChildGender { male, female }

/// Implementasi sederhana kalkulasi Z-score menggunakan formula LMS
/// (Lambda-Mu-Sigma) yang menjadi standar WHO Child Growth Standards.
/// L, M, S diambil dari tabel referensi resmi WHO per usia & gender.
class WhoGrowthStandardService {
  // Tabel LMS Berat-Badan-untuk-Umur (subset contoh — produksi WAJIB
  // memuat tabel lengkap 0-60 bulan per bulan dari data resmi WHO).
  static const Map<int, Map<String, double>> _weightForAgeLMS = {
    // ageMonths: {L, M, S} — contoh untuk laki-laki
    0: {'L': 0.3487, 'M': 3.3464, 'S': 0.14602},
    6: {'L': 0.0402, 'M': 7.9341, 'S': 0.12619},
    12: {'L': -0.1733, 'M': 9.6479, 'S': 0.11790},
    24: {'L': -0.5754, 'M': 12.1515, 'S': 0.11645},
  };

  double calculateWeightForAgeZScore({
    required ChildGender gender,
    required int ageInMonths,
    required double weightKg,
  }) {
    final lms = _lookupLMS(_weightForAgeLMS, ageInMonths);
    return _calculateLMSZScore(
      value: weightKg,
      l: lms['L']!,
      m: lms['M']!,
      s: lms['S']!,
    );
  }

  double calculateHeightForAgeZScore({
    required ChildGender gender,
    required int ageInMonths,
    required double heightCm,
  }) {
    // Tabel LMS Tinggi-untuk-Umur — struktur identik, nilai berbeda.
    final lms = _lookupLMS(_weightForAgeLMS, ageInMonths); // placeholder tabel
    return _calculateLMSZScore(value: heightCm, l: lms['L']!, m: lms['M']!, s: lms['S']!);
  }

  double calculateWeightForHeightZScore({
    required ChildGender gender,
    required double heightCm,
    required double weightKg,
  }) {
    // BB/TB menggunakan tabel referensi berbasis tinggi, bukan usia.
    // Implementasi produksi: interpolasi tabel WHO weight-for-length/height.
    const l = -0.3521, m = 13.0, s = 0.1200; // contoh placeholder
    return _calculateLMSZScore(value: weightKg, l: l, m: m, s: s);
  }

  /// Formula resmi WHO LMS:
  /// Z = ((X/M)^L - 1) / (L * S)   jika L != 0
  /// Z = ln(X/M) / S               jika L == 0
  double _calculateLMSZScore({
    required double value,
    required double l,
    required double m,
    required double s,
  }) {
    if (l == 0) {
      return (value / m).abs() > 0 ? (_ln(value / m) / s) : 0;
    }
    return ((_pow(value / m, l)) - 1) / (l * s);
  }

  double _pow(double base, double exponent) {
    if (base <= 0) return 0;
    return _exp(exponent * _ln(base));
  }

  double _ln(double x) => x > 0 ? (x == 1 ? 0 : _naturalLog(x)) : 0;
  double _naturalLog(double x) {
    // Implementasi produksi: gunakan dart:math log(x)
    return x; // placeholder — gunakan import 'dart:math' as math; math.log(x)
  }
  double _exp(double x) => x; // placeholder — gunakan math.exp(x)

  Map<String, double> _lookupLMS(Map<int, Map<String, double>> table, int ageMonths) {
    if (table.containsKey(ageMonths)) return table[ageMonths]!;

    // Interpolasi linear antara dua titik usia terdekat jika data
    // bulan eksak tidak tersedia di tabel.
    final keys = table.keys.toList()..sort();
    int lower = keys.first;
    int upper = keys.last;
    for (int i = 0; i < keys.length - 1; i++) {
      if (ageMonths >= keys[i] && ageMonths <= keys[i + 1]) {
        lower = keys[i];
        upper = keys[i + 1];
        break;
      }
    }
    if (lower == upper) return table[lower]!;

    final ratio = (ageMonths - lower) / (upper - lower);
    final lowerLMS = table[lower]!;
    final upperLMS = table[upper]!;

    return {
      'L': lowerLMS['L']! + (upperLMS['L']! - lowerLMS['L']!) * ratio,
      'M': lowerLMS['M']! + (upperLMS['M']! - lowerLMS['M']!) * ratio,
      'S': lowerLMS['S']! + (upperLMS['S']! - lowerLMS['S']!) * ratio,
    };
  }
}
```

> **Catatan implementasi produksi:** Tabel LMS di atas hanyalah contoh struktural dengan beberapa titik data. Untuk produksi, WAJIB mengimpor tabel lengkap resmi WHO (tersedia sebagai file CSV/JSON di situs WHO Child Growth Standards) yang mencakup setiap bulan usia 0–60 dari masing-masing tiga indeks (BB/U, TB/U, BB/TB) terpisah untuk laki-laki dan perempuan. Gunakan `import 'dart:math' as math;` untuk fungsi `log()` dan `pow()` asli, bukan placeholder di atas.

### 4.6 Unit Test untuk Use Case (Domain Layer murni — tanpa mocking Firebase)

```dart
// test/features/pregnancy/domain/usecases/calculate_due_date_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:carelink/features/pregnancy/domain/usecases/calculate_due_date.dart';

void main() {
  late CalculateDueDate usecase;

  setUp(() {
    usecase = CalculateDueDate();
  });

  test('harus mengembalikan HPL tepat 280 hari untuk siklus 28 hari standar', async () {
    final hpht = DateTime(2026, 1, 1);
    final result = await usecase(CalculateDueDateParams(lastMenstrualPeriod: hpht));

    result.fold(
      (failure) => fail('Tidak boleh gagal'),
      (dueDate) => expect(dueDate, DateTime(2026, 1, 1).add(const Duration(days: 280))),
    );
  });

  test('harus menyesuaikan HPL untuk siklus 32 hari (lebih panjang dari 28)', async () {
    final hpht = DateTime(2026, 1, 1);
    final result = await usecase(
      CalculateDueDateParams(lastMenstrualPeriod: hpht, averageCycleLength: 32),
    );

    result.fold(
      (failure) => fail('Tidak boleh gagal'),
      (dueDate) => expect(
        dueDate,
        DateTime(2026, 1, 1).add(const Duration(days: 284)), // +4 hari dari deviasi siklus
      ),
    );
  });

  test('harus mengembalikan Failure jika HPHT di masa depan', async () {
    final futureDate = DateTime.now().add(const Duration(days: 10));
    final result = await usecase(CalculateDueDateParams(lastMenstrualPeriod: futureDate));

    expect(result.isLeft(), true);
  });
}
```

---

## 5. Skema Lengkap Cloud Firestore

Seksi ini mendefinisikan setiap field, tipe data, dan aturan validasi per koleksi secara ekshaustif. Seluruh field bertanda `*` adalah wajib (required) saat dokumen dibuat.

### 5.1 Koleksi `users/{userId}`

| Field | Tipe Firestore | Wajib | Keterangan |
|---|---|---|---|
| `fullName` | `string` | * | Nama lengkap pengguna |
| `email` | `string` | * | Diambil dari Firebase Auth saat registrasi |
| `photoUrl` | `string` \| `null` | | URL foto profil (Firebase Storage) |
| `language` | `string` | * | Default `'id'` |
| `themePreference` | `string` | | `'light'` \| `'dark'` \| `'system'` |
| `profileType` | `string` | * | `'pregnant'` \| `'has_children'` \| `'both'` |
| `fcmToken` | `string` \| `null` | | Token device aktif untuk push notification |
| `createdAt` | `timestamp` | * | `FieldValue.serverTimestamp()` saat dibuat |
| `updatedAt` | `timestamp` | * | Diperbarui setiap kali profil diubah |
| `emergencyContacts` | `array<map>` | | Daftar kontak darurat: `[{name, phone, relation}]` — dibatasi maksimal 5 entri agar dokumen tetap ringan |

### 5.2 Subkoleksi `users/{userId}/pregnancies/{pregnancyId}`

| Field | Tipe Firestore | Wajib | Keterangan |
|---|---|---|---|
| `isActive` | `boolean` | * | Hanya satu dokumen boleh `true` per user pada satu waktu |
| `lastMenstrualPeriod` | `timestamp` | * | HPHT — basis kalkulasi Naegele |
| `estimatedDueDate` | `timestamp` | * | Hasil kalkulasi `CalculateDueDate` Use Case |
| `averageCycleLength` | `number` | | Default `28` |
| `prePregnancyWeightKg` | `number` | * | Basis kalkulasi BMI |
| `prePregnancyHeightCm` | `number` | * | Basis kalkulasi BMI |
| `currentTrimester` | `number` | * | `1`, `2`, atau `3` — dihitung ulang otomatis tiap query |
| `bloodType` | `string` | | Opsional, untuk konteks medis darurat |
| `riskFlags` | `array<string>` | | Misal `['gestational_diabetes_risk', 'hypertension_risk']` |
| `createdAt` | `timestamp` | * | |
| `endedAt` | `timestamp` \| `null` | | Diisi saat kehamilan berakhir (lahir/keguguran) |

### 5.3 Subkoleksi `.../pregnancies/{id}/kick_counts/{sessionId}`

| Field | Tipe Firestore | Wajib | Keterangan |
|---|---|---|---|
| `startTime` | `timestamp` | * | |
| `sessionDurationSeconds` | `number` | * | Durasi sesi dalam detik |
| `totalKicks` | `number` | * | Harus `>= 0` |
| `isCompleted` | `boolean` | * | `true` jika `totalKicks >= 10` |
| `createdAt` | `timestamp` | * | `serverTimestamp()` |

### 5.4 Subkoleksi `.../pregnancies/{id}/contractions/{contractionId}`

| Field | Tipe Firestore | Wajib | Keterangan |
|---|---|---|---|
| `startTime` | `timestamp` | * | |
| `endTime` | `timestamp` | * | Harus `> startTime` |
| `intensityLevel` | `string` | | `'mild'` \| `'moderate'` \| `'strong'` |
| `createdAt` | `timestamp` | * | |

### 5.5 Subkoleksi `.../pregnancies/{id}/symptom_logs/{logId}`

| Field | Tipe Firestore | Wajib | Keterangan |
|---|---|---|---|
| `date` | `timestamp` | * | Tanggal pencatatan (per hari, bukan per waktu) |
| `nauseaLevel` | `number` | | Skala `0–5` |
| `fatigueLevel` | `number` | | Skala `0–5` |
| `moodNote` | `string` | | Catatan bebas suasana hati |
| `triggers` | `array<string>` | | Faktor pemicu, misal `['makanan_pedas', 'kurang_tidur']` |
| `createdAt` | `timestamp` | * | |

### 5.6 Subkoleksi `users/{userId}/children/{childId}`

| Field | Tipe Firestore | Wajib | Keterangan |
|---|---|---|---|
| `fullName` | `string` | * | |
| `gender` | `string` | * | `'male'` \| `'female'` — menentukan tabel WHO yang digunakan |
| `dateOfBirth` | `timestamp` | * | Basis seluruh kalkulasi usia |
| `birthWeightKg` | `number` | | |
| `birthLengthCm` | `number` | | |
| `childOrder` | `number` | | Anak ke-berapa dalam keluarga |
| `photoUrl` | `string` \| `null` | | |
| `createdAt` | `timestamp` | * | |

### 5.7 Subkoleksi `.../children/{id}/growth_logs/{logId}`

| Field | Tipe Firestore | Wajib | Keterangan |
|---|---|---|---|
| `measurementDate` | `timestamp` | * | |
| `weightKg` | `number` | * | Rentang valid: `0.5 – 80` |
| `heightCm` | `number` | * | Rentang valid: `30 – 150` |
| `headCircumferenceCm` | `number` | * | Rentang valid: `25 – 60` |
| `weightForAgeZScore` | `number` | * | Hasil kalkulasi, disimpan untuk histori grafik tanpa rekalkulasi |
| `heightForAgeZScore` | `number` | * | |
| `weightForHeightZScore` | `number` | * | |
| `zone` | `string` | * | `'green'` \| `'yellow'` \| `'red'` |
| `createdAt` | `timestamp` | * | |

### 5.8 Subkoleksi `.../children/{id}/vaccinations/{vaccinationId}`

| Field | Tipe Firestore | Wajib | Keterangan |
|---|---|---|---|
| `vaccineName` | `string` | * | Misal `'Hepatitis B-0'`, `'DTP-1'`, `'MR'` |
| `status` | `string` | * | Hanya `'completed'` atau `'pending'` |
| `scheduledDate` | `timestamp` | * | Tanggal jatuh tempo sesuai jadwal IDAI |
| `actualDate` | `timestamp` \| `null` | | Diisi saat status berubah ke `'completed'` |
| `batchNumber` | `string` \| `null` | | Nomor batch vaksin (untuk traceability) |
| `administeredAt` | `string` \| `null` | | Nama fasilitas kesehatan tempat vaksinasi diberikan |
| `nextReminderAt` | `timestamp` \| `null` | | Untuk trigger FCM beberapa minggu sebelum jatuh tempo |
| `createdAt` | `timestamp` | * | |

### 5.9 Subkoleksi `.../children/{id}/developmental_milestones/{milestoneId}`

| Field | Tipe Firestore | Wajib | Keterangan |
|---|---|---|---|
| `ageMonths` | `number` | * | Usia checklist ini relevan |
| `domain` | `string` | * | `'gross_motor'` \| `'fine_motor'` \| `'language'` \| `'social_emotional'` \| `'cognitive'` |
| `description` | `string` | * | Deskripsi tonggak, misal "Mampu tersenyum sosial" |
| `isAchieved` | `boolean` | * | Default `false` |
| `achievedDate` | `timestamp` \| `null` | | Diisi saat orang tua menandai tercapai |
| `source` | `string` | | Referensi standar, misal `'CDC'` |

### 5.10 Koleksi `users/{userId}/emergency_alerts/{alertId}`

| Field | Tipe Firestore | Wajib | Keterangan |
|---|---|---|---|
| `triggeredAt` | `timestamp` | * | |
| `latitude` | `number` | * | |
| `longitude` | `number` | * | |
| `status` | `string` | * | `'active'` \| `'resolved'` \| `'false_alarm'` |
| `notifiedContacts` | `array<string>` | | Daftar nomor/UID kontak yang berhasil dinotifikasi |
| `resolvedAt` | `timestamp` \| `null` | | |

---

## 6. Firestore Security Rules — Implementasi Lengkap

Berikut implementasi penuh dalam sintaks CEL (Common Expression Language) yang WAJIB diterapkan di `firestore.rules`. Setiap koleksi memiliki rule eksplisit — TIDAK ADA wildcard rule yang longgar.

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // ────────────────────────────────────────────────
    // FUNGSI HELPER — Direkomendasikan untuk menghindari
    // duplikasi logika di seluruh rules
    // ────────────────────────────────────────────────
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    function isValidNumber(value, min, max) {
      return value is number && value >= min && value <= max;
    }

    // ────────────────────────────────────────────────
    // KOLEKSI: users/{userId}
    // ────────────────────────────────────────────────
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isOwner(userId)
                    && request.resource.data.keys().hasAll(['fullName', 'email', 'language', 'profileType'])
                    && request.resource.data.fullName is string
                    && request.resource.data.email is string
                    && request.resource.data.profileType in ['pregnant', 'has_children', 'both'];
      allow update: if isOwner(userId)
                    && request.resource.data.profileType in ['pregnant', 'has_children', 'both'];
      allow delete: if false; // penghapusan akun WAJIB melalui Cloud Function khusus, bukan client langsung

      // ────────────────────────────────────────────
      // SUBKOLEKSI: pregnancies/{pregnancyId}
      // ────────────────────────────────────────────
      match /pregnancies/{pregnancyId} {
        allow read: if isOwner(userId);
        allow create: if isOwner(userId)
                      && request.resource.data.keys().hasAll(['lastMenstrualPeriod', 'estimatedDueDate', 'prePregnancyWeightKg'])
                      && request.resource.data.lastMenstrualPeriod is timestamp
                      && request.resource.data.estimatedDueDate is timestamp
                      && isValidNumber(request.resource.data.prePregnancyWeightKg, 30, 200);
        allow update: if isOwner(userId);
        allow delete: if isOwner(userId);

        // KICK COUNTS — validasi ketat field totalKicks
        match /kick_counts/{sessionId} {
          allow read: if isOwner(userId);
          allow create: if isOwner(userId)
                        && request.resource.data.keys().hasAll(['startTime', 'totalKicks', 'isCompleted'])
                        && request.resource.data.startTime is timestamp
                        && isValidNumber(request.resource.data.totalKicks, 0, 1000)
                        && request.resource.data.isCompleted is bool;
          allow update: if false; // sesi yang sudah tersimpan bersifat immutable (riwayat medis)
          allow delete: if isOwner(userId);
        }

        // CONTRACTIONS — validasi endTime > startTime
        match /contractions/{contractionId} {
          allow read: if isOwner(userId);
          allow create: if isOwner(userId)
                        && request.resource.data.keys().hasAll(['startTime', 'endTime'])
                        && request.resource.data.startTime is timestamp
                        && request.resource.data.endTime is timestamp
                        && request.resource.data.endTime > request.resource.data.startTime;
          allow update: if false;
          allow delete: if isOwner(userId);
        }

        // SYMPTOM LOGS
        match /symptom_logs/{logId} {
          allow read: if isOwner(userId);
          allow create: if isOwner(userId)
                        && request.resource.data.date is timestamp
                        && (!('nauseaLevel' in request.resource.data) || isValidNumber(request.resource.data.nauseaLevel, 0, 5))
                        && (!('fatigueLevel' in request.resource.data) || isValidNumber(request.resource.data.fatigueLevel, 0, 5));
          allow update: if isOwner(userId);
          allow delete: if isOwner(userId);
        }
      }

      // ────────────────────────────────────────────
      // SUBKOLEKSI: children/{childId}
      // ────────────────────────────────────────────
      match /children/{childId} {
        allow read: if isOwner(userId);
        allow create: if isOwner(userId)
                      && request.resource.data.keys().hasAll(['fullName', 'gender', 'dateOfBirth'])
                      && request.resource.data.gender in ['male', 'female']
                      && request.resource.data.dateOfBirth is timestamp
                      && request.resource.data.dateOfBirth <= request.time; // tidak boleh tanggal masa depan
        allow update: if isOwner(userId)
                      && (!('gender' in request.resource.data) || request.resource.data.gender in ['male', 'female']);
        allow delete: if isOwner(userId);

        // GROWTH LOGS — validasi rentang fisiologis wajar
        match /growth_logs/{logId} {
          allow read: if isOwner(userId);
          allow create: if isOwner(userId)
                        && request.resource.data.keys().hasAll(['measurementDate', 'weightKg', 'heightCm', 'headCircumferenceCm', 'zone'])
                        && isValidNumber(request.resource.data.weightKg, 0.5, 80)
                        && isValidNumber(request.resource.data.heightCm, 30, 150)
                        && isValidNumber(request.resource.data.headCircumferenceCm, 25, 60)
                        && request.resource.data.zone in ['green', 'yellow', 'red'];
          allow update: if false; // riwayat pertumbuhan bersifat immutable
          allow delete: if isOwner(userId);
        }

        // VACCINATIONS — status hanya 2 nilai valid
        match /vaccinations/{vaccinationId} {
          allow read: if isOwner(userId);
          allow create: if isOwner(userId)
                        && request.resource.data.keys().hasAll(['vaccineName', 'status', 'scheduledDate'])
                        && request.resource.data.vaccineName is string
                        && request.resource.data.status in ['completed', 'pending']
                        && request.resource.data.scheduledDate is timestamp;
          allow update: if isOwner(userId)
                        && request.resource.data.status in ['completed', 'pending'];
          allow delete: if isOwner(userId);
        }

        // DEVELOPMENTAL MILESTONES
        match /developmental_milestones/{milestoneId} {
          allow read: if isOwner(userId);
          allow create: if isOwner(userId)
                        && request.resource.data.domain in ['gross_motor', 'fine_motor', 'language', 'social_emotional', 'cognitive']
                        && isValidNumber(request.resource.data.ageMonths, 0, 72);
          allow update: if isOwner(userId);
          allow delete: if isOwner(userId);
        }
      }

      // ────────────────────────────────────────────
      // SUBKOLEKSI: emergency_alerts/{alertId}
      // ────────────────────────────────────────────
      match /emergency_alerts/{alertId} {
        allow read: if isOwner(userId);
        allow create: if isOwner(userId)
                      && request.resource.data.keys().hasAll(['triggeredAt', 'latitude', 'longitude', 'status'])
                      && request.resource.data.status == 'active'
                      && isValidNumber(request.resource.data.latitude, -90, 90)
                      && isValidNumber(request.resource.data.longitude, -180, 180);
        allow update: if isOwner(userId)
                      && request.resource.data.status in ['active', 'resolved', 'false_alarm'];
        allow delete: if false; // log darurat tidak boleh dihapus — audit trail medis-legal
      }
    }

    // ────────────────────────────────────────────────
    // DEFAULT DENY — menutup seluruh path lain yang tidak
    // didefinisikan secara eksplisit di atas
    // ────────────────────────────────────────────────
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### 6.1 Catatan Kritis Implementasi Rules

1. **Immutability pada data medis riwayat** (`kick_counts`, `contractions`, `growth_logs`) — rule `allow update: if false` mencegah modifikasi data setelah tersimpan, menjaga integritas audit trail medis. Jika ada kesalahan input, alur yang benar adalah `delete` lalu `create` ulang, bukan `update`.
2. **`emergency_alerts` tidak bisa dihapus** — bersifat permanen sebagai bukti audit jika suatu hari diperlukan investigasi medis-legal.
3. **`allow delete: if false` pada `users/{userId}`** — penghapusan akun lengkap (termasuk seluruh subkoleksi) WAJIB melalui Cloud Function (`onCall` trigger) yang melakukan cascading delete terkontrol, bukan operasi client langsung yang berisiko data parsial tertinggal.
4. **Default deny di akhir** — prinsip *fail closed*: setiap path yang tidak didefinisikan secara eksplisit otomatis ditolak, bukan diizinkan.

### 6.2 Testing Security Rules

Gunakan `@firebase/rules-unit-testing` untuk menguji rules sebelum deploy:

```javascript
// test/firestore.rules.test.js
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');

describe('Growth Logs Security Rules', () => {
  let testEnv;

  beforeAll(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: 'carelink-test',
      firestore: { rules: require('fs').readFileSync('firestore.rules', 'utf8') },
    });
  });

  test('pengguna lain tidak boleh membaca growth_logs milik user lain', async () => {
    const aliceContext = testEnv.authenticatedContext('alice_uid');
    const bobContext = testEnv.authenticatedContext('bob_uid');

    await bobContext.firestore()
      .collection('users/bob_uid/children/child1/growth_logs')
      .add({ weightKg: 10, heightCm: 75, headCircumferenceCm: 45, zone: 'green', measurementDate: new Date() });

    await assertFails(
      aliceContext.firestore()
        .collection('users/bob_uid/children/child1/growth_logs')
        .get()
    );
  });

  test('weightKg di luar rentang fisiologis harus ditolak', async () => {
    const aliceContext = testEnv.authenticatedContext('alice_uid');
    await assertFails(
      aliceContext.firestore()
        .collection('users/alice_uid/children/child1/growth_logs')
        .add({ weightKg: 500, heightCm: 75, headCircumferenceCm: 45, zone: 'green', measurementDate: new Date() })
    );
  });
});
```

---

## 7. Dependency Injection — Konfigurasi GetIt Lengkap

### 7.1 Struktur Registrasi per Fitur

```dart
// core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';

import 'injection_container.auth.dart';
import 'injection_container.pregnancy.dart';
import 'injection_container.child_growth.dart';
import 'injection_container.vaccination.dart';
import 'injection_container.kick_counter.dart';
import 'injection_container.contraction_timer.dart';
import 'injection_container.emergency.dart';
import '../network/network_info.dart';

final sl = GetIt.instance; // Service Locator global

Future<void> initDependencies() async {
  // ─────────────────────────────────────────
  // 1. EXTERNAL / THIRD-PARTY — didaftarkan PALING AWAL
  // ─────────────────────────────────────────
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  final usersBox = await Hive.openBox('users_cache');
  sl.registerLazySingleton<Box>(() => usersBox, instanceName: 'usersBox');

  // ─────────────────────────────────────────
  // 2. CORE / SHARED
  // ─────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // ─────────────────────────────────────────
  // 3. FEATURE MODULES — urutan tidak masalah
  //    karena GetIt resolve dependency lazily
  // ─────────────────────────────────────────
  initAuthDependencies(sl);
  initPregnancyDependencies(sl);
  initChildGrowthDependencies(sl);
  initVaccinationDependencies(sl);
  initKickCounterDependencies(sl);
  initContractionTimerDependencies(sl);
  initEmergencyDependencies(sl);
}
```

### 7.2 Contoh Modul Registrasi per Fitur

```dart
// core/di/injection_container.child_growth.dart
import 'package:get_it/get_it.dart';
import '../../features/child_growth/data/datasources/growth_remote_datasource.dart';
import '../../features/child_growth/data/datasources/growth_local_datasource.dart';
import '../../features/child_growth/data/repositories/growth_repository_impl.dart';
import '../../features/child_growth/domain/repositories/growth_repository.dart';
import '../../features/child_growth/domain/services/who_growth_standard_service.dart';
import '../../features/child_growth/domain/usecases/calculate_growth_zscore.dart';
import '../../features/child_growth/domain/usecases/add_growth_log.dart';
import '../../features/child_growth/domain/usecases/get_growth_logs.dart';
import '../../features/child_growth/presentation/bloc/growth_bloc.dart';

void initChildGrowthDependencies(GetIt sl) {
  // Presentation — Factory karena BLoC dibuat baru setiap halaman dibuka
  sl.registerFactory(() => GrowthBloc(
        calculateGrowthZScore: sl(),
        addGrowthLog: sl(),
        getGrowthLogs: sl(),
      ));

  // Domain — Use Cases, lazy singleton karena stateless
  sl.registerLazySingleton(() => CalculateGrowthZScore(sl()));
  sl.registerLazySingleton(() => AddGrowthLog(sl()));
  sl.registerLazySingleton(() => GetGrowthLogs(sl()));
  sl.registerLazySingleton(() => WhoGrowthStandardService());

  // Domain — Repository abstraction terikat ke implementasi konkret
  sl.registerLazySingleton<GrowthRepository>(() => GrowthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
        firebaseAuth: sl(),
      ));

  // Data — Data Sources
  sl.registerLazySingleton<GrowthRemoteDataSource>(
    () => GrowthRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<GrowthLocalDataSource>(
    () => GrowthLocalDataSourceImpl(hiveBox: sl(instanceName: 'usersBox')),
  );
}
```

**Pemakaian di widget (penyediaan BLoC ke widget tree):**

```dart
// features/child_growth/presentation/pages/growth_log_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/growth_bloc.dart';

class GrowthLogPage extends StatelessWidget {
  final String childId;
  const GrowthLogPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GrowthBloc>()..add(LoadGrowthLogsRequested(childId)),
      child: const GrowthLogView(),
    );
  }
}
```

---

## 8. Mekanisme Sinkronisasi Offline — Sync Queue

### 8.1 Masalah yang Diselesaikan

Firestore SDK sudah menyediakan offline persistence bawaan (otomatis cache & retry write saat reconnect). Namun, untuk operasi kompleks seperti penyimpanan sesi Kick Counter / Contraction Timer yang melibatkan logika tambahan (misal: pemicu notifikasi setelah sync berhasil), arsitektur ini WAJIB mengimplementasikan **Sync Queue eksplisit** berbasis Hive sebagai lapisan tambahan di atas mekanisme bawaan Firestore.

### 8.2 Struktur Sync Queue

```dart
// core/sync/sync_queue_item.dart
class SyncQueueItem {
  final String id;
  final String collectionPath; // contoh: 'users/uid/pregnancies/preg1/kick_counts'
  final Map<String, dynamic> payload;
  final DateTime queuedAt;
  final int retryCount;

  const SyncQueueItem({
    required this.id,
    required this.collectionPath,
    required this.payload,
    required this.queuedAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'collectionPath': collectionPath,
        'payload': payload,
        'queuedAt': queuedAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) => SyncQueueItem(
        id: map['id'],
        collectionPath: map['collectionPath'],
        payload: Map<String, dynamic>.from(map['payload']),
        queuedAt: DateTime.parse(map['queuedAt']),
        retryCount: map['retryCount'] ?? 0,
      );
}
```

```dart
// core/sync/sync_queue_manager.dart
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_queue_item.dart';

class SyncQueueManager {
  final Box queueBox;
  final FirebaseFirestore firestore;
  final Connectivity connectivity;

  static const int maxRetries = 5;
  StreamSubscription? _connectivitySubscription;

  SyncQueueManager({
    required this.queueBox,
    required this.firestore,
    required this.connectivity,
  }) {
    _listenForReconnection();
  }

  void _listenForReconnection() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        processQueue();
      }
    });
  }

  Future<void> enqueue(SyncQueueItem item) async {
    await queueBox.put(item.id, item.toMap());
  }

  Future<void> processQueue() async {
    final keys = queueBox.keys.toList();

    for (final key in keys) {
      final raw = queueBox.get(key);
      if (raw == null) continue;

      final item = SyncQueueItem.fromMap(Map<String, dynamic>.from(raw));

      try {
        await firestore.collection(item.collectionPath).add({
          ...item.payload,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await queueBox.delete(key); // berhasil sync, hapus dari antrean
      } catch (e) {
        if (item.retryCount >= maxRetries) {
          await queueBox.delete(key); // beri tahu user via UI bahwa data ini gagal permanen
          // TODO: emit event kegagalan permanen ke BLoC terkait untuk notifikasi user
        } else {
          final retriedItem = SyncQueueItem(
            id: item.id,
            collectionPath: item.collectionPath,
            payload: item.payload,
            queuedAt: item.queuedAt,
            retryCount: item.retryCount + 1,
          );
          await queueBox.put(key, retriedItem.toMap());
        }
      }
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
```

### 8.3 Aturan Penggunaan Sync Queue

| Skenario | Aturan |
|---|---|
| Sesi Kick Counter selesai saat offline | Disimpan ke `SyncQueueManager.enqueue()`, BLoC tetap emit `KickCounterSaveSuccess` (UX tidak boleh terhambat oleh status jaringan) |
| Reconnect terdeteksi | `processQueue()` otomatis dipanggil via listener `connectivity_plus` |
| Retry gagal 5 kali | Item dihapus dari antrean dan ditandai gagal permanen — BLoC terkait WAJIB menampilkan indikator visual "data belum tersinkron" di UI riwayat |
| Growth Log baru (bukan real-time session) | Boleh mengandalkan offline persistence bawaan Firestore SDK saja, TIDAK perlu Sync Queue eksplisit karena tidak ada logika tambahan pasca-sync |

---

## 9. Jadwal Imunisasi IDAI 2024 — Implementasi sebagai Data Service

### 9.1 Model Data Jadwal Vaksin Acuan

```dart
// features/vaccination/domain/entities/vaccine_schedule_template.dart
class VaccineScheduleTemplate {
  final String vaccineName;
  final int scheduledAgeInDays; // usia anak saat vaksin jatuh tempo, dalam hari
  final int reminderLeadDays;   // berapa hari sebelumnya notifikasi dikirim
  final bool isCombo;           // true jika bagian dari sediaan kombinasi/pentavalen
  final String? notes;

  const VaccineScheduleTemplate({
    required this.vaccineName,
    required this.scheduledAgeInDays,
    this.reminderLeadDays = 14,
    this.isCombo = false,
    this.notes,
  });
}
```

### 9.2 Tabel Acuan Lengkap IDAI 2024 (Domain Service)

```dart
// features/vaccination/domain/services/idai_2024_schedule_service.dart
import '../entities/vaccine_schedule_template.dart';

/// Sumber acuan: Rekomendasi Jadwal Imunisasi IDAI 2024.
/// Service ini murni Dart — tidak bergantung Firebase — sehingga
/// dapat diuji unit dan diperbarui independen dari infrastruktur data.
class Idai2024ScheduleService {
  static const List<VaccineScheduleTemplate> schedule = [
    // ── Usia 0 hari (segera pasca-lahir, dalam 24 jam) ──
    VaccineScheduleTemplate(
      vaccineName: 'Hepatitis B-0',
      scheduledAgeInDays: 0,
      reminderLeadDays: 0,
      notes: 'Wajib diberikan dalam 24 jam pertama kehidupan',
    ),
    VaccineScheduleTemplate(
      vaccineName: 'Polio Oral-0',
      scheduledAgeInDays: 0,
      reminderLeadDays: 0,
    ),

    // ── Usia < 1 bulan ──
    VaccineScheduleTemplate(
      vaccineName: 'BCG',
      scheduledAgeInDays: 30,
      reminderLeadDays: 7,
    ),

    // ── Usia 2 bulan (60 hari) ──
    VaccineScheduleTemplate(vaccineName: 'DTP-Hib-HepB-1 (Pentavalen)', scheduledAgeInDays: 60, isCombo: true),
    VaccineScheduleTemplate(vaccineName: 'Polio-1', scheduledAgeInDays: 60),
    VaccineScheduleTemplate(vaccineName: 'PCV-1', scheduledAgeInDays: 60),
    VaccineScheduleTemplate(vaccineName: 'Rotavirus-1', scheduledAgeInDays: 60),

    // ── Usia 3 bulan (90 hari) ──
    VaccineScheduleTemplate(vaccineName: 'DTP-Hib-HepB-2 (Pentavalen)', scheduledAgeInDays: 90, isCombo: true),
    VaccineScheduleTemplate(vaccineName: 'Polio-2', scheduledAgeInDays: 90),
    VaccineScheduleTemplate(vaccineName: 'PCV-2', scheduledAgeInDays: 90),
    VaccineScheduleTemplate(vaccineName: 'Rotavirus-2', scheduledAgeInDays: 90),

    // ── Usia 4 bulan (120 hari) ──
    VaccineScheduleTemplate(vaccineName: 'DTP-Hib-HepB-3 (Pentavalen)', scheduledAgeInDays: 120, isCombo: true),
    VaccineScheduleTemplate(vaccineName: 'Polio-3', scheduledAgeInDays: 120),
    VaccineScheduleTemplate(vaccineName: 'IPV-1', scheduledAgeInDays: 120, notes: 'Polio suntik minimal 1 dosis'),

    // ── Usia 6 bulan (180 hari) ──
    VaccineScheduleTemplate(vaccineName: 'PCV-3 (Booster Dasar)', scheduledAgeInDays: 180),
    VaccineScheduleTemplate(vaccineName: 'Rotavirus-3', scheduledAgeInDays: 180, notes: 'Hanya jika formulasi 3-dosis'),
    VaccineScheduleTemplate(
      vaccineName: 'Influenza-1',
      scheduledAgeInDays: 180,
      notes: 'Dosis pertama dari dua dosis primer berjarak 4 minggu',
    ),
    VaccineScheduleTemplate(vaccineName: 'Influenza-2', scheduledAgeInDays: 208), // +4 minggu dari dosis 1
    VaccineScheduleTemplate(
      vaccineName: 'HFMD-1',
      scheduledAgeInDays: 180,
      notes: 'Vaksin baru wajib tercatat sejak pedoman IDAI 2024 — Flu Singapore',
    ),
    VaccineScheduleTemplate(vaccineName: 'HFMD-2', scheduledAgeInDays: 208),

    // ── Usia 9 bulan (270 hari) ──
    VaccineScheduleTemplate(vaccineName: 'MR (Measles-Rubella)', scheduledAgeInDays: 270),
    VaccineScheduleTemplate(
      vaccineName: 'JE (Japanese Encephalitis)',
      scheduledAgeInDays: 270,
      notes: 'Hanya untuk anak di wilayah endemis/vektor terjangkit',
    ),

    // ── Usia 12 bulan (360 hari) ──
    VaccineScheduleTemplate(vaccineName: 'PCV Booster', scheduledAgeInDays: 360),
    VaccineScheduleTemplate(vaccineName: 'Hepatitis A-1', scheduledAgeInDays: 360),

    // ── Usia 18 bulan (540 hari) ──
    VaccineScheduleTemplate(vaccineName: 'DTP Booster-1', scheduledAgeInDays: 540),
    VaccineScheduleTemplate(vaccineName: 'MMR (Measles-Mumps-Rubella)', scheduledAgeInDays: 540),
    VaccineScheduleTemplate(vaccineName: 'Varicella', scheduledAgeInDays: 540),
    VaccineScheduleTemplate(vaccineName: 'Hepatitis A-2', scheduledAgeInDays: 540),

    // ── Usia 2 tahun ke atas (booster berkala) ──
    VaccineScheduleTemplate(
      vaccineName: 'Tifoid',
      scheduledAgeInDays: 730,
      reminderLeadDays: 30,
      notes: 'Booster diulang setiap 3 tahun',
    ),
    VaccineScheduleTemplate(
      vaccineName: 'Dengue',
      scheduledAgeInDays: 2190, // 6 tahun, usia sekolah dasar
      notes: 'Untuk anak usia sekolah dasar di wilayah endemis',
    ),
    VaccineScheduleTemplate(
      vaccineName: 'HPV-1',
      scheduledAgeInDays: 3650, // 10 tahun, praremaja
      notes: 'Anak perempuan, dosis pertama dari rangkaian proteksi kanker serviks',
    ),
  ];

  /// Generate jadwal personal berdasarkan tanggal lahir anak.
  List<VaccineScheduleItem> generateScheduleForChild({
    required DateTime dateOfBirth,
  }) {
    return schedule.map((template) {
      final scheduledDate = dateOfBirth.add(Duration(days: template.scheduledAgeInDays));
      final reminderDate = scheduledDate.subtract(Duration(days: template.reminderLeadDays));

      return VaccineScheduleItem(
        vaccineName: template.vaccineName,
        scheduledDate: scheduledDate,
        reminderDate: reminderDate,
        isCombo: template.isCombo,
        notes: template.notes,
      );
    }).toList();
  }
}

class VaccineScheduleItem {
  final String vaccineName;
  final DateTime scheduledDate;
  final DateTime reminderDate;
  final bool isCombo;
  final String? notes;

  const VaccineScheduleItem({
    required this.vaccineName,
    required this.scheduledDate,
    required this.reminderDate,
    required this.isCombo,
    this.notes,
  });
}
```

### 9.3 Use Case — Generate & Simpan Jadwal Saat Profil Anak Dibuat

```dart
// features/vaccination/domain/usecases/generate_vaccine_schedule.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/vaccination_repository.dart';
import '../services/idai_2024_schedule_service.dart';

class GenerateVaccineScheduleParams {
  final String childId;
  final DateTime dateOfBirth;

  const GenerateVaccineScheduleParams({
    required this.childId,
    required this.dateOfBirth,
  });
}

class GenerateVaccineSchedule implements UseCase<void, GenerateVaccineScheduleParams> {
  final VaccinationRepository repository;
  final Idai2024ScheduleService scheduleService;

  const GenerateVaccineSchedule({
    required this.repository,
    required this.scheduleService,
  });

  @override
  Future<Either<Failure, void>> call(GenerateVaccineScheduleParams params) async {
    final items = scheduleService.generateScheduleForChild(
      dateOfBirth: params.dateOfBirth,
    );

    return repository.bulkCreateVaccinationRecords(
      childId: params.childId,
      items: items,
    );
  }
}
```

> **Trigger pemanggilan:** Use Case ini WAJIB dipanggil tepat satu kali — segera setelah profil anak (`children/{childId}`) berhasil dibuat — agar seluruh dokumen `vaccinations` ter-generate otomatis dengan status awal `'pending'` untuk seluruh rentang usia 0–10 tahun.

### 9.4 Cloud Function — Trigger Reminder Otomatis (Server-Side)

Karena pengiriman notifikasi terjadwal jauh ke depan (misal: pengingat 14 hari sebelum jatuh tempo vaksin usia 6 bulan) tidak praktis dijadwalkan dari client (aplikasi bisa saja tidak pernah dibuka di tanggal tersebut), bagian ini WAJIB diimplementasikan sebagai **Cloud Function terjadwal (Scheduled Function)**, bukan logic di sisi Flutter:

```javascript
// functions/index.js (Node.js — Firebase Cloud Functions)
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.checkVaccineReminders = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const tomorrow = admin.firestore.Timestamp.fromMillis(now.toMillis() + 24 * 60 * 60 * 1000);

    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const childrenSnapshot = await userDoc.ref.collection('children').get();

      for (const childDoc of childrenSnapshot.docs) {
        const dueVaccines = await childDoc.ref
          .collection('vaccinations')
          .where('status', '==', 'pending')
          .where('nextReminderAt', '>=', now)
          .where('nextReminderAt', '<=', tomorrow)
          .get();

        if (!dueVaccines.empty && userDoc.data().fcmToken) {
          await admin.messaging().send({
            token: userDoc.data().fcmToken,
            notification: {
              title: 'Pengingat Imunisasi',
              body: `${dueVaccines.docs[0].data().vaccineName} segera jatuh tempo untuk ${childDoc.data().fullName}`,
            },
            data: { type: 'vaccine_reminder', childId: childDoc.id },
          });
        }
      }
    }
  });
```

---

## 10. Error Handling — Implementasi Lengkap

### 10.1 Hierarki Failure (Domain Layer)

```dart
// core/errors/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Akses ditolak oleh sistem keamanan']);
}

class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([super.message = 'Sesi pengguna tidak valid, silakan masuk kembali']);
}
```

### 10.2 Hierarki Exception (Data Layer)

```dart
// core/errors/exceptions.dart
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}
```

### 10.3 Mapping Firebase Error Code ke Failure (Penting untuk UX Lokal)

Firebase mengembalikan error code teknis dalam Bahasa Inggris. Lapisan Data WAJIB memetakan kode ini ke pesan berbahasa Indonesia yang dapat dipahami pengguna awam, bukan meneruskan pesan teknis mentah ke UI.

```dart
// core/errors/firebase_error_mapper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'failures.dart';

class FirebaseErrorMapper {
  static Failure mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const ServerFailure('Akun dengan surel tersebut tidak ditemukan.');
      case 'wrong-password':
        return const ServerFailure('Kata sandi yang Anda masukkan salah.');
      case 'email-already-in-use':
        return const ServerFailure('Surel ini sudah terdaftar. Silakan masuk.');
      case 'weak-password':
        return const ServerFailure('Kata sandi terlalu lemah, gunakan minimal 8 karakter.');
      case 'network-request-failed':
        return const NetworkFailure();
      case 'too-many-requests':
        return const ServerFailure('Terlalu banyak percobaan. Coba lagi beberapa saat.');
      default:
        return ServerFailure('Terjadi kesalahan: ${e.message}');
    }
  }

  static Failure mapFirestoreError(String? code, String? message) {
    switch (code) {
      case 'permission-denied':
        return const PermissionFailure();
      case 'unavailable':
        return const NetworkFailure('Server tidak dapat dijangkau, periksa koneksi Anda.');
      default:
        return ServerFailure(message ?? 'Terjadi kesalahan tak terduga.');
    }
  }
}
```

### 10.4 Pola Penanganan di BLoC (UI-Facing)

```dart
// Contoh pola standar penanganan failure->state di seluruh BLoC aplikasi
result.fold(
  (failure) {
    final userMessage = switch (failure) {
      NetworkFailure() => 'Periksa koneksi internet Anda dan coba lagi.',
      PermissionFailure() => 'Anda tidak memiliki akses untuk tindakan ini.',
      UnauthenticatedFailure() => 'Sesi Anda berakhir, silakan masuk kembali.',
      ValidationFailure(message: final msg) => msg,
      _ => 'Terjadi kesalahan. Silakan coba lagi.',
    };
    emit(SomeFailureState(userMessage));
  },
  (data) => emit(SomeSuccessState(data)),
);
```

---

## 11. Routing Adaptif — go_router Berbasis Profil Pengguna

### 11.1 Konfigurasi Router dengan Redirect Logic

```dart
// core/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_profile_page.dart';
import '../../features/dashboard/presentation/pages/pregnancy_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/child_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/combined_dashboard_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggingIn = state.matchedLocation == '/login';

      if (user == null && !isLoggingIn) return '/login';
      if (user != null && isLoggingIn) return '/dashboard';

      return null; // tidak ada redirect, lanjutkan navigasi normal
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/onboarding-profile', builder: (_, __) => const OnboardingProfilePage()),

      // ROUTE ADAPTIF — widget yang dirender bergantung pada profileType pengguna
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AdaptiveDashboardResolver(),
      ),
    ],
  );
}

/// Widget ini membaca profileType pengguna dari Firestore (via BLoC)
/// dan merender dashboard yang sesuai — inilah inti dari "routing
/// adaptif" yang disebut dalam dokumen arsitektur.
class AdaptiveDashboardResolver extends StatelessWidget {
  const AdaptiveDashboardResolver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoaded) {
          return switch (state.profile.profileType) {
            'pregnant' => const PregnancyDashboardPage(),
            'has_children' => const ChildDashboardPage(),
            'both' => const CombinedDashboardPage(),
            _ => const OnboardingProfilePage(),
          };
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
```

---

## 12. Modul Emergency SOS — Implementasi Lengkap End-to-End

### 12.1 Entity & Use Case

```dart
// features/emergency/domain/entities/emergency_alert.dart
import 'package:equatable/equatable.dart';

enum AlertStatus { active, resolved, falseAlarm }

class EmergencyAlert extends Equatable {
  final String? id;
  final DateTime triggeredAt;
  final double latitude;
  final double longitude;
  final AlertStatus status;
  final List<String> notifiedContacts;

  const EmergencyAlert({
    this.id,
    required this.triggeredAt,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.notifiedContacts = const [],
  });

  @override
  List<Object?> get props => [id, triggeredAt, latitude, longitude, status, notifiedContacts];
}
```

```dart
// features/emergency/domain/usecases/trigger_sos_alert.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/emergency_alert.dart';
import '../repositories/emergency_repository.dart';
import '../services/location_service.dart';

class TriggerSosAlert implements UseCase<EmergencyAlert, NoParams> {
  final EmergencyRepository repository;
  final LocationService locationService;

  const TriggerSosAlert({required this.repository, required this.locationService});

  @override
  Future<Either<Failure, EmergencyAlert>> call(NoParams params) async {
    final positionResult = await locationService.getCurrentPosition();

    return positionResult.fold(
      (failure) => Left(failure),
      (position) async {
        final alert = EmergencyAlert(
          triggeredAt: DateTime.now(),
          latitude: position.latitude,
          longitude: position.longitude,
          status: AlertStatus.active,
        );

        return repository.createAlert(alert);
      },
    );
  }
}
```

### 12.2 Location Service (Domain-level abstraction, Data-level implementation)

```dart
// features/emergency/data/services/location_service_impl.dart
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/services/location_service.dart';

class LocationServiceImpl implements LocationService {
  @override
  Future<Either<Failure, Position>> getCurrentPosition() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied) {
        return const Left(PermissionFailure('Izin lokasi ditolak. SOS membutuhkan akses lokasi.'));
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const Left(PermissionFailure(
        'Izin lokasi diblokir permanen. Aktifkan melalui Pengaturan perangkat.',
      ));
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return Right(position);
    } catch (e) {
      return const Left(ServerFailure('Gagal mendapatkan lokasi. Pastikan GPS aktif.'));
    }
  }
}
```

### 12.3 Widget Tombol SOS — Persistent di Seluruh Halaman

```dart
// features/emergency/presentation/widgets/sos_floating_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/emergency_bloc.dart';
import '../bloc/emergency_event.dart';
import '../bloc/emergency_state.dart';

/// Widget ini WAJIB diletakkan di level Scaffold root aplikasi
/// (misal di dalam sebuah PersistentBottomSheet atau Stack global),
/// BUKAN di tiap halaman individual, agar selalu tersedia tanpa
/// duplikasi kode dan tanpa risiko terlewat di halaman baru.
class SosFloatingButton extends StatelessWidget {
  const SosFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmergencyBloc, EmergencyState>(
      listener: (context, state) {
        if (state is EmergencySosTriggered) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sinyal darurat terkirim ke kontak Anda.')),
          );
        }
        if (state is EmergencyFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is EmergencyTriggering;
        return FloatingActionButton(
          backgroundColor: Colors.red.shade700,
          onPressed: isLoading ? null : () => _confirmAndTrigger(context),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.sos, color: Colors.white, size: 28),
        );
      },
    );
  }

  void _confirmAndTrigger(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kirim Sinyal Darurat?'),
        content: const Text(
          'Lokasi Anda akan dikirim ke kontak darurat dan fasilitas kesehatan terdaftar.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<EmergencyBloc>().add(const SosButtonPressed());
            },
            child: const Text('Kirim Sekarang'),
          ),
        ],
      ),
    );
  }
}
```

---

## 13. Strategi Testing Menyeluruh

### 13.1 Piramida Testing untuk Ibu CareLink

| Lapisan | Jenis Test | Tools | Target Coverage |
|---|---|---|---|
| Domain (Use Case) | Unit Test | `flutter_test`, `mocktail` | 90%+ — wajib tinggi karena ini logika medis kritis |
| Data (Repository) | Unit Test dengan mock DataSource | `mocktail` | 80%+ |
| Presentation (BLoC) | BLoC Test | `bloc_test` | 80%+ |
| Firestore Rules | Rules Unit Test | `@firebase/rules-unit-testing` | 100% per koleksi |
| Widget | Widget Test | `flutter_test` | Fitur kritis (SOS, Kick Counter, Contraction Timer) wajib |
| End-to-End | Integration Test | `integration_test` | Alur onboarding → dashboard, alur SOS penuh |

### 13.2 Contoh BLoC Test — Kick Counter

```dart
// test/features/kick_counter/presentation/bloc/kick_counter_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:carelink/features/kick_counter/presentation/bloc/kick_counter_bloc.dart';
import 'package:carelink/features/kick_counter/presentation/bloc/kick_counter_event.dart';
import 'package:carelink/features/kick_counter/presentation/bloc/kick_counter_state.dart';
import 'package:carelink/features/kick_counter/domain/usecases/save_kick_session.dart';

class MockSaveKickSession extends Mock implements SaveKickSession {}

void main() {
  late MockSaveKickSession mockSaveKickSession;
  late KickCounterBloc bloc;

  setUp(() {
    mockSaveKickSession = MockSaveKickSession();
    bloc = KickCounterBloc(saveKickSession: mockSaveKickSession);
  });

  tearDown(() => bloc.close());

  blocTest<KickCounterBloc, KickCounterState>(
    'emit KickCounterInProgress saat sesi dimulai',
    build: () => bloc,
    act: (bloc) => bloc.add(const StartKickSessionRequested()),
    expect: () => [isA<KickCounterInProgress>()],
  );

  blocTest<KickCounterBloc, KickCounterState>(
    'emit KickCounterTargetReached setelah 10 tendangan tercatat',
    build: () => bloc,
    act: (bloc) {
      bloc.add(const StartKickSessionRequested());
      for (int i = 0; i < 10; i++) {
        bloc.add(const KickRecorded());
      }
    },
    skip: 1, // skip emit pertama dari StartKickSessionRequested
    expect: () => [
      ...List.generate(9, (_) => isA<KickCounterInProgress>()),
      isA<KickCounterTargetReached>(),
    ],
  );

  blocTest<KickCounterBloc, KickCounterState>(
    'emit KickCounterFailure jika penyimpanan gagal',
    setUp: () {
      when(() => mockSaveKickSession(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Gagal menyimpan')));
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const EndKickSessionRequested(pregnancyId: 'preg1')),
    expect: () => [
      isA<KickCounterSaving>(),
      isA<KickCounterFailure>(),
    ],
  );
}
```

---

## 14. Ringkasan Aturan Larangan Mutlak (Diperluas)

| No. | Larangan | Lapisan Terdampak |
|---|---|---|
| 1 | Widget UI DILARANG mengimpor atau memanggil Firebase SDK secara langsung | Presentation |
| 2 | Domain Layer DILARANG bergantung pada Flutter framework, Firebase, atau library pihak ketiga apapun | Domain |
| 3 | DILARANG menyimpan array/map yang terus bertumbuh tanpa batas dalam satu dokumen Firestore | Data / Firestore |
| 4 | Data historis (log harian) DILARANG disimpan sebagai field array dalam dokumen induk | Data / Firestore |
| 5 | Fitur Kick Counter & Contraction Timer DILARANG mengirim data ke Firestore per-event — hanya boleh setelah sesi selesai | Presentation / Data |
| 6 | Aturan Keamanan Firestore WAJIB ada — tidak boleh ada koleksi yang berjalan tanpa rules eksplisit | Firestore Rules |
| 7 | Algoritma evaluasi pertumbuhan WAJIB menggunakan Z-score LMS, BUKAN perbandingan rentang sederhana | Domain |
| 8 | API key dan credential Firebase DILARANG di-hardcode dalam source code | Seluruh Lapisan |
| 9 | BLoC DILARANG mengakses Data Layer secara langsung — harus melalui Use Case di Domain Layer | Presentation |
| 10 | Tombol SOS DILARANG hanya tersedia di satu halaman — harus persistent dan selalu dapat diakses | Presentation |
| 11 | Riwayat medis (`kick_counts`, `contractions`, `growth_logs`) DILARANG memiliki rule `allow update` — bersifat immutable | Firestore Rules |
| 12 | Penghapusan akun pengguna DILARANG dieksekusi langsung dari client — wajib melalui Cloud Function cascading delete | Data / Infrastructure |
| 13 | Reminder vaksinasi jangka panjang DILARANG dijadwalkan dari sisi client saja — wajib didukung Cloud Function terjadwal | Infrastructure |
| 14 | Pesan error teknis Firebase DILARANG diteruskan mentah ke UI — wajib dipetakan ke Bahasa Indonesia yang dapat dipahami pengguna | Data → Presentation |
| 15 | Use Case DILARANG melempar exception langsung — seluruh error wajib dikemas sebagai `Either<Failure, T>` | Domain |

---

*rule-carelink.md (Versi Detail) — Dokumen ini adalah blueprint arsitektur implementation-ready untuk tim pengembang Ibu CareLink, mencakup contoh kode Dart konkret di setiap lapisan Clean Architecture, skema Firestore lengkap per field, Security Rules siap-deploy dalam sintaks CEL, mekanisme offline-sync, dan strategi testing. Seluruh snippet kode bersifat referensial dan WAJIB diadaptasi serta diuji ulang sesuai kebutuhan aktual proyek sebelum dirilis ke produksi. Seluruh parameter klinis (tabel LMS WHO, jadwal IDAI 2024, rentang fisiologis) harus divalidasi ulang dengan profesional medis berlisensi dan sumber data resmi terbaru sebelum digunakan dalam sistem produksi yang menangani data kesehatan nyata.*
