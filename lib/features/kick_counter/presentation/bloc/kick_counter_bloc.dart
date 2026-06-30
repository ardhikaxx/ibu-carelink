import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/wakelock_service.dart';
import '../../domain/entities/kick_session_entity.dart';
import '../../domain/usecases/kick_counter_usecases.dart';
import 'kick_counter_event.dart';
import 'kick_counter_state.dart';

class KickCounterBloc extends Bloc<KickCounterEvent, KickCounterState> {
  final SaveKickSessionUseCase saveKickSessionUseCase;
  final GetKickSessionsUseCase getKickSessionsUseCase;
  Timer? _timer;

  KickCounterBloc({
    required this.saveKickSessionUseCase,
    required this.getKickSessionsUseCase,
  }) : super(const KickCounterInitial()) {
    on<StartKickSessionEvent>(_onStartSession);
    on<RecordKickEvent>(_onRecordKick);
    on<TickTimerEvent>(_onTickTimer);
    on<StopAndSaveSessionEvent>(_onStopAndSave);
    on<LoadHistorySessionsEvent>(_onLoadHistory);
  }

  Future<void> _onStartSession(StartKickSessionEvent event, Emitter<KickCounterState> emit) async {
    await WakeLockService.enable();
    await HapticService.triggerKickImpact();
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isClosed) {
        add(TickTimerEvent(t.tick));
      }
    });

    // Load history first
    final histResult = await getKickSessionsUseCase(GetKickSessionsParams(
      userId: event.userId,
      pregnancyId: event.pregnancyId,
    ));
    final history = histResult.getOrElse(() => []);

    emit(KickCounterActive(
      pregnancyId: event.pregnancyId,
      userId: event.userId,
      sessionId: const Uuid().v4(),
      startTime: DateTime.now(),
      elapsedSeconds: 0,
      totalKicks: 0,
      history: history,
    ));
  }

  Future<void> _onRecordKick(RecordKickEvent event, Emitter<KickCounterState> emit) async {
    final currentState = state;
    if (currentState is KickCounterActive) {
      await HapticService.triggerKickImpact();
      emit(currentState.copyWith(totalKicks: currentState.totalKicks + 1));
    }
  }

  void _onTickTimer(TickTimerEvent event, Emitter<KickCounterState> emit) {
    final currentState = state;
    if (currentState is KickCounterActive) {
      emit(currentState.copyWith(elapsedSeconds: event.elapsedSeconds));
    }
  }

  Future<void> _onStopAndSave(StopAndSaveSessionEvent event, Emitter<KickCounterState> emit) async {
    final currentState = state;
    if (currentState is KickCounterActive) {
      _timer?.cancel();
      await WakeLockService.disable();
      emit(KickCounterSaving());

      final session = KickSessionEntity(
        id: currentState.sessionId,
        pregnancyId: currentState.pregnancyId,
        startTime: currentState.startTime,
        sessionDurationSeconds: currentState.elapsedSeconds,
        totalKicks: currentState.totalKicks,
        isCompleted: true,
      );

      // Aturan Mutlak 5: Hanya dikirim setelah sesi selesai sebagai satu dokumen utuh
      final result = await saveKickSessionUseCase(SaveKickSessionParams(
        session: session,
        userId: currentState.userId,
      ));

      await result.fold(
        (failure) async => emit(KickCounterError(failure.message)),
        (saved) async {
          final updatedHistory = [saved, ...currentState.history];
          emit(KickCounterSuccess(savedSession: saved, history: updatedHistory));
        },
      );
    }
  }

  Future<void> _onLoadHistory(LoadHistorySessionsEvent event, Emitter<KickCounterState> emit) async {
    final result = await getKickSessionsUseCase(GetKickSessionsParams(
      userId: event.userId,
      pregnancyId: event.pregnancyId,
    ));
    result.fold(
      (failure) => emit(const KickCounterInitial()),
      (list) => emit(KickCounterInitial(history: list)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    WakeLockService.disable();
    return super.close();
  }
}
