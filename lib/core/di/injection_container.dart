import 'package:get_it/get_it.dart';
import 'package:bonssight/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bonssight/features/history/presentation/cubit/history_cubit.dart';
import 'package:bonssight/features/analysis/presentation/cubit/analysis_cubit.dart';
import 'package:bonssight/features/analysis/data/datasources/analysis_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Data Sources
  sl.registerLazySingleton(() => AnalysisRemoteDataSource());

  // Cubits
  sl.registerFactory(() => AuthCubit());
  sl.registerFactory(() => HistoryCubit());
  sl.registerFactory(() => AnalysisCubit(remoteDataSource: sl()));
}
