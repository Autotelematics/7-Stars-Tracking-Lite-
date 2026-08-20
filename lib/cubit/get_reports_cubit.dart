import 'package:autotelematic_new_app/model/getreportmodel.dart';
import 'package:autotelematic_new_app/model/viewreportinitialdata.dart';
import 'package:autotelematic_new_app/repository/get_reportsrepository.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';

part 'get_reports_state.dart';

class GetReportsCubit extends Cubit<GetReportsState> {
  GetReportsCubit() : super(GetReportsInitial());

  GetReportsRepository getReportsRepository = GetReportsRepository();
  GetReportModel getReportModel = GetReportModel();

  void fetchReportsfromAPI(ViewReportIntialData viewReportIntialData) async {
    emit(GetReportsLoading());
    String getReportDateTime =
        '&date_from=${viewReportIntialData.fromDate}'
        '&devices[]=${viewReportIntialData.deviceID}'
        '&date_to=${viewReportIntialData.toDate}'
        '&from_time=${viewReportIntialData.fromTime}'
        '&to_time=${viewReportIntialData.toTime}'
        '&format=${viewReportIntialData.reportFormat}'
        '&type=${viewReportIntialData.reportType}'
        '&speed_limit=${viewReportIntialData.speed_limit}'
        '&geofences[]=${viewReportIntialData.geofences}'
        '&ignition_off=${viewReportIntialData.ignition_off}';

    String? userApiHashKey = await UserSessions.getUserApiHash();
    try {
      getReportModel = await getReportsRepository.getReportsFromAPI(
          userApiHashKey.toString(), getReportDateTime);
      emit(GetReportsLoadingComplete(getReportModel: getReportModel));
    } catch (e) {
      emit(GetReportsError(message: 'Error while fetching report..'));
      rethrow;
    }
  }
}
