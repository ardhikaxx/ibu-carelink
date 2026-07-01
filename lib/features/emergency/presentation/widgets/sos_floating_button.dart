import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme.dart';
import '../bloc/emergency_bloc.dart';
import '../bloc/emergency_event.dart';
import '../bloc/emergency_state.dart';

class SosFloatingButton extends StatelessWidget {
  const SosFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmergencyBloc, EmergencyState>(
      listener: (context, state) {
        if (state is EmergencySosTriggered) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sinyal darurat SOS terkirim ke kontak & faskes!')),
          );
        }
        if (state is EmergencyFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is EmergencyTriggering;
        return FloatingActionButton(
          backgroundColor: AppTheme.primaryRose,
          onPressed: isLoading ? null : () => _confirmAndTrigger(context),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.sos, color: Colors.white, size: 28),
        );
      },
    );
  }

  void _confirmAndTrigger(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kirim Sinyal Darurat?'),
        content: const Text(
          'Lokasi Anda akan dikirim ke kontak darurat dan fasilitas kesehatan terdaftar.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRose),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<EmergencyBloc>().add(const SosButtonPressed());
            },
            child: const Text('Kirim Sekarang'),
          ),
        ],
      ),
    );
  }
}
