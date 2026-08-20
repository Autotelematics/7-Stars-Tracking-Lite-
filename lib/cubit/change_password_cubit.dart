import 'package:autotelematic_new_app/model/changepassowrdmodel.dart';
import 'package:autotelematic_new_app/repository/changepassword_repository.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordInitial());
  ChangePasswordRepository changePasswordRepository =
      ChangePasswordRepository();

  void changePasswrod(String password) async {
    String? userApiHashKey = await UserSessions.getUserApiHash();

    try {
      emit(ChangePasswordLoading());
      ChangePasswordModel changePasswordModel = await changePasswordRepository
          .changePasswordFromAPI(userApiHashKey.toString(), password);
      // Extract success message from API response, if available
      String? successMessage;
      if (changePasswordModel.toJson().containsKey('message')) {
        successMessage = changePasswordModel.toJson()['message']?.toString();
      }
      emit(ChangePasswordComplete(
        changePasswordModel: changePasswordModel,
        successMessage: successMessage ?? 'Password changed successfully!',
      ));
    } catch (e) {
      String errorMessage = 'Failed to change password. Please try again.';
      if (e is DioException && e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'].toString();
        } else {
          errorMessage = e.message ?? errorMessage;
        }
      } else {
        errorMessage = e.toString();
      }
      emit(ChangePasswordError(message: errorMessage));
    }
  }
}
