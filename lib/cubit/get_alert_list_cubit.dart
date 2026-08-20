import 'package:autotelematic_new_app/cubit/get_alert_list_state.dart';
import 'package:autotelematic_new_app/model/get_alerts_list_model.dart';
import 'package:autotelematic_new_app/repository/delete_alert_repository.dart';
import 'package:autotelematic_new_app/repository/get_alert_list_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class GetAlertsListCubit extends Cubit<GetAlertsListState> {
  final GetAlertListRepository getRepository;
  final DeleteAlertRepository deleteRepository;

  int _currentPage = 1;
  int _totalPages = 1;
  int? _grandTotal;
  GetAlertsModel? _lastValidModel;
  List<String> alertTypeList = ['All'];

  // --- ADD THESE ---
  String? _deviceIdFilter;
  String? _alertTypeFilter;

  Map<String, int> get alertTypeCounts {
    final model = state.model ?? _lastValidModel;
    if (model == null) return {};
    final Map<String, int> map = Map<String, int>.from(model.counts ?? {});
    map['All'] = _grandTotal ?? model.total ?? 0;
    return map;
  }
  // ------------------

  GetAlertsListCubit({
    required this.getRepository,
    required this.deleteRepository,
  }) : super(GetAlertsListInitial());

  // Call this from UI to update filters (call fetchAlertsList after changing)
  void setDeviceIdFilter(int? deviceId) {
    _deviceIdFilter = deviceId?.toString();
  }

  // Update filter method
  void setAlertTypeFilter(String? alertType) {
    if (alertType == null || alertType == "All") {
      _alertTypeFilter = null;
    } else {
      _alertTypeFilter = alertType; // Use as is
    }
  }

  void clearFilters() {
    _deviceIdFilter = null;
    _alertTypeFilter = null;
  }

  Future<void> fetchAlertsList({
    bool isRefresh = false,
    String? deviceId,
    String? alertType,
    required BuildContext dialogContext,
  }) async {
    if (isRefresh) {
      _currentPage = 1;
      _lastValidModel = null;
    }

    // Save current filters if passed from UI (or use cubit vars)
    if (deviceId != null) _deviceIdFilter = deviceId;
    if (alertType != null) _alertTypeFilter = alertType;

    final showLoading = isRefresh || _lastValidModel == null;

    if (showLoading) {
      emit(GetAlertsListLoading(
        previousModel: _lastValidModel,
        currentPage: _currentPage,
        totalPages: _totalPages,
        showLoading: true,
        selectedAlertIds: state.selectedAlertIds,
      ));
    } else if (_currentPage <= _totalPages) {
      emit(GetAlertsListLoading(
        previousModel: _lastValidModel,
        currentPage: _currentPage,
        totalPages: _totalPages,
        showLoading: false,
        selectedAlertIds: state.selectedAlertIds,
      ));
    }

    try {
      final result = await getRepository.getAlertListApi(
        page: _currentPage,
        deviceId: _deviceIdFilter,
        alertType: _alertTypeFilter,
        dialogContext: dialogContext,
      );

// Only set grand total when there are no filters
      if (((_deviceIdFilter == null) || (_deviceIdFilter?.isEmpty ?? true)) &&
          ((_alertTypeFilter == null) || (_alertTypeFilter?.isEmpty ?? true))) {
        _grandTotal = result?.total;
      }
      if (result != null) {
        _totalPages = (result.total / result.perPage).ceil();
        _totalPages = (result.total / result.perPage).ceil();

        // After fetching counts
        final countsMap = result.counts; // Map<String, int>
        final List<String> typeLabels = countsMap.keys.toList();
        alertTypeList = ['All', ...typeLabels];

        // -------------------------------------------------------------

        // Remove duplicates by filtering unique IDs
        final newItems =
            _lastValidModel == null || _lastValidModel!.items.isEmpty
                ? result.items
                : result.items
                    .where((newItem) => !_lastValidModel!.items
                        .any((item) => item.id == newItem.id))
                    .toList();
        if (isRefresh) {
          _lastValidModel = result.copyWith(items: newItems);
        } else {
          _lastValidModel = _lastValidModel?.copyWith(
                items: [...?_lastValidModel?.items, ...newItems],
                total: result.total,
              ) ??
              result.copyWith(items: newItems);
        }

        // Filter out invalid selected IDs
        final validSelectedIds = state.selectedAlertIds
            .where((id) => _lastValidModel!.items.any((item) => item.id == id))
            .toList();

        emit(GetAlertsListLoaded(
          model: _lastValidModel!,
          currentPage: _currentPage,
          totalPages: _totalPages,
          selectedAlertIds: isRefresh ? [] : validSelectedIds,
        ));

        if (_currentPage < _totalPages) {
          _currentPage++;
        }
      } else {
        emit(GetAlertsListError(
          message: "No data received",
          previousModel: _lastValidModel,
          currentPage: _currentPage,
          totalPages: _totalPages,
          selectedAlertIds: state.selectedAlertIds,
        ));
      }
    } catch (e) {
      String userFriendlyMessage = e.toString();
      if (userFriendlyMessage.contains('unserialize()')) {
        userFriendlyMessage =
            'Server is synchronizing data. Please try again in a moment.';
      } else if (userFriendlyMessage.contains('Exception:')) {
        userFriendlyMessage =
            userFriendlyMessage.replaceAll('Exception:', '').trim();
      } else if (userFriendlyMessage.contains('SocketException') ||
          userFriendlyMessage.contains('ClientException')) {
        userFriendlyMessage =
            'No internet connection. Please check your network.';
      }

      // If we already have data, don't show full screen error (silent error)
      if (_lastValidModel != null) {
        return;
      }

      emit(GetAlertsListError(
        message: userFriendlyMessage,
        previousModel: _lastValidModel,
        currentPage: _currentPage,
        totalPages: _totalPages,
        selectedAlertIds: state.selectedAlertIds,
      ));
    }
  }

  Future<void> deleteAlerts(List<int> alertIds) async {
    try {
      emit(GetAlertsListLoading(
        previousModel: _lastValidModel,
        currentPage: _currentPage,
        totalPages: _totalPages,
        showLoading: false,
        selectedAlertIds: state.selectedAlertIds,
      ));

      final success = await deleteRepository.deleteAlert(alertIds: alertIds);

      if (success) {
        if (_lastValidModel != null) {
          final updatedItems = _lastValidModel!.items
              .where((item) => !alertIds.contains(item.id))
              .toList();
          _lastValidModel = _lastValidModel!.copyWith(
            items: updatedItems,
            total: _lastValidModel!.total - alertIds.length,
          );
        }

        emit(GetAlertsListLoaded(
          model: _lastValidModel ??
              GetAlertsModel(
                status: 0,
                page: 1,
                perPage: 10,
                total: 0,
                counts: <String, int>{},
                items: [],
                message: null,
              ),
          currentPage: _currentPage,
          totalPages: _totalPages,
          selectedAlertIds: [],
        ));
      } else {
        throw Exception('Failed to delete alerts');
      }
    } catch (e) {
      String userFriendlyMessage = e.toString();
      if (userFriendlyMessage.contains('unserialize()')) {
        userFriendlyMessage = 'Server is synchronizing data. Please try again in a moment.';
      } else if (userFriendlyMessage.contains('Exception:')) {
        userFriendlyMessage = userFriendlyMessage.replaceAll('Exception:', '').trim();
      }

      emit(GetAlertsListError(
        message: userFriendlyMessage,
        previousModel: _lastValidModel,
        currentPage: _currentPage,
        totalPages: _totalPages,
        selectedAlertIds: state.selectedAlertIds,
      ));
    }
  }

  void toggleSelection(int alertId) {
    final currentSelections = List<int>.from(state.selectedAlertIds);
    if (currentSelections.contains(alertId)) {
      currentSelections.remove(alertId);
    } else {
      currentSelections.add(alertId);
    }
    emit(GetAlertsListLoaded(
      model: state.model ?? _lastValidModel!,
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      selectedAlertIds: currentSelections,
    ));
  }

  void clearSelection() {
    final model = state.model ??
        _lastValidModel ??
        GetAlertsModel(
          status: 0,
          page: 1,
          perPage: 10,
          total: 0,
          counts: <String, int>{},
          items: [],
          message: null,
        );

    emit(GetAlertsListLoaded(
      model: model,
      currentPage: state.currentPage,
      totalPages: state.totalPages,
      selectedAlertIds: [],
    ));
  }
}
