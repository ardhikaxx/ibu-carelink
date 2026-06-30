import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/theme.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/entities/zscore_evaluation.dart';
import '../bloc/child_growth_bloc.dart';
import '../bloc/child_growth_event.dart';
import '../bloc/child_growth_state.dart';
import 'add_growth_log_page.dart';
import 'growth_chart_page.dart';
import '../../../immunization/presentation/pages/immunization_page.dart';
import '../../../milestones/presentation/pages/milestone_page.dart';

class ChildDashboardPage extends StatefulWidget {
  final String userId;
  const ChildDashboardPage({super.key, required this.userId});

  @override
  State<ChildDashboardPage> createState() => _ChildDashboardPageState();
}

class _ChildDashboardPageState extends State<ChildDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChildGrowthBloc>().add(LoadChildrenEvent(widget.userId));
  }

  void _showAddChildModal() {
    final nameController = TextEditingController();
    final weightController = TextEditingController(text: '3.2');
    final lengthController = TextEditingController(text: '50.0');
    String gender = 'Laki-laki';
    DateTime dob = DateTime.now().subtract(const Duration(days: 180));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Registrasi Profil Bayi / Anak', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Lengkap Anak', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: InputDecoration(labelText: 'Jenis Kelamin (Standar WHO)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                items: ['Laki-laki', 'Perempuan'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setModalState(() => gender = val!),
              ),
              const SizedBox(height: 14),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
                leading: const Icon(Icons.cake_rounded, color: AppTheme.primaryTeal),
                title: const Text('Tanggal Lahir'),
                subtitle: Text(DateHelper.formatIndonesianDate(dob), style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dob,
                    firstDate: DateTime(2018),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setModalState(() => dob = picked);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'BB Lahir (kg)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: lengthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'PB Lahir (cm)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    final child = ChildEntity(
                      id: const Uuid().v4(),
                      userId: widget.userId,
                      name: nameController.text.trim(),
                      gender: gender,
                      dateOfBirth: dob,
                      birthWeightKg: double.tryParse(weightController.text) ?? 3.2,
                      birthLengthCm: double.tryParse(lengthController.text) ?? 50.0,
                    );
                    context.read<ChildGrowthBloc>().add(AddNewChildEvent(child: child, userId: widget.userId));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan Profil Anak'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildGrowthBloc, ChildGrowthState>(
      builder: (context, state) {
        if (state is ChildGrowthLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
        }

        if (state is ChildGrowthEmpty || state is ChildGrowthError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppTheme.primaryTeal.withOpacity(0.12), shape: BoxShape.circle),
                    child: const Icon(Icons.child_care_rounded, size: 64, color: AppTheme.primaryTeal),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum Ada Profil Anak Terdaftar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Daftarkan profil buah hati Anda untuk memantau kurva pertumbuhan WHO Z-Score & jadwal imunisasi IDAI.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                    onPressed: _showAddChildModal,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah Profil Anak'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ChildGrowthLoaded) {
          final selected = state.selectedChild;
          final latestLog = state.logs.isNotEmpty ? state.logs.last : null;
          final eval = latestLog?.evaluation;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ChildGrowthBloc>().add(LoadChildrenEvent(widget.userId));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab Multiple Children
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: state.children.map((c) {
                              final isSel = c.id == selected.id;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(c.name),
                                  selected: isSel,
                                  selectedColor: AppTheme.primaryTeal,
                                  labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                                  onSelected: (_) {
                                    context.read<ChildGrowthBloc>().add(SelectChildEvent(child: c, userId: widget.userId));
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _showAddChildModal,
                        icon: const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.primaryTeal),
                        tooltip: 'Tambah Anak',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Medical Alert Card if Z-Score < -2 SD
                  if (state.hasMedicalAlert)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppTheme.errorRed.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.report_problem_rounded, color: Colors.white, size: 36),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PERINGATAN KLINIS Z-SCORE WHO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                                SizedBox(height: 4),
                                Text('Indikator pertumbuhan anak berada di bawah -2 SD (Risiko Stunting / Gizi Kurang). Segera jadwalkan konsultasi ke dokter spesialis anak!', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Banner Anak Utama
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00A896), Color(0xFF028090)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [BoxShadow(color: AppTheme.primaryTeal.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selected.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                            Icon(selected.gender == 'Laki-laki' ? Icons.male_rounded : Icons.female_rounded, color: Colors.white, size: 32),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${selected.formattedAge} • Lahir ${DateHelper.formatIndonesianDate(selected.dateOfBirth)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const Divider(color: Colors.white24, height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBannerStat('Berat Lahir', '${selected.birthWeightKg} kg'),
                            _buildBannerStat('Panjang Lahir', '${selected.birthLengthCm} cm'),
                            _buildBannerStat('BB Terakhir', latestLog != null ? '${latestLog.weightKg} kg' : '-'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primaryTeal),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => GrowthChartPage(child: selected, logs: state.logs)));
                            },
                            icon: const Icon(Icons.show_chart_rounded),
                            label: const Text('Buka Kurva Z-Score WHO'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status Klasifikasi Gizi Terakhir
                  if (eval != null) ...[
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hasil Analisis Z-Score WHO Terakhir', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatusTile(
                                    'Status TB/U (Stunting)',
                                    eval.hfaStatus == ZScoreClassification.normal
                                        ? 'Normal (Gizi Baik)'
                                        : eval.hfaStatus == ZScoreClassification.warning
                                            ? 'Waspada'
                                            : 'Intervensi (< -2 SD)',
                                    eval.hfaStatus == ZScoreClassification.normal ? AppTheme.successGreen : AppTheme.errorRed,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatusTile(
                                    'Status BB/U (Gizi)',
                                    eval.wfaStatus == ZScoreClassification.normal
                                        ? 'Normal'
                                        : eval.wfaStatus == ZScoreClassification.warning
                                            ? 'Waspada'
                                            : 'Perlu Perhatian Khusus',
                                    eval.wfaStatus == ZScoreClassification.normal ? AppTheme.successGreen : AppTheme.warningYellow,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Modul KIA Digital & Tumbuh Kembang
                  const Text('Modul Buku KIA & Perkembangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Jadwal Imunisasi',
                          subtitle: 'Standar IDAI 2024',
                          icon: Icons.vaccines_rounded,
                          color: AppTheme.primaryTeal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImmunizationPage(child: selected, userId: widget.userId),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Milestone KPSP',
                          subtitle: 'Denver II / KPSP',
                          icon: Icons.psychology_rounded,
                          color: AppTheme.accentWarm,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MilestonePage(child: selected, userId: widget.userId),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Riwayat Pengukuran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddGrowthLogPage(child: selected, userId: widget.userId)));
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Catat BB/TB'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.logs.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Center(child: Text('Belum ada riwayat pengukuran antropometri.', style: TextStyle(color: Colors.grey.shade500))),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.logs.length,
                      itemBuilder: (context, index) {
                        final item = state.logs[state.logs.length - 1 - index]; // Newest first
                        final zSt = item.evaluation?.hfaStatus ?? ZScoreClassification.normal;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: zSt == ZScoreClassification.normal
                                  ? AppTheme.successGreen.withOpacity(0.15)
                                  : AppTheme.errorRed.withOpacity(0.15),
                              child: Icon(
                                Icons.straighten_rounded,
                                color: zSt == ZScoreClassification.normal ? AppTheme.successGreen : AppTheme.errorRed,
                              ),
                            ),
                            title: Text('${item.weightKg} kg • ${item.heightCm} cm • LK ${item.headCircumferenceCm} cm', style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(DateHelper.formatIndonesianDate(item.measurementDate)),
                            trailing: Chip(
                              label: Text(zSt == ZScoreClassification.normal ? 'WHO Normal' : 'WHO Perhatian'),
                              backgroundColor: zSt == ZScoreClassification.normal ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.errorRed.withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: zSt == ZScoreClassification.normal ? AppTheme.successGreen : AppTheme.errorRed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildBannerStat(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildFeatureCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
            const SizedBox(height: 3),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTile(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}
