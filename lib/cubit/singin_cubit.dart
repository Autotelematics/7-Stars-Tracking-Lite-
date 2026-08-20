import 'package:autotelematic_new_app/model/user_signin_model.dart';
import 'package:autotelematic_new_app/repository/auth_repository.dart';
import 'package:autotelematic_new_app/res/push_notification_service.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

part 'singin_state.dart';

class SinginCubit extends Cubit<SinginState> {
  SinginCubit() : super(SinginInitial());
  final AuthRepository authRepository = AuthRepository();
  final UserSessions userSessions = UserSessions();

  late UserLoginData userLoginData;

  Future<void> signIn(dynamic data) async {
    emit(SigninLoadingState());
    try {
      // 1) Auth first (no notification checks here)
      userLoginData = await authRepository.signinAPI(data);

      // 2) Save session
      await userSessions.saveUserSession(userLoginData, data['email']);

      // 3) Best-effort: if already authorized, submit token; otherwise skip
      _trySubmitFcmTokenIfAuthorized();

      // 4) Print permissions for debugging
      if (userLoginData.permissions != null) {
        final permissionsMap = userLoginData.permissions!.toJson();
        print("--- USER PERMISSIONS ---");
        permissionsMap.forEach((key, value) {
          if (value is Map && (value['view'] == true || value['edit'] == true || value['remove'] == true)) {
            print("$key: $value");
          }
        });
        print("-------------------------");
      }

      // 5) Success regardless of notification status
      emit(SignInSuccessState(userLoginData));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(SigninErrorState(errorMessage));
    }
  }

  /// Fire-and-forget. Never blocks login, never throws, never prompts.
  Future<void> _trySubmitFcmTokenIfAuthorized() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (authorized) {
        await FirebaseMessaging.instance.setAutoInitEnabled(true);
        // Optionally ensure token exists
        await FirebaseMessaging.instance.getToken();
        await PushNotificationService().submitFcmTokenIfLoggedIn();
      }
      // If denied/notDetermined, do nothing. User can enable later in-app.
    } catch (_) {
      // Silently ignore; notifications are optional.
    }
  }
}
