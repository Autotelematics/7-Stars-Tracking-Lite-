part of 'setting_cubit.dart';

abstract class SettingState {
  const SettingState();
}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingError extends SettingState {
  final String message;
  SettingError(this.message);
}

class SettingComplete extends SettingState {
  final String userID;
  final bool notificationsEnabled;
  SettingComplete({required this.userID, required this.notificationsEnabled});
}