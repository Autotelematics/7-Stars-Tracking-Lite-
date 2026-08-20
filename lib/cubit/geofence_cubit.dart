import 'package:autotelematic_new_app/repository/geofence_repository.dart'
    show GeofenceRepository;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'geofencing_state.dart';

class GeofencingCubit extends Cubit<GeofencingState> {
  GeofencingCubit() : super(GeofencingInitial());
  final GeofenceRepository repository = GeofenceRepository();

  Future<void> loadGeofencingData() async {
    emit(GeofencingLoading());
    try {
      final model = await repository.fetchGeofences();
// Initialize all geofences with isSelected = false
      for (var geofence in model.items.geofences) {
        geofence.isSelected = false;
      }
      emit(GeofencingLoaded(model));
    } catch (e) {
      emit(GeofencingError(e.toString()));
    }
  }


}
