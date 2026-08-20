import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

part 'net_connectivity_event.dart';
part 'net_connectivity_state.dart';

class NetConnectivityBloc
    extends Bloc<NetConnectivityEvent, NetConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  NetConnectivityBloc() : super(NetConnectivityInitial()) {
    on<NetConnectivityLostEvent>(
            (event, emit) => emit(NetConnectivityLostState()));

    on<NetConnectivityConnectedEvent>(
            (event, emit) => emit(NetConnectivityGainState()));

    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
          // If ANY connection type is active, emit connected
          if (results.contains(ConnectivityResult.mobile) ||
              results.contains(ConnectivityResult.wifi)) {
            add(NetConnectivityConnectedEvent());
          } else {
            add(NetConnectivityLostEvent());
          }
        });
  }

  @override
  Future<void> close() {
    connectivitySubscription?.cancel();
    return super.close();
  }
}
