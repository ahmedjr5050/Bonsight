import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bonssight/features/analysis/data/models/analysis_result_model.dart';
import 'package:bonssight/features/analysis/data/datasources/analysis_remote_data_source.dart';
import 'package:bonssight/features/history/data/datasources/history_remote_data_source.dart';

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
  final HistoryRemoteDataSource historyDataSource;
  final String uid;

  AnalysisCubit({
    required this.remoteDataSource,
    required this.historyDataSource,
    required this.uid,
  }) : super(AnalysisInitial());

  void selectImage(XFile image) {
    emit(AnalysisImageSelected(image));
  }

  Future<void> startAnalysis(XFile image) async {
    emit(AnalysisProcessing(image));
    try {
      final imageBytes = await image.readAsBytes();
      final result = await remoteDataSource.analyzeImage(image);

      // Show result immediately — don't wait for Firebase save
      emit(AnalysisCompleted(image, result));

      // Save to Firestore/Storage in the background
      historyDataSource.saveAnalysis(
        uid: uid,
        imageName: image.name,
        imageBytes: imageBytes,
        result: result,
      ).catchError((e) {
        log('Background save failed: $e');
      });
    } catch (e) {
      emit(AnalysisError(image, e.toString()));
    }
  }

  void reset() {
    emit(AnalysisInitial());
  }
}
