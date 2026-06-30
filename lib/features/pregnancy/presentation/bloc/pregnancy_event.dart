import 'package:equatable/equatable.dart';
import '../../domain/entities/symptom_log_entity.dart';

abstract class PregnancyEvent extends Equatable {
  const PregnancyEvent();

  @override
  List<Object?> get props => [];
}

class LoadActivePregnancyEvent extends PregnancyEvent {
  final String userId;
  const LoadActivePregnancyEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreatePregnancyProfileEvent extends PregnancyEvent {
  final String userId;
  final DateTime hpht;
  final double preWeight;
  const CreatePregnancyProfileEvent({required this.userId, required this.hpht, required this.preWeight});

  @override
  List<Object?> get props => [userId, hpht, preWeight];
}

class AddSymptomLogEvent extends PregnancyEvent {
  final SymptomLogEntity log;
  final String userId;
  const AddSymptomLogEvent({required this.log, required this.userId});

  @override
  List<Object?> get props => [log, userId];
}
