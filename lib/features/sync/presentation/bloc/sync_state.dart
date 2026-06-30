import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  const SyncState({
    required this.isOnline,
    this.isSyncing = false,
    this.lastSyncTime,
  });

  @override
  List<Object?> get props => [isOnline, isSyncing, lastSyncTime];
}

class SyncOnlineState extends SyncState {
  const SyncOnlineState({super.isSyncing, super.lastSyncTime}) : super(isOnline: true);
}

class SyncOfflineState extends SyncState {
  const SyncOfflineState({super.lastSyncTime}) : super(isOnline: false, isSyncing: false);
}
