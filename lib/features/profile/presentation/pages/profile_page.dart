import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../../sync/presentation/bloc/sync_event.dart';

class ProfilePage extends StatelessWidget {
  final UserEntity user;
  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Akun CareLink'),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.15),
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'I', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal))
                  : null,
            ),
            const SizedBox(height: 16),
            Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(user.email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 28),

            // Card Pengaturan Sinkronisasi Offline
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud_sync_rounded, color: AppTheme.primaryTeal),
                        SizedBox(width: 10),
                        Text('Manajemen Sinkronisasi Data', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Aplikasi Ibu CareLink menyimpan seluruh catatan kesehatan kehamilan dan tumbuh kembang anak di penyimpanan lokal sehingga tetap dapat diakses di area tanpa internet.', style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryTeal, side: const BorderSide(color: AppTheme.primaryTeal)),
                        onPressed: () {
                          context.read<SyncBloc>().add(TriggerManualSyncEvent());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Memeriksa antrean lokal & menyinkronkan ke Cloud Firestore...')),
                          );
                        },
                        icon: const Icon(Icons.sync_rounded),
                        label: const Text('Sinkronkan Data Manual Sekarang'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Info Aplikasi
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Colors.white,
              leading: const Icon(Icons.privacy_tip_rounded, color: AppTheme.primaryTeal),
              title: const Text('Kebijakan Privasi Medis'),
              subtitle: const Text('Keamanan Data Health Insurance Portability Standar'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: Colors.white,
              leading: const Icon(Icons.help_center_rounded, color: AppTheme.primaryTeal),
              title: const Text('Bantuan & FAQ CareLink'),
              subtitle: const Text('Panduan pemakaian fitur KPSP & Tendangan'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar dari Akun'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
