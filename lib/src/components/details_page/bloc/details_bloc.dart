import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leaf_disease_app/src/domain/disease_detection/leaf_disease_detection_repository.dart';
import 'package:leaf_disease_app/src/components/details_page/bloc/details_state.dart';
import 'package:image/image.dart' as img;
import 'package:leaf_disease_app/src/domain/settings/repository/settings_repository.dart';

class DetailsCubit extends Cubit<DetailsState> {
  final LeafDiseaseDetectionRepository leafDiseaseDetectionRepository;
  final SettingsRepository settingsRepository;

  DetailsCubit(super.initialState, {required this.leafDiseaseDetectionRepository, required this.settingsRepository}) {
    _warmup();
  }

  void _warmup() async {
    if (state is DetailsClassifyingState) {
      final image = await img.decodeImageFile((state as DetailsClassifyingState).imagePath);
      if (image == null) {
        if (isClosed) {
          return;
        }
        emit(const DetailsClassificationFailedState());
        return;
      }
      final results =
          await leafDiseaseDetectionRepository.detectDiseases(image, settingsRepository.settings.activeLeafType);
      if (isClosed) {
        return;
      }
      emit(DetailsClassifiedState(results));
    }
  }
}
