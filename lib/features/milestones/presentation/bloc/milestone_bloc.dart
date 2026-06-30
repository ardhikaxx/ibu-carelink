import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/milestone_usecases.dart';
import 'milestone_event.dart';
import 'milestone_state.dart';

class MilestoneBloc extends Bloc<MilestoneEvent, MilestoneState> {
  final GetMilestonesUseCase getMilestonesUseCase;
  final ToggleMilestoneUseCase toggleMilestoneUseCase;

  MilestoneBloc({
    required this.getMilestonesUseCase,
    required this.toggleMilestoneUseCase,
  }) : super(MilestoneInitial()) {
    on<LoadMilestonesEvent>(_onLoadMilestones);
    on<ToggleMilestoneEvent>(_onToggleMilestone);
  }

  Future<void> _onLoadMilestones(LoadMilestonesEvent event, Emitter<MilestoneState> emit) async {
    emit(MilestoneLoading());
    final res = await getMilestonesUseCase(GetMilestonesParams(userId: event.userId, childId: event.childId));
    res.fold(
      (failure) => emit(MilestoneError(failure.message)),
      (list) {
        // Cek red flag berdasarkan estimasi/aktual usia anak
        final hasRedFlag = list.any((m) => m.isRedFlagWarning(8)); // Evaluasi standar
        emit(MilestoneLoaded(milestones: list, hasRedFlagWarning: hasRedFlag));
      },
    );
  }

  Future<void> _onToggleMilestone(ToggleMilestoneEvent event, Emitter<MilestoneState> emit) async {
    final currentState = state;
    if (currentState is MilestoneLoaded) {
      final res = await toggleMilestoneUseCase(ToggleMilestoneParams(milestone: event.milestone, userId: event.userId));
      res.fold(
        (failure) => emit(MilestoneError(failure.message)),
        (updated) {
          final newList = currentState.milestones.map((m) => m.id == updated.id ? updated : m).toList();
          final hasRedFlag = newList.any((m) => m.isRedFlagWarning(8));
          emit(MilestoneLoaded(milestones: newList, hasRedFlagWarning: hasRedFlag));
        },
      );
    }
  }
}
