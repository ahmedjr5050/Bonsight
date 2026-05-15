import 'package:get_it/get_it.dart';
import 'package:bonssight/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bonssight/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bonssight/features/history/data/datasources/history_remote_data_source.dart';
import 'package:bonssight/features/history/presentation/cubit/history_cubit.dart';
import 'package:bonssight/features/analysis/presentation/cubit/analysis_cubit.dart';
import 'package:bonssight/features/analysis/data/datasources/analysis_remote_data_source.dart';
import 'package:bonssight/features/dashboard/presentation/cubit/dashboard_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => AuthRemoteDataSource());
  sl.registerLazySingleton(() => AnalysisRemoteDataSource());
  sl.registerLazySingleton(() => HistoryRemoteDataSource());

  sl.registerFactory(() => AuthCubit(authDataSource: sl()));

  sl.registerFactoryParam<HistoryCubit, String, void>(
    (uid, _) => HistoryCubit(dataSource: sl(), uid: uid),
  );
  sl.registerFactoryParam<AnalysisCubit, String, void>(
    (uid, _) => AnalysisCubit(remoteDataSource: sl(), historyDataSource: sl(), uid: uid),
  );
  sl.registerFactoryParam<DashboardCubit, String, void>(
    (uid, _) => DashboardCubit(dataSource: sl(), uid: uid),
  );
}
