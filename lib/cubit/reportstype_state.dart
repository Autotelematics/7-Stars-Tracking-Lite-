import 'package:autotelematic_new_app/model/reporttypemodel.dart';
import 'package:equatable/equatable.dart';

abstract class ReportstypeState extends Equatable {
  const ReportstypeState();

  @override
  List<Object?> get props => [];
}

class ReportstypeInitial extends ReportstypeState {
  const ReportstypeInitial();
}

class ReportstypeLoading extends ReportstypeState {
  const ReportstypeLoading();
}

class ReportstypeError extends ReportstypeState {
  final String message;

  const ReportstypeError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportstypeLoadingComplete extends ReportstypeState {
  final ReportTypeModel reportTypeModel;

  const ReportstypeLoadingComplete(this.reportTypeModel);

  @override
  List<Object?> get props => [reportTypeModel];
}