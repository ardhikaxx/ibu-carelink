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

  const SymptomLogPage({super.key, required this.pregnancyId, required this.userId});

  @override
  State<SymptomLogPage> createState() => _SymptomLogPageState();
}

class _SymptomLogPageState extends State<SymptomLogPage> {
  int _nauseaLevel = 1;
  int _fatigueLevel = 1;
  final _moodController = TextEditingController();
  final List<String> _selectedTriggers = [];

  final List<String> _commonTriggers = [
    'Bau Masakan',
    'Kurang Tidur',
    'Aktivitas Fisik',
    'Perubahan Suhu',
    'Telat Makan',
    'Stres',
  ];

  @override
  void dispose() {
    _moodController.dispose();
    super.dispose();
  }

  void _saveLog() {
    final log = SymptomLogEntity(
      id: const Uuid().v4(),
      pregnancyId: widget.pregnancyId,
      date: DateTime.now(),
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
      appBar: AppBar(
        title: const Text('Catat Gejala Harian'),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evaluasi Kondisi Maternal Hari Ini',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              'Pencatatan gejala membantu memantau fluktuasi hormon trimester.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Nausea Slider
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tingkat Mual / Morning Sickness', style: TextStyle(fontWeight: FontWeight.w700)),
                        Chip(
                          label: Text('Level $_nauseaLevel/5'),
                          backgroundColor: AppTheme.primaryRose.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _nauseaLevel.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: AppTheme.primaryRose,
                      onChanged: (val) => setState(() => _nauseaLevel = val.toInt()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fatigue Slider
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tingkat Kelelahan Fisik', style: TextStyle(fontWeight: FontWeight.w700)),
                        Chip(
                          label: Text('Level $_fatigueLevel/5'),
                          backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: _fatigueLevel.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: AppTheme.primaryTeal,
                      onChanged: (val) => setState(() => _fatigueLevel = val.toInt()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Triggers Checklist
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Faktor Pemicu Gejala (Pilih jika ada)', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonTriggers.map((t) {
                        final isSel = _selectedTriggers.contains(t);
                        return FilterChip(
                          label: Text(t),
                          selected: isSel,
                          selectedColor: AppTheme.accentWarm.withValues(alpha: 0.3),
                          checkmarkColor: const Color(0xFF0F172A),
                          onSelected: (sel) {
                            setState(() {
                              if (sel) {
                                _selectedTriggers.add(t);
                              } else {
                                _selectedTriggers.remove(t);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mood note
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Catatan Suasana Hati / Keluhan Lain', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _moodController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Merasa lebih bertenaga setelah tidur siang...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                onPressed: _saveLog,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Simpan Diari Gejala'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
