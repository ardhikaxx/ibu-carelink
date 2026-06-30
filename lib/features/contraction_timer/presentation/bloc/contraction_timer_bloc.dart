import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/wakelock_service.dart';
import '../../domain/entities/contraction_entity.dart';
import '../../domain/usecases/contraction_usecases.dart';
import 'contraction_timer_event.dart';
import 'contraction_timer_state.dart';

class ContractionTimerBloc extends Bloc<ContractionTimerEvent, ContractionTimerState> {
  final SaveContractionUseCase saveContractionUseCase;
  final GetContractionsUseCase getContractionsUseCase;
  Timer? _timer;

  ContractionTimerBloc({
    required this.saveContractionUseCase,
    required this.getContractionsUseCase,
  }) : super(const ContractionTimerInitial()) {
    on<StartContractionSessionEvent>(_onStartSession);
    on<ToggleContractionEvent>(_onToggleContraction);
    on<TickContractionTimerEvent>(_onTickTimer);
    on<StopContractionSessionEvent>(_onStopSession);
    on<LoadHistoryContractionsEvent>(_onLoadHistory);
  }

  Future<void> _onStartSession(StartContractionSessionEvent event, Emitter<ContractionTimerState> emit) async {
    await WakeLockService.enable();
    await HapticService.triggerContractionImpact();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isClosed && state is ContractionTimerActive) {
        final st = state as ContractionTimerActive;
        int dur = st.activeDurationSeconds;
        int intv = st.currentIntervalSeconds;
        if (st.status == ContractionStatus.contractionStarted) {
          dur++;
        } else if (st.status == ContractionStatus.intervalRunning) {
          intv++;
        }
        add(TickContractionTimerEvent(currentDuration: dur, currentInterval: intv));
      }
    });

    final res = await getContractionsUseCase(GetContractionsParams(
      userId: event.userId,
      pregnancyId: event.pregnancyId,
    ));
    final history = res.getOrElse(() => []);
    final is511 = _check511Rule(history);

    emit(ContractionTimerActive(
      pregnancyId: event.pregnancyId,
      userId: event.userId,
      status: ContractionStatus.idle,
      history: history,
      is511AlertActive: is511,
    ));
  }

  Future<void> _onToggleContraction(ToggleContractionEvent event, Emitter<ContractionTimerState> emit) async {
    final currentState = state;
    if (currentState is ContractionTimerActive) {
      await HapticService.triggerContractionImpact();

      if (currentState.status == ContractionStatus.idle || currentState.status == ContractionStatus.intervalRunning) {
        // Mulai Kontraksi Baru
        emit(currentState.copyWith(
          status: ContractionStatus.contractionStarted,
          currentStartTime: DateTime.now(),
          activeDurationSeconds: 0,
          currentIntensity: event.intensity,
        ));
      } else if (currentState.status == ContractionStatus.contractionStarted) {
        // Selesai Kontraksi -> Simpan 1 catatan kontraksi ke list sementara & kirim setelah stop atau langsung
        final now = DateTime.now();
        final start = currentState.currentStartTime ?? now.subtract(Duration(seconds: currentState.activeDurationSeconds));
        final interval = currentState.lastEndTime != null
            ? start.difference(currentState.lastEndTime!).inSeconds
            : 0;

        final contraction = ContractionEntity(
          id: const Uuid().v4(),
          pregnancyId: currentState.pregnancyId,
          startTime: start,
          endTime: now,
          durationSeconds: currentState.activeDurationSeconds,
          intervalSeconds: interval,
          intensityLevel: currentState.currentIntensity,
        );

        // Aturan 5: Kirim dan evaluasi pola klinis
        await saveContractionUseCase(SaveContractionParams(
          contraction: contraction,
          userId: currentState.userId,
        ));

        final updatedHistory = [contraction, ...currentState.history];
        final is511 = _check511Rule(updatedHistory);

        emit(currentState.copyWith(
          status: ContractionStatus.intervalRunning,
          lastEndTime: now,
          currentIntervalSeconds: 0,
          history: updatedHistory,
          is511AlertActive: is511,
        ));
      }
    }
  }

  void _onTickTimer(TickContractionTimerEvent event, Emitter<ContractionTimerState> emit) {
    final currentState = state;
    if (currentState is ContractionTimerActive) {
      emit(currentState.copyWith(
        activeDurationSeconds: event.currentDuration,
        currentIntervalSeconds: event.currentInterval,
      ));
    }
  }

  Future<void> _onStopSession(StopContractionSessionEvent event, Emitter<ContractionTimerState> emit) async {
    final currentState = state;
    if (currentState is ContractionTimerActive) {
      _timer?.cancel();
      await WakeLockService.disable();
      emit(ContractionTimerSuccess(currentState.history));
    }
  }

  Future<void> _onLoadHistory(LoadHistoryContractionsEvent event, Emitter<ContractionTimerState> emit) async {
    final res = await getContractionsUseCase(GetContractionsParams(
      userId: event.userId,
      pregnancyId: event.pregnancyId,
    ));
    res.fold(
      (failure) => emit(const ContractionTimerInitial()),
      (list) => emit(ContractionTimerInitial(history: list)),
    );
  }

  /// Evaluasi Ambang Batas Klinis 5-1-1:
  /// Kontraksi terjadi setiap <= 5 menit (interval <= 300s), berdurasi sekitar 1 menit (>= 45s), konsisten dalam beberapa catatan terakhir.
  bool _check511Rule(List<ContractionEntity> history) {
    if (history.length < 3) return false;
    int matchingCount = 0;
    for (int i = 0; i < 3; i++) {
      final c = history[i];
      if (c.durationSeconds >= 45 && c.intervalSeconds > 0 && c.intervalSeconds <= 360) {
        matchingCount++;
      }
    }
    return matchingCount >= 3;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    WakeLockService.disable();
    return super.close();
  }
}
