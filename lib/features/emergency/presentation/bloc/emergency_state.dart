import 'package:equatable/equatable.dart';
import '../../domain/entities/emergency_alert.dart';

abstract class EmergencyState extends Equatable {
  const EmergencyState();

  @override
  List<Object?> get props => [];
}

class EmergencyInitial extends EmergencyState {}

class EmergencyTriggering extends EmergencyState {}

class EmergencySosTriggered extends EmergencyState {
  final EmergencyAlert alert;

  const EmergencySosTriggered({required this.alert});

  @override
  List<Object?> get props => [alert];
}

class EmergencyFailure extends EmergencyState {
  final String message;

  const EmergencyFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
