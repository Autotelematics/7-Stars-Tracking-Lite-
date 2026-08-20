part of 'get_reports_cubit.dart';

class GetReportsState {
  const GetReportsState();
}

class GetReportsInitial extends GetReportsState {}

class GetReportsLoading extends GetReportsState {}

class GetReportsError extends GetReportsState {
  String message;
  GetReportsError({required this.message});
}

class GetReportsLoadingComplete extends GetReportsState {
  GetReportModel getReportModel;
  GetReportsLoadingComplete({required this.getReportModel});
}
