import 'package:autotelematic_new_app/model/get_alerts_list_model.dart';

abstract class GetAlertsListState {
  final bool isLoading;
  final GetAlertsModel? model;
  final String? errorMessage;
  final bool showLoading;
  final int currentPage;
  final int totalPages;
  final List<int> selectedAlertIds;

  // ADD these:
  final int? deviceIdFilter;
  final String? alertTypeFilter;

  GetAlertsListState({
    required this.isLoading,
    this.model,
    this.errorMessage,
    required this.showLoading,
    required this.currentPage,
    required this.totalPages,
    required this.selectedAlertIds,
    this.deviceIdFilter,
    this.alertTypeFilter,
  });
}

class GetAlertsListInitial extends GetAlertsListState {
  GetAlertsListInitial()
      : super(
    isLoading: false,
    model: null,
    showLoading: true,
    currentPage: 1,
    totalPages: 1,
    selectedAlertIds: [],
    deviceIdFilter: null,
    alertTypeFilter: null,
  );
}

class GetAlertsListLoading extends GetAlertsListState {
  GetAlertsListLoading({
    required GetAlertsModel? previousModel,
    required super.currentPage,
    required super.totalPages,
    required super.showLoading,
    required super.selectedAlertIds,
    super.deviceIdFilter,
    super.alertTypeFilter,
  }) : super(
    isLoading: true,
    model: previousModel,
  );
}

class GetAlertsListLoaded extends GetAlertsListState {
  GetAlertsListLoaded({
    required GetAlertsModel super.model,
    required super.currentPage,
    required super.totalPages,
    required super.selectedAlertIds,
    super.deviceIdFilter,
    super.alertTypeFilter,
  }) : super(
    isLoading: false,
    showLoading: false,
  );
}

class GetAlertsListError extends GetAlertsListState {
  GetAlertsListError({
    required String message,
    required GetAlertsModel? previousModel,
    required super.currentPage,
    required super.totalPages,
    required super.selectedAlertIds,
    super.deviceIdFilter,
    super.alertTypeFilter,
  }) : super(
    isLoading: false,
    model: previousModel,
    errorMessage: message,
    showLoading: false,
  );
}
