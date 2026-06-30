import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/utils/theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/child_growth/presentation/bloc/child_growth_bloc.dart';
import 'features/contraction_timer/presentation/bloc/contraction_timer_bloc.dart';
import 'features/dashboard/presentation/pages/main_nav_page.dart';
import 'features/immunization/presentation/bloc/immunization_bloc.dart';
import 'features/kick_counter/presentation/bloc/kick_counter_bloc.dart';
import 'features/milestones/presentation/bloc/milestone_bloc.dart';
import 'features/pregnancy/presentation/bloc/pregnancy_bloc.dart';
import 'features/sync/presentation/bloc/sync_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const IbuCareLinkApp());
}

class IbuCareLinkApp extends StatelessWidget {
  const IbuCareLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<PregnancyBloc>(
          create: (_) => di.sl<PregnancyBloc>(),
        ),
        BlocProvider<KickCounterBloc>(
          create: (_) => di.sl<KickCounterBloc>(),
        ),
        BlocProvider<ContractionTimerBloc>(
          create: (_) => di.sl<ContractionTimerBloc>(),
        ),
        BlocProvider<ChildGrowthBloc>(
          create: (_) => di.sl<ChildGrowthBloc>(),
        ),
        BlocProvider<ImmunizationBloc>(
          create: (_) => di.sl<ImmunizationBloc>(),
        ),
        BlocProvider<MilestoneBloc>(
          create: (_) => di.sl<MilestoneBloc>(),
        ),
        BlocProvider<SyncBloc>(
          create: (_) => di.sl<SyncBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Ibu CareLink',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                ),
              );
            }
            if (state is AuthAuthenticated) {
              return MainNavPage(user: state.user);
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}
