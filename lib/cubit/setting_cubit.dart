import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit() : super(SettingInitial()) {
    // Automatically fetch settings when cubit is created
    getSharedPreferenceSettings();
  }

  bool? notificationsEnabled = true;
  String? userID;
  SharedPreferences? sp;

  Future<void> getSharedPreferenceSettings() async {
    try {
      emit(SettingLoading());
      sp = await SharedPreferences.getInstance();

      notificationsEnabled = sp!.getBool('notifications') ?? true;
      userID = sp!.getString('userid');

      if (userID == null || userID!.isEmpty) {
        emit(SettingError('User ID not found. Please log in again.'));
        return;
      }

      emit(SettingComplete(userID: userID!, notificationsEnabled: notificationsEnabled ?? true));
    } catch (e) {
      emit(SettingError('Failed to load settings: $e'));
    }
  }

  void setNotifications() {
    emit(SettingLoading());
    notificationsEnabled = !(notificationsEnabled ?? true);

    sp!.setBool('notifications', notificationsEnabled!);
    emit(SettingComplete(userID: userID ?? '', notificationsEnabled: notificationsEnabled ?? true));
  }
}