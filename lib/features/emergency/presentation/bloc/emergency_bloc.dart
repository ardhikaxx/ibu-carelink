import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/trigger_sos_alert.dart';
import 'emergency_event.dart';
import 'emergency_state.dart';

class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final TriggerSosAlert triggerSosAlert;

  EmergencyBloc({required this.triggerSosAlert}) : super(EmergencyInitial()) {
    on<SosButtonPressed>(_onSosButtonPressed);
  }

  Future<void> _onSosButtonPressed(
    SosButtonPressed event,
    Emitter<EmergencyState> emit,
  ) async {
    emit(EmergencyTriggering());
    final result = await triggerSosAlert(NoParams());
    result.fold(
      (failure) => emit(EmergencyFailure(message: failure.message)),
      (alert) => emit(EmergencySosTriggered(alert: alert)),
    );
  }
}
