import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:bonssight/features/history/data/datasources/history_remote_data_source.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Map<String, dynamic>> items;

  const HistoryLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRemoteDataSource _dataSource;
  final String _uid;

  HistoryCubit({required HistoryRemoteDataSource dataSource, required String uid})
      : _dataSource = dataSource,
        _uid = uid,
        super(HistoryInitial()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    emit(HistoryLoading());
    final raw = await _dataSource.getHistory(_uid);
    final fmt = DateFormat('MMM d, yyyy • h:mm a');
    final items = raw.map((entry) {
      final ts = entry['timestamp'] as DateTime?;
      final detections = entry['detections'] as List;
      return {
        'id': entry['id'],
        'imageName': entry['imageName'],
        'imageUrl': entry['imageUrl'],
        'date': ts != null ? fmt.format(ts) : 'Unknown date',
        'timestamp': ts,
        'detections': detections,
        'count': detections.length,
        'severity': detections.isNotEmpty
            ? (detections.any((d) => (d as Map)['severity'] == 'Severe') ? 'Severe' : 'Moderate')
            : 'None',
      };
    }).toList();
    emit(HistoryLoaded(items));
  }
}
