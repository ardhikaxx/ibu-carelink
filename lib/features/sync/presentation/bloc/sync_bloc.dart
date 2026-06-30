import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  SyncBloc() : super(const SyncOnlineState()) {
    on<ConnectivityStatusChangedEvent>(_onConnectivityChanged);
    on<TriggerManualSyncEvent>(_onManualSync);

    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      final isConnected = result != ConnectivityResult.none;
      add(ConnectivityStatusChangedEvent(isConnected));
    });
  }

  Future<void> _onConnectivityChanged(ConnectivityStatusChangedEvent event, Emitter<SyncState> emit) async {
    final wasOffline = !state.isOnline;
    if (event.isOnline) {
      if (wasOffline) {
        // Transisi dari Offline -> Online: Jalankan sinkronisasi antrean lokal
        emit(SyncOnlineState(isSyncing: true, lastSyncTime: state.lastSyncTime));
        await Future.delayed(const Duration(milliseconds: 1500)); // Simulasi proses batch sync lokal ke Firestore
        emit(SyncOnlineState(isSyncing: false, lastSyncTime: DateTime.now()));
      } else {
        emit(SyncOnlineState(isSyncing: state.isSyncing, lastSyncTime: state.lastSyncTime));
      }
    } else {
      emit(SyncOfflineState(lastSyncTime: state.lastSyncTime));
    }
  }

  Future<void> _onManualSync(TriggerManualSyncEvent event, Emitter<SyncState> emit) async {
    if (state.isOnline) {
      emit(SyncOnlineState(isSyncing: true, lastSyncTime: state.lastSyncTime));
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(SyncOnlineState(isSyncing: false, lastSyncTime: DateTime.now()));
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
