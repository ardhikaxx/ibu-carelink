import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Pregnancy
import 'features/pregnancy/data/datasources/pregnancy_local_data_source.dart';
import 'features/pregnancy/data/datasources/pregnancy_remote_data_source.dart';
import 'features/pregnancy/data/repositories/pregnancy_repository_impl.dart';
import 'features/pregnancy/domain/repositories/pregnancy_repository.dart';
import 'features/pregnancy/domain/usecases/pregnancy_usecases.dart';
import 'features/pregnancy/presentation/bloc/pregnancy_bloc.dart';

// Kick Counter
import 'features/kick_counter/data/datasources/kick_counter_local_data_source.dart';
import 'features/kick_counter/data/datasources/kick_counter_remote_data_source.dart';
import 'features/kick_counter/data/repositories/kick_counter_repository_impl.dart';
import 'features/kick_counter/domain/repositories/kick_counter_repository.dart';
import 'features/kick_counter/domain/usecases/kick_counter_usecases.dart';
import 'features/kick_counter/presentation/bloc/kick_counter_bloc.dart';

// Contraction Timer
import 'features/contraction_timer/data/datasources/contraction_local_data_source.dart';
import 'features/contraction_timer/data/datasources/contraction_remote_data_source.dart';
import 'features/contraction_timer/data/repositories/contraction_repository_impl.dart';
import 'features/contraction_timer/domain/repositories/contraction_repository.dart';
import 'features/contraction_timer/domain/usecases/contraction_usecases.dart';
import 'features/contraction_timer/presentation/bloc/contraction_timer_bloc.dart';

// Child Growth
import 'features/child_growth/data/datasources/child_local_data_source.dart';
import 'features/child_growth/data/datasources/child_remote_data_source.dart';
import 'features/child_growth/data/repositories/child_growth_repository_impl.dart';
import 'features/child_growth/domain/repositories/child_growth_repository.dart';
import 'features/child_growth/domain/usecases/child_growth_usecases.dart';
import 'features/child_growth/presentation/bloc/child_growth_bloc.dart';

// Immunization
import 'features/immunization/data/datasources/immunization_local_data_source.dart';
import 'features/immunization/data/datasources/immunization_remote_data_source.dart';
import 'features/immunization/data/repositories/immunization_repository_impl.dart';
import 'features/immunization/domain/repositories/immunization_repository.dart';
import 'features/immunization/domain/usecases/immunization_usecases.dart';
import 'features/immunization/presentation/bloc/immunization_bloc.dart';

// Milestones
import 'features/milestones/data/datasources/milestone_local_data_source.dart';
import 'features/milestones/data/datasources/milestone_remote_data_source.dart';
import 'features/milestones/data/repositories/milestone_repository_impl.dart';
import 'features/milestones/domain/repositories/milestone_repository.dart';
import 'features/milestones/domain/usecases/milestone_usecases.dart';
import 'features/milestones/presentation/bloc/milestone_bloc.dart';

// Sync
import 'features/sync/presentation/bloc/sync_bloc.dart';

