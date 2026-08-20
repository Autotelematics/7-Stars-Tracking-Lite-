import 'package:autotelematic_new_app/model/get_device_group_model.dart';
import 'package:autotelematic_new_app/repository/get_device_group_repository.dart';
import 'package:bloc/bloc.dart';

import 'get_device_group_state.dart';

class GetDeviceGroupCubit extends Cubit<GetDeviceGroupState> {
  final GetDeviceGroupRepository getRepository;

  int _currentPage = 1;
  int _totalPages = 1;
  GetDeviceGroupModel? _lastValidModel;

  GetDeviceGroupCubit({
    required this.getRepository,
  }) : super(GetDeviceGroupInitial());

  Future<void> fetchDeviceGroups({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    final hasData =
        _lastValidModel != null && _lastValidModel!.items!.isNotEmpty;
    final showLoading = isRefresh || !hasData;

    if (showLoading) {
      emit(GetDeviceGroupLoading(
        previousModel: _lastValidModel,
        currentPage: _currentPage,
        totalPages: _totalPages,
        showLoading: true,
      ));
    }

    try {
      final result = await getRepository.getDeviceGroupApi(page: _currentPage);
      if (result != null) {
        // Assuming the API returns total and perPage fields; adjust if different
        // Since GetDeviceGroupModel doesn't have total/perPage, we'll assume a default or API-provided value
        // If the API provides total and perPage, update the model to include them
        _totalPages = 1; // Placeholder; update based on actual API response

        if (isRefresh) {
          _lastValidModel = result;
        } else {
          _lastValidModel = _lastValidModel?.copyWith(
                items: [...?_lastValidModel!.items, ...?result.items],
              ) ??
              result;
        }

        emit(GetDeviceGroupLoaded(
          model: _lastValidModel!,
          currentPage: _currentPage,
          totalPages: _totalPages,
        ));

        _currentPage++;
        // print(_currentPage);
      } else {
        emit(GetDeviceGroupError(
          message: "No data received",
          previousModel: _lastValidModel,
          currentPage: _currentPage,
          totalPages: _totalPages,
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

      if (_lastValidModel != null) {
        return;
      }

      emit(GetDeviceGroupError(
        message: userFriendlyMessage,
        previousModel: _lastValidModel,
        currentPage: _currentPage,
        totalPages: _totalPages,
      ));
    }
  }
}
