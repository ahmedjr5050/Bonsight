import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Map<String, dynamic>> items;

  const HistoryLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryInitial()) {
    loadHistory();
  }

  void loadHistory() {
    // Mock user data matching the requested UI visually
    final mockItems = List.generate(6, (index) => {
      'id': 8271 - index,
      'date': 'Oct 24, 2025',
      'type': 'Digital Radiography',
    });
    emit(HistoryLoaded(mockItems));
  }
}
