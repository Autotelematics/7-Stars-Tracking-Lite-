import 'package:bloc/bloc.dart';
import 'package:autotelematic_new_app/repository/geofence_repository.dart';
import '../model/geofence_model.dart';

abstract class GeofencingState {}

class GeofencingInitial extends GeofencingState {}

class GeofencingLoading extends GeofencingState {}

class GeofencingLoaded extends GeofencingState {
  final GeofenceResponse model;
  GeofencingLoaded(this.model);
}

class GeofencingError extends GeofencingState {
  final String message;
  GeofencingError(this.message);
}

class GeofencingCubit extends Cubit<GeofencingState> {

  GeofencingCubit() : super(GeofencingInitial());

  Future<void> loadGeofencingData() async {
    emit(GeofencingLoading());
    GeofenceRepository repository=GeofenceRepository();
    try {
      final model = await repository.fetchGeofences();
      emit(GeofencingLoaded(model));
    } catch (e) {
      emit(GeofencingError(e.toString()));
    }
  }

  void toggleGeofenceSelection(int index, bool value) {
    if (state is GeofencingLoaded) {
      final currentState = state as GeofencingLoaded;
      final updatedGeofences =
      List<Geofence>.from(currentState.model.items.geofences);
      updatedGeofences[index].isSelected = value;
      emit(GeofencingLoaded(GeofenceResponse(
        items: GeofenceItems(geofences: updatedGeofences),
        status: currentState.model.status,
      )));
    }
  }}