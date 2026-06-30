import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/child_growth_usecases.dart';
import 'child_growth_event.dart';
import 'child_growth_state.dart';

class ChildGrowthBloc extends Bloc<ChildGrowthEvent, ChildGrowthState> {
  final GetChildrenUseCase getChildrenUseCase;
  final AddChildUseCase addChildUseCase;
  final LogGrowthUseCase logGrowthUseCase;
  final GetGrowthLogsUseCase getGrowthLogsUseCase;

  ChildGrowthBloc({
    required this.getChildrenUseCase,
    required this.addChildUseCase,
    required this.logGrowthUseCase,
    required this.getGrowthLogsUseCase,
  }) : super(ChildGrowthInitial()) {
    on<LoadChildrenEvent>(_onLoadChildren);
    on<SelectChildEvent>(_onSelectChild);
    on<AddNewChildEvent>(_onAddChild);
    on<RecordGrowthLogEvent>(_onRecordGrowthLog);
  }

  Future<void> _onLoadChildren(LoadChildrenEvent event, Emitter<ChildGrowthState> emit) async {
    emit(ChildGrowthLoading());
    final res = await getChildrenUseCase(GetChildrenParams(event.userId));
    await res.fold(
      (failure) async => emit(ChildGrowthError(failure.message)),
      (children) async {
        if (children.isNotEmpty) {
          final first = children.first;
          final logsRes = await getGrowthLogsUseCase(GetGrowthLogsParams(userId: event.userId, child: first));
          final logs = logsRes.getOrElse(() => []);
          final hasAlert = logs.any((l) => l.evaluation?.requiresInterventionAlert == true);
          emit(ChildGrowthLoaded(children: children, selectedChild: first, logs: logs, hasMedicalAlert: hasAlert));
        } else {
          emit(ChildGrowthEmpty());
        }
      },
    );
  }

  Future<void> _onSelectChild(SelectChildEvent event, Emitter<ChildGrowthState> emit) async {
    final currentState = state;
    if (currentState is ChildGrowthLoaded) {
      emit(ChildGrowthLoading());
      final logsRes = await getGrowthLogsUseCase(GetGrowthLogsParams(userId: event.userId, child: event.child));
      final logs = logsRes.getOrElse(() => []);
      final hasAlert = logs.any((l) => l.evaluation?.requiresInterventionAlert == true);
      emit(ChildGrowthLoaded(children: currentState.children, selectedChild: event.child, logs: logs, hasMedicalAlert: hasAlert));
    }
  }

  Future<void> _onAddChild(AddNewChildEvent event, Emitter<ChildGrowthState> emit) async {
    emit(ChildGrowthLoading());
    final res = await addChildUseCase(AddChildParams(child: event.child, userId: event.userId));
    await res.fold(
      (failure) async => emit(ChildGrowthError(failure.message)),
      (added) async {
        add(LoadChildrenEvent(event.userId));
      },
    );
  }

  Future<void> _onRecordGrowthLog(RecordGrowthLogEvent event, Emitter<ChildGrowthState> emit) async {
    final currentState = state;
    if (currentState is ChildGrowthLoaded) {
      await logGrowthUseCase(LogGrowthParams(log: event.log, child: event.child, userId: event.userId));
      add(SelectChildEvent(child: event.child, userId: event.userId));
    }
  }
}
