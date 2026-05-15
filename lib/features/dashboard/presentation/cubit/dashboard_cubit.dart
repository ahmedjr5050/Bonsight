import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bonssight/features/history/data/datasources/history_remote_data_source.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalScans;
  final int anomaliesDetected;
  final List<Map<String, dynamic>> recentAnalyses;

  const DashboardLoaded({
    required this.totalScans,
    required this.anomaliesDetected,
    required this.recentAnalyses,
  });

  @override
  List<Object> get props => [totalScans, anomaliesDetected, recentAnalyses];
}

class DashboardError extends DashboardState {}

class DashboardCubit extends Cubit<DashboardState> {
  final HistoryRemoteDataSource _dataSource;
  final String _uid;

  DashboardCubit({required HistoryRemoteDataSource dataSource, required String uid})
      : _dataSource = dataSource,
        _uid = uid,
        super(DashboardInitial()) {
    load();
  }

  Future<void> load() async {
    emit(DashboardLoading());
    final stats = await _dataSource.getDashboardStats(_uid);
    emit(DashboardLoaded(
      totalScans: stats['total'] as int,
      anomaliesDetected: stats['withDetections'] as int,
      recentAnalyses: List<Map<String, dynamic>>.from(stats['recent'] as List),
    ));
  }
}
