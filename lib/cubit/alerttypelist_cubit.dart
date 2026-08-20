import 'package:autotelematic_new_app/model/alertypelistmodel.dart';
import 'package:autotelematic_new_app/repository/alertstypelist_repository.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';
part 'alerttypelist_state.dart';

class AlertsTypeListCubit extends Cubit<AlertsTypeListState> {
  AlertsTypeListCubit() : super(AlerttypelistLoading());
  AlertListRepository alertListRepository = AlertListRepository();

  void fetchAlertsTypeListFromAPI() async {
    String? userApiHashKey = await UserSessions.getUserApiHash();
    try {
      emit(AlerttypelistLoading());
      AlertsListModel alertsTypeList = await alertListRepository
          .alertsTypeListApi(userApiHashKey.toString());
      emit(AlerttypelistComplete(alertsTypeList: alertsTypeList));
    } catch (e) {
      emit(AlerttypelistError());
    }
  }

  void changeAlertsTypeStatus(String alertID, String activationStatus) async {
    String? userApiHashKey = await UserSessions.getUserApiHash();
    try {
      alertListRepository
          .changeAlertValueApi(
              userApiHashKey.toString(), alertID, activationStatus)
          .then((value) => fetchAlertsTypeListFromAPI());
    } catch (e) {
      emit(AlerttypelistError());
    }
  }
}
