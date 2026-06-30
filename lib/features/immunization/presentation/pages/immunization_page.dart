import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/theme.dart';
import '../../../child_growth/domain/entities/child_entity.dart';
import '../../domain/entities/immunization_entity.dart';
import '../bloc/immunization_bloc.dart';
import '../bloc/immunization_event.dart';
import '../bloc/immunization_state.dart';

class ImmunizationPage extends StatefulWidget {
  final ChildEntity child;
  final String userId;

  const ImmunizationPage({super.key, required this.child, required this.userId});

  @override
  State<ImmunizationPage> createState() => _ImmunizationPageState();
}

class _ImmunizationPageState extends State<ImmunizationPage> {
  @override
  void initState() {
    super.initState();
    context.read<ImmunizationBloc>().add(LoadImmunizationsEvent(
          userId: widget.userId,
          childId: widget.child.id,
        ));
  }

  void _showMarkDoneDialog(ImmunizationEntity item) {
    final batchController = TextEditingController();
    final clinicController = TextEditingController();
    DateTime adminDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Rekam Vaksinasi (${item.vaccineName})'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan informasi klinis pemberian vaksinasi untuk validasi rekam medis digital.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: batchController,
                decoration: InputDecoration(labelText: 'Nomor Batch / Lot Vaksin', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: clinicController,
                decoration: InputDecoration(labelText: 'Nama Klinik / Posyandu / Bidan', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
            onPressed: () {
              context.read<ImmunizationBloc>().add(MarkImmunizationDoneEvent(
                    immunization: item,
                    userId: widget.userId,
                    batchNumber: batchController.text.trim(),
                    clinicName: clinicController.text.trim(),
                    dateAdministered: adminDate,
                  ));
              Navigator.pop(ctx);
            },
            child: const Text('Konfirmasi Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childAgeMonths = widget.child.ageInMonths;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Jadwal Imunisasi (${widget.child.name})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: BlocBuilder<ImmunizationBloc, ImmunizationState>(
        builder: (context, state) {
          if (state is ImmunizationLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose));
          }

          if (state is ImmunizationLoaded) {
            final list = state.immunizations;
            final overdue = list.where((i) => i.getStatus(childAgeMonths) == ImmunizationStatus.overdue).toList();
            final upcoming = list.where((i) => i.getStatus(childAgeMonths) == ImmunizationStatus.upcoming).toList();
            final completed = list.where((i) => i.getStatus(childAgeMonths) == ImmunizationStatus.completed).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRose.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.primaryRose.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppTheme.primaryRose, size: 36),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Jadwal Rekomendasi IDAI 2024', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(
                                'Terpenuhi: ${completed.length} dari ${list.length} Vaksin Wajib & Anjuran',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (overdue.isNotEmpty) ...[
                    _buildSectionHeader('Terlewat / Perlu Segera Disusulkan (Catch-up)', AppTheme.errorRed, Icons.warning_rounded),
                    const SizedBox(height: 10),
                    ...overdue.map((i) => _buildVaccineCard(i, childAgeMonths)),
                    const SizedBox(height: 20),
                  ],

                  if (upcoming.isNotEmpty) ...[
                    _buildSectionHeader('Segera & Mendatang', AppTheme.warningYellow, Icons.schedule_rounded),
                    const SizedBox(height: 10),
                    ...upcoming.map((i) => _buildVaccineCard(i, childAgeMonths)),
                    const SizedBox(height: 20),
                  ],

                  if (completed.isNotEmpty) ...[
                    _buildSectionHeader('Selesai Diberikan (Riwayat KIA)', AppTheme.successGreen, Icons.check_circle_rounded),
                    const SizedBox(height: 10),
                    ...completed.map((i) => _buildVaccineCard(i, childAgeMonths)),
                  ],
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
      ],
    );
  }

  Widget _buildVaccineCard(ImmunizationEntity item, int currentChildAgeMonths) {
    final status = item.getStatus(currentChildAgeMonths);
    Color borderColor = status == ImmunizationStatus.completed
        ? AppTheme.successGreen
        : status == ImmunizationStatus.overdue
            ? AppTheme.errorRed
            : AppTheme.warningYellow;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: borderColor.withValues(alpha: 0.4))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.vaccineName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Chip(
                  label: Text(item.isCompleted ? 'Selesai' : 'Usia ${item.targetAgeMonths} Bulan'),
                  backgroundColor: borderColor.withValues(alpha: 0.12),
                  labelStyle: TextStyle(color: borderColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (item.isCompleted) ...[
              Text('Diberikan pada: ${DateHelper.formatIndonesianDate(item.dateAdministered ?? DateTime.now())}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              if (item.batchNumber.isNotEmpty)
                Text('No Batch: ${item.batchNumber} • Tempat: ${item.clinicName}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ] else ...[
              Text('Vaksinasi penting perlindungan antibodi spesifik usia anak.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                  onPressed: () => _showMarkDoneDialog(item),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Tandai Sudah Imunisasi'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
