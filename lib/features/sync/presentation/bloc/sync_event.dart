import 'package:equatable/equatable.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class ConnectivityStatusChangedEvent extends SyncEvent {
  final bool isOnline;
  const ConnectivityStatusChangedEvent(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class TriggerManualSyncEvent extends SyncEvent {}
