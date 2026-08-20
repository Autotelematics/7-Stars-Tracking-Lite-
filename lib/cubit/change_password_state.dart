// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:autotelematic_new_app/model/changepassowrdmodel.dart';

/// Base state for the ChangePasswordCubit.
abstract class ChangePasswordState {
  const ChangePasswordState();
}

/// Initial state when the cubit is first created.
class ChangePasswordInitial extends ChangePasswordState {}

/// State indicating that the password change request is in progress.
class ChangePasswordLoading extends ChangePasswordState {}

/// State emitted when an error occurs during the password change.
/// Contains the error message from the API response.
class ChangePasswordError extends ChangePasswordState {
  final String message;

  ChangePasswordError({
    required this.message,
  });
}

/// State emitted when the password change is successful.
class ChangePasswordComplete extends ChangePasswordState {
  final ChangePasswordModel changePasswordModel;
  final String? successMessage;

  ChangePasswordComplete({
    required this.changePasswordModel,
    this.successMessage,
  });
}