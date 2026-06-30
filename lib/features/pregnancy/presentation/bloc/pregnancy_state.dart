import 'package:equatable/equatable.dart';
import '../../domain/entities/pregnancy_entity.dart';
import '../../domain/entities/symptom_log_entity.dart';

abstract class PregnancyState extends Equatable {
  const PregnancyState();

  @override
  List<Object?> get props => [];
}

class PregnancyInitial extends PregnancyState {}

class PregnancyLoading extends PregnancyState {}

class PregnancyLoaded extends PregnancyState {
  final PregnancyEntity pregnancy;
  final List<SymptomLogEntity> symptomLogs;
  const PregnancyLoaded({required this.pregnancy, this.symptomLogs = const []});

  @override
  List<Object?> get props => [pregnancy, symptomLogs];
}

class PregnancyEmpty extends PregnancyState {}

class PregnancyError extends PregnancyState {
  final String message;
  const PregnancyError(this.message);

  @override
  List<Object?> get props => [message];
}
