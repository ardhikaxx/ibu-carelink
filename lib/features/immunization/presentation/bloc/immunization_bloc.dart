import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/immunization_entity.dart';
import '../../domain/usecases/immunization_usecases.dart';
import 'immunization_event.dart';
import 'immunization_state.dart';

class ImmunizationBloc extends Bloc<ImmunizationEvent, ImmunizationState> {
  final GetImmunizationsUseCase getImmunizationsUseCase;
  final UpdateImmunizationUseCase updateImmunizationUseCase;

  ImmunizationBloc({
    required this.getImmunizationsUseCase,
    required this.updateImmunizationUseCase,
  }) : super(ImmunizationInitial()) {
    on<LoadImmunizationsEvent>(_onLoadImmunizations);
    on<MarkImmunizationDoneEvent>(_onMarkDone);
  }

  Future<void> _onLoadImmunizations(LoadImmunizationsEvent event, Emitter<ImmunizationState> emit) async {
    emit(ImmunizationLoading());
    final res = await getImmunizationsUseCase(GetImmunizationsParams(userId: event.userId, childId: event.childId));
    res.fold(
      (failure) => emit(ImmunizationError(failure.message)),
      (list) => emit(ImmunizationLoaded(immunizations: list, childAgeMonths: 6)), // Default atau estimasi usia
    );
  }

  Future<void> _onMarkDone(MarkImmunizationDoneEvent event, Emitter<ImmunizationState> emit) async {
    final currentState = state;
    if (currentState is ImmunizationLoaded) {
      final updatedEntity = ImmunizationEntity(
        id: event.immunization.id,
        childId: event.immunization.childId,
        vaccineName: event.immunization.vaccineName,
        targetAgeMonths: event.immunization.targetAgeMonths,
        isCompleted: true,
        dateAdministered: event.dateAdministered,
        batchNumber: event.batchNumber,
        clinicName: event.clinicName,
      );

      final res = await updateImmunizationUseCase(UpdateImmunizationParams(immunization: updatedEntity, userId: event.userId));
      await res.fold(
        (failure) async => emit(ImmunizationError(failure.message)),
        (saved) async {
          final newList = currentState.immunizations.map((i) => i.id == saved.id ? saved : i).toList();
          emit(ImmunizationLoaded(immunizations: newList, childAgeMonths: currentState.childAgeMonths));
        },
      );
    }
  }
}
