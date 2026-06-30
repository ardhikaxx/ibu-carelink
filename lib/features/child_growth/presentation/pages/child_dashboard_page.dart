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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftarkan Anak Baru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Anak',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: gender,
                decoration: InputDecoration(
                  labelText: 'Jenis Kelamin',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                items: ['Laki-laki', 'Perempuan']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setModalState(() => gender = val!),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                tileColor: const Color(0xFFF8FAFC),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRose.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.cake_rounded, color: AppTheme.primaryRose, size: 20),
                ),
                title: const Text('Tanggal Lahir', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                subtitle: Text(
                  DateHelper.formatIndonesianDate(dob),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontSize: 15),
                ),
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
                      decoration: InputDecoration(
                        labelText: 'BB Lahir (kg)',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: lengthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'PB Lahir (cm)',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
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
                  child: const Text('Simpan Profil Anak', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<ChildGrowthBloc, ChildGrowthState>(
        builder: (context, state) {
          if (state is ChildGrowthLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose));
          }

          if (state is ChildGrowthEmpty || state is ChildGrowthError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.child_care_rounded, size: 56, color: AppTheme.primaryRose),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Belum Ada Profil Anak',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan profil buah hati Anda untuk memulai pemantauan kurva pertumbuhan Z-Score WHO & jadwal imunisasi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                        ),
                        onPressed: _showAddChildModal,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Tambah Profil Anak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
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
              color: AppTheme.primaryRose,
              onRefresh: () async {
                context.read<ChildGrowthBloc>().add(LoadChildrenEvent(widget.userId));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Child Selector & Add Button
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: state.children.map((c) {
                                final isSel = c.id == selected.id;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () {
                                      context.read<ChildGrowthBloc>().add(SelectChildEvent(child: c, userId: widget.userId));
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSel ? const Color(0xFF0F172A) : Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: isSel ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                                        boxShadow: isSel
                                            ? [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))]
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            c.gender == 'Laki-laki' ? Icons.face_rounded : Icons.face_3_rounded,
                                            size: 18,
                                            color: isSel ? Colors.white : const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            c.name,
                                            style: TextStyle(
                                              color: isSel ? Colors.white : const Color(0xFF0F172A),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: IconButton(
                            onPressed: _showAddChildModal,
                            icon: const Icon(Icons.add_rounded, color: Color(0xFF0F172A), size: 22),
                            tooltip: 'Tambah Anak',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Medical Alert Card if Z-Score < -2 SD
                    if (state.hasMedicalAlert)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppTheme.errorRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Peringatan Klinis Z-Score',
                                    style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Indikator di bawah -2 SD (Risiko Stunting/Gizi Kurang). Segera konsultasi ke dokter spesialis anak.',
                                    style: TextStyle(color: Color(0xFF7F1D1D), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Ultra-Modern White Floating Profile Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  selected.gender == 'Laki-laki' ? Icons.child_care_rounded : Icons.face_4_rounded,
                                  color: AppTheme.primaryRose,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            selected.name,
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            selected.gender,
                                            style: const TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${selected.formattedAge} • Lahir ${DateHelper.formatIndonesianDate(selected.dateOfBirth)}',
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricItem('BB Lahir', '${selected.birthWeightKg} kg'),
                              _buildMetricItem('PB Lahir', '${selected.birthLengthCm} cm'),
                              _buildMetricItem('BB Terakhir', latestLog != null ? '${latestLog.weightKg} kg' : '-'),
                              _buildMetricItem('TB Terakhir', latestLog != null ? '${latestLog.heightCm} cm' : '-'),
                            ],
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => GrowthChartPage(child: selected, logs: state.logs)));
                              },
                              icon: const Icon(Icons.insights_rounded, size: 18),
                              label: const Text('Buka Kurva Z-Score WHO', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // WHO Evaluation Status Card
                    if (eval != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status Pertumbuhan WHO Terakhir',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatusTile(
                                    'Tinggi Badan (TB/U)',
                                    eval.hfaStatus == ZScoreClassification.normal
                                        ? 'Normal'
                                        : eval.hfaStatus == ZScoreClassification.warning
                                            ? 'Waspada'
                                            : 'Stunting',
                                    eval.hfaStatus == ZScoreClassification.normal ? AppTheme.successGreen : AppTheme.errorRed,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatusTile(
                                    'Berat Badan (BB/U)',
                                    eval.wfaStatus == ZScoreClassification.normal
                                        ? 'Normal'
                                        : eval.wfaStatus == ZScoreClassification.warning
                                            ? 'Waspada'
                                            : 'Perhatian Khusus',
                                    eval.wfaStatus == ZScoreClassification.normal ? AppTheme.successGreen : AppTheme.warningYellow,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Modules KIA & Development
                    const Text(
                      'Layanan & Pantauan KIA',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildServiceCard(
                            title: 'Jadwal Imunisasi',
                            subtitle: 'Standar IDAI 2024',
                            icon: Icons.vaccines_rounded,
                            color: AppTheme.primaryRose,
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
                          child: _buildServiceCard(
                            title: 'Skrining KPSP',
                            subtitle: 'Denver II Perkembangan',
                            icon: Icons.psychology_rounded,
                            color: const Color(0xFFF59E0B),
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

                    // Measurement History Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Pengukuran',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AddGrowthLogPage(child: selected, userId: widget.userId)));
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRose,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_rounded, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Catat BB/TB', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (state.logs.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada riwayat pengukuran antropometri.',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.logs.length,
                        itemBuilder: (context, index) {
                          final item = state.logs[state.logs.length - 1 - index];
                          final zSt = item.evaluation?.hfaStatus ?? ZScoreClassification.normal;
                          final isNormal = zSt == ZScoreClassification.normal;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isNormal ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.straighten_rounded,
                                    color: isNormal ? AppTheme.successGreen : AppTheme.errorRed,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.weightKg} kg • ${item.heightCm} cm • LK ${item.headCircumferenceCm} cm',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateHelper.formatIndonesianDate(item.measurementDate),
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isNormal ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isNormal ? 'WHO Normal' : 'WHO Perhatian',
                                    style: TextStyle(
                                      color: isNormal ? AppTheme.successGreen : AppTheme.errorRed,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTile(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  val,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
