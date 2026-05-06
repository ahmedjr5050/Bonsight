import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bonssight/features/analysis/data/models/analysis_result_model.dart';
import 'package:bonssight/features/analysis/data/datasources/analysis_remote_data_source.dart';

abstract class AnalysisState extends Equatable {
  const AnalysisState();

  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}

class AnalysisImageSelected extends AnalysisState {
  final XFile image;
  const AnalysisImageSelected(this.image);

  @override
  List<Object?> get props => [image.path];
}

class AnalysisProcessing extends AnalysisState {
  final XFile image;
  const AnalysisProcessing(this.image);

  @override
  List<Object?> get props => [image.path];
}

class AnalysisCompleted extends AnalysisState {
  final XFile image;
  final AnalysisResult result;

  const AnalysisCompleted(this.image, this.result);

  @override
  List<Object?> get props => [image.path, result];
}

class AnalysisError extends AnalysisState {
  final XFile image;
  final String message;

  const AnalysisError(this.image, this.message);

  @override
  List<Object?> get props => [image.path, message];
}

class AnalysisCubit extends Cubit<AnalysisState> {
  final AnalysisRemoteDataSource remoteDataSource;

  AnalysisCubit({required this.remoteDataSource}) : super(AnalysisInitial());

  void selectImage(XFile image) {
    emit(AnalysisImageSelected(image));
  }

  Future<void> startAnalysis(XFile image) async {
    emit(AnalysisProcessing(image));
    try {
      final result = await remoteDataSource.analyzeImage(image);
      emit(AnalysisCompleted(image, result));
    } catch (e) {
      emit(AnalysisError(image, e.toString()));
    }
  }

  void reset() {
    emit(AnalysisInitial());
  }
}
