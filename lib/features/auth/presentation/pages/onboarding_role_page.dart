import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../dashboard/presentation/pages/main_nav_page.dart';

class OnboardingRolePage extends StatefulWidget {
  final UserEntity user;
  const OnboardingRolePage({super.key, required this.user});

  @override
  State<OnboardingRolePage> createState() => _OnboardingRolePageState();
}

class _OnboardingRolePageState extends State<OnboardingRolePage> {
  String? _selectedRole;

  void _submitRole() {
    if (_selectedRole != null) {
      context.read<AuthBloc>().add(SaveRoleEvent(
            uid: widget.user.uid,
            role: _selectedRole!,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MainNavPage(user: state.user)),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorRed),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF1F2), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Selamat Datang, ${widget.user.name}!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kuesioner Profiling Klinis: Pilih status Anda saat ini agar antarmuka beranda menyesuaikan kebutuhan medis prioritas Anda.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView(
                    children: [
                      _buildRoleOption(
                        id: 'pregnant',
                        title: 'Sedang Hamil (Maternal)',
                        subtitle: 'Fokus pemantauan trimester kehamilan, HPL, tendangan janin & kontraksi persalinan.',
                        icon: Icons.child_care_rounded,
                        color: AppTheme.primaryRose,
                      ),
                      const SizedBox(height: 16),
                      _buildRoleOption(
                        id: 'toddler_parent',
                        title: 'Memiliki Anak Balita (Pediatrik)',
                        subtitle: 'Fokus grafik pertumbuhan Z-Score WHO, jadwal imunisasi IDAI 2024 & tonggak perkembangan.',
                        icon: Icons.escalator_warning_rounded,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(height: 16),
                      _buildRoleOption(
                        id: 'both',
                        title: 'Keduanya (Hamil & Memiliki Balita)',
                        subtitle: 'Akses penuh ke seluruh fitur maternal dan pemantauan tumbuh kembang anak secara simultan.',
                        icon: Icons.family_restroom_rounded,
                        color: AppTheme.accentWarm,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedRole == null ? null : _submitRole,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRole == null ? Colors.grey : AppTheme.primaryRose,
                    ),
                    child: const Text('Lanjutkan ke Beranda Utama'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isSelected ? color : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 28)
            else
              Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey.shade300, size: 28),
          ],
        ),
      ),
    );
  }
}
