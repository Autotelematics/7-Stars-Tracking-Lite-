// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'alerttypelist_cubit.dart';

class AlertsTypeListState {
  const AlertsTypeListState();
}

class AlerttypelistInitial extends AlertsTypeListState {}

class AlerttypelistLoading extends AlertsTypeListState {}

class AlerttypelistError extends AlertsTypeListState {}

class AlerttypelistComplete extends AlertsTypeListState {
  AlertsListModel alertsTypeList;
  AlerttypelistComplete({
    required this.alertsTypeList,
  });
}
