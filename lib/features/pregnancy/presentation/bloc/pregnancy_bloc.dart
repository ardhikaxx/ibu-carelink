import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/pregnancy_usecases.dart';
import 'pregnancy_event.dart';
import 'pregnancy_state.dart';

class PregnancyBloc extends Bloc<PregnancyEvent, PregnancyState> {
  final GetActivePregnancyUseCase getActivePregnancyUseCase;
  final CreatePregnancyUseCase createPregnancyUseCase;
  final LogSymptomUseCase logSymptomUseCase;
  final GetSymptomLogsUseCase getSymptomLogsUseCase;

  PregnancyBloc({
    required this.getActivePregnancyUseCase,
    required this.createPregnancyUseCase,
    required this.logSymptomUseCase,
    required this.getSymptomLogsUseCase,
  }) : super(PregnancyInitial()) {
    on<LoadActivePregnancyEvent>(_onLoadActivePregnancy);
    on<CreatePregnancyProfileEvent>(_onCreatePregnancy);
    on<AddSymptomLogEvent>(_onAddSymptomLog);
  }

  Future<void> _onLoadActivePregnancy(LoadActivePregnancyEvent event, Emitter<PregnancyState> emit) async {
    emit(PregnancyLoading());
    final result = await getActivePregnancyUseCase(GetActivePregnancyParams(event.userId));
    await result.fold(
      (failure) async => emit(PregnancyError(failure.message)),
      (pregnancy) async {
        if (pregnancy != null) {
          final logsResult = await getSymptomLogsUseCase(GetSymptomLogsParams(
            userId: event.userId,
            pregnancyId: pregnancy.id,
          ));
          final logs = logsResult.getOrElse(() => []);
          emit(PregnancyLoaded(pregnancy: pregnancy, symptomLogs: logs));
        } else {
          emit(PregnancyEmpty());
        }
      },
    );
  }

  Future<void> _onCreatePregnancy(CreatePregnancyProfileEvent event, Emitter<PregnancyState> emit) async {
    emit(PregnancyLoading());
    final result = await createPregnancyUseCase(CreatePregnancyParams(
      userId: event.userId,
      hpht: event.hpht,
      prePregnancyWeight: event.preWeight,
    ));
    result.fold(
      (failure) => emit(PregnancyError(failure.message)),
      (pregnancy) => emit(PregnancyLoaded(pregnancy: pregnancy, symptomLogs: const [])),
    );
  }

  Future<void> _onAddSymptomLog(AddSymptomLogEvent event, Emitter<PregnancyState> emit) async {
    final currentState = state;
    if (currentState is PregnancyLoaded) {
      await logSymptomUseCase(event.log);
      final logsResult = await getSymptomLogsUseCase(GetSymptomLogsParams(
        userId: event.userId,
        pregnancyId: currentState.pregnancy.id,
      ));
      final logs = logsResult.getOrElse(() => currentState.symptomLogs);
      emit(PregnancyLoaded(pregnancy: currentState.pregnancy, symptomLogs: logs));
    }
  }
}
