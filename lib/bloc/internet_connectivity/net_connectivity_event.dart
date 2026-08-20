part of 'net_connectivity_bloc.dart';

abstract class NetConnectivityEvent {}

class NetConnectivityLostEvent extends NetConnectivityEvent {}

class NetConnectivityConnectedEvent extends NetConnectivityEvent {}
