import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/theme.dart';
import '../../domain/entities/symptom_log_entity.dart';
import '../bloc/pregnancy_bloc.dart';
import '../bloc/pregnancy_event.dart';

class SymptomLogPage extends StatefulWidget {
  final String pregnancyId;
  final String userId;

  final SymptomLogEntity? initialLog;

  const SymptomLogPage({super.key, required this.pregnancyId, required this.userId, this.initialLog});

  @override
  State<SymptomLogPage> createState() => _SymptomLogPageState();
}

class _SymptomLogPageState extends State<SymptomLogPage> {
  DateTime _date = DateTime.now();
  int _nauseaLevel = 1;
  int _fatigueLevel = 1;
  final _moodController = TextEditingController();
  final List<String> _selectedTriggers = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialLog != null) {
      _date = widget.initialLog!.date;
      _nauseaLevel = widget.initialLog!.nauseaLevel;
      _fatigueLevel = widget.initialLog!.fatigueLevel;
      _moodController.text = widget.initialLog!.moodNote;
      _selectedTriggers.addAll(widget.initialLog!.triggers);
    }
  }

  final List<String> _commonTriggers = [
    'Bau Masakan',
    'Kurang Tidur',
    'Aktivitas Fisik',
    'Perubahan Suhu',
    'Telat Makan',
    'Stres / Emosional',
    'Perjalanan / Kendaraan',
  ];

  @override
  void dispose() {
    _moodController.dispose();
    super.dispose();
  }

  void _saveLog() {
    final log = SymptomLogEntity(
      id: widget.initialLog?.id ?? const Uuid().v4(),
      pregnancyId: widget.pregnancyId,
      date: _date,
      nauseaLevel: _nauseaLevel,
      fatigueLevel: _fatigueLevel,
      moodNote: _moodController.text.trim(),
      triggers: List.from(_selectedTriggers),
    );

    context.read<PregnancyBloc>().add(AddSymptomLogEvent(log: log, userId: widget.userId));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.initialLog != null ? 'Edit Gejala Harian' : 'Catat Gejala Harian',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evaluasi Kondisi Maternal',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pantau fluktuasi kenyamanan tubuh Anda hari ini secara berkala.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Nausea Slider Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRose.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.sick_rounded, color: AppTheme.primaryRose, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Tingkat Mual / Morning Sickness',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRose.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Level $_nauseaLevel / 5',
                          style: const TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primaryRose,
                      inactiveTrackColor: AppTheme.primaryRose.withValues(alpha: 0.15),
                      thumbColor: AppTheme.primaryRose,
                      overlayColor: AppTheme.primaryRose.withValues(alpha: 0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _nauseaLevel.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (val) => setState(() => _nauseaLevel = val.toInt()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('1 - Sangat Ringan', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        Text('5 - Sangat Berat', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fatigue Slider Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRose.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.battery_3_bar_rounded, color: AppTheme.primaryRose, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Tingkat Kelelahan Fisik',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRose.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Level $_fatigueLevel / 5',
                          style: const TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primaryRose,
                      inactiveTrackColor: AppTheme.primaryRose.withValues(alpha: 0.15),
                      thumbColor: AppTheme.primaryRose,
                      overlayColor: AppTheme.primaryRose.withValues(alpha: 0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _fatigueLevel.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (val) => setState(() => _fatigueLevel = val.toInt()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('1 - Segar / Fit', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        Text('5 - Sangat Lelah', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Triggers Checklist Card
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
                    'Faktor Pemicu Gejala (Opsional)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  const Text('Pilih aktivitas atau kondisi yang memicu keluhan hari ini:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _commonTriggers.map((t) {
                      final isSel = _selectedTriggers.contains(t);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSel) {
                              _selectedTriggers.remove(t);
                            } else {
                              _selectedTriggers.add(t);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppTheme.primaryRose : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? AppTheme.primaryRose : const Color(0xFFE2E8F0)),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryRose.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSel) ...[
                                const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                t,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mood Note Card
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
                    'Catatan Suasana Hati / Keluhan Lain',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _moodController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan catatan tambahan mengenai kondisi tubuh Anda hari ini...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF0F172A)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saveLog,
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: Text(widget.initialLog != null ? 'Simpan Perubahan Gejala' : 'Simpan Catatan Gejala', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