// Emergency
import 'features/emergency/data/datasources/emergency_remote_data_source.dart';
import 'features/emergency/data/repositories/emergency_repository_impl.dart';
import 'features/emergency/data/services/location_service_impl.dart';
import 'features/emergency/domain/repositories/emergency_repository.dart';
import 'features/emergency/domain/services/location_service.dart';
import 'features/emergency/domain/usecases/trigger_sos_alert.dart';
import 'features/emergency/presentation/bloc/emergency_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  await GoogleSignIn.instance.initialize(
    clientId: kIsWeb ? '985223544295-aanjof8t40vr9kto213lb0p0nu3k5qvu.apps.googleusercontent.com' : null,
    serverClientId: '985223544295-aanjof8t40vr9kto213lb0p0nu3k5qvu.apps.googleusercontent.com',
  );
  sl.registerLazySingleton(() => GoogleSignIn.instance);

  //! Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl(), googleSignIn: sl()),
  );
  sl.registerLazySingleton<PregnancyLocalDataSource>(
    () => PregnancyLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<PregnancyRemoteDataSource>(
    () => PregnancyRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<KickCounterLocalDataSource>(
    () => KickCounterLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<KickCounterRemoteDataSource>(
    () => KickCounterRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ContractionLocalDataSource>(
    () => ContractionLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<ContractionRemoteDataSource>(
    () => ContractionRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ChildLocalDataSource>(
    () => ChildLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<ChildRemoteDataSource>(
    () => ChildRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ImmunizationLocalDataSource>(
    () => ImmunizationLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<ImmunizationRemoteDataSource>(
    () => ImmunizationRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<MilestoneLocalDataSource>(
    () => MilestoneLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<MilestoneRemoteDataSource>(
    () => MilestoneRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<EmergencyRemoteDataSource>(
    () => EmergencyRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );
  sl.registerLazySingleton<LocationService>(
    () => LocationServiceImpl(),
  );

  //! Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<PregnancyRepository>(
    () => PregnancyRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<KickCounterRepository>(
    () => KickCounterRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<ContractionRepository>(
    () => ContractionRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<ChildGrowthRepository>(
    () => ChildGrowthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<ImmunizationRepository>(
    () => ImmunizationRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<MilestoneRepository>(
    () => MilestoneRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<EmergencyRepository>(
    () => EmergencyRepositoryImpl(remoteDataSource: sl()),
  );

  //! Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(() => SaveUserRoleUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton(() => GetActivePregnancyUseCase(sl()));
  sl.registerLazySingleton(() => CreatePregnancyUseCase(sl()));
  sl.registerLazySingleton(() => LogSymptomUseCase(sl()));
  sl.registerLazySingleton(() => GetSymptomLogsUseCase(sl()));

  sl.registerLazySingleton(() => SaveKickSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetKickSessionsUseCase(sl()));

  sl.registerLazySingleton(() => SaveContractionUseCase(sl()));
  sl.registerLazySingleton(() => GetContractionsUseCase(sl()));

  sl.registerLazySingleton(() => GetChildrenUseCase(sl()));
  sl.registerLazySingleton(() => AddChildUseCase(sl()));
  sl.registerLazySingleton(() => LogGrowthUseCase(sl()));
  sl.registerLazySingleton(() => GetGrowthLogsUseCase(sl()));

  sl.registerLazySingleton(() => GetImmunizationsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateImmunizationUseCase(sl()));

  sl.registerLazySingleton(() => GetMilestonesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleMilestoneUseCase(sl()));
  sl.registerLazySingleton(() => TriggerSosAlert(repository: sl(), locationService: sl()));

  //! BLoCs
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        googleLoginUseCase: sl(),
        saveUserRoleUseCase: sl(),
        getCurrentUserUseCase: sl(),
        logoutUseCase: sl(),
      ));
  sl.registerFactory(() => PregnancyBloc(
        getActivePregnancyUseCase: sl(),
        createPregnancyUseCase: sl(),
        logSymptomUseCase: sl(),
        getSymptomLogsUseCase: sl(),
      ));
  sl.registerFactory(() => KickCounterBloc(
        saveKickSessionUseCase: sl(),
        getKickSessionsUseCase: sl(),
      ));
  sl.registerFactory(() => ContractionTimerBloc(
        saveContractionUseCase: sl(),
        getContractionsUseCase: sl(),
      ));
  sl.registerFactory(() => ChildGrowthBloc(
        getChildrenUseCase: sl(),
        addChildUseCase: sl(),
        logGrowthUseCase: sl(),
        getGrowthLogsUseCase: sl(),
      ));
  sl.registerFactory(() => ImmunizationBloc(
        getImmunizationsUseCase: sl(),
        updateImmunizationUseCase: sl(),
      ));
  sl.registerFactory(() => MilestoneBloc(
        getMilestonesUseCase: sl(),
        toggleMilestoneUseCase: sl(),
      ));
  sl.registerFactory(() => EmergencyBloc(triggerSosAlert: sl()));
  sl.registerLazySingleton(() => SyncBloc());
}
