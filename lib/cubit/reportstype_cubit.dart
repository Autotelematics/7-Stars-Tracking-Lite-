import 'package:autotelematic_new_app/cubit/reportstype_state.dart';
import 'package:autotelematic_new_app/model/reporttypemodel.dart';
import 'package:autotelematic_new_app/repository/reporttyperepository.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

class ReportstypeCubit extends Cubit<ReportstypeState> {
  ReportstypeCubit() : super(ReportstypeInitial());

  final ReportTypeRepository reportTypeRepository = ReportTypeRepository();
  ReportTypeModel reportTypeModel = ReportTypeModel();

  void fetchReportsTypeFromApi() async {
    emit(ReportstypeLoading());
    try {
      final String? userApiHashKey = await UserSessions.getUserApiHash();
      if (userApiHashKey == null || userApiHashKey.isEmpty) {
        emit(ReportstypeError('User API hash key is missing or invalid'));
        return;
      }

      reportTypeModel = await reportTypeRepository.getReportsTypeFromAPI(userApiHashKey);
      print("Report Types fetched: ${reportTypeModel.items?.length ?? 0} items");
      if (reportTypeModel.items != null) {
        for (var item in reportTypeModel.items!) {
          print("Report: ${item.name} (Type: ${item.type})");
        }
      }
      emit(ReportstypeLoadingComplete(reportTypeModel));
    } catch (e) {
      final errorMessage = e is DioException
          ? 'Network error: ${e.message}'
          : 'Failed to load report types: $e';
      emit(ReportstypeError(errorMessage));
    }
  }
}