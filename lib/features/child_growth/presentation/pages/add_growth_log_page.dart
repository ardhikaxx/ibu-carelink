import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/theme.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/entities/growth_log_entity.dart';
import '../bloc/child_growth_bloc.dart';
import '../bloc/child_growth_event.dart';

class AddGrowthLogPage extends StatefulWidget {
  final ChildEntity child;
  final String userId;

  const AddGrowthLogPage({super.key, required this.child, required this.userId});

  @override
  State<AddGrowthLogPage> createState() => _AddGrowthLogPageState();
}

class _AddGrowthLogPageState extends State<AddGrowthLogPage> {
  DateTime _date = DateTime.now();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
    super.dispose();
  }

  void _saveLog() {
    final w = double.tryParse(_weightController.text) ?? 0.0;
    final h = double.tryParse(_heightController.text) ?? 0.0;
    final hc = double.tryParse(_headController.text) ?? 0.0;

    if (w <= 0 || h <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berat dan Tinggi badan tidak boleh kosong/nol.')),
      );
      return;
    }

    final log = GrowthLogEntity(
      id: const Uuid().v4(),
      childId: widget.child.id,
      measurementDate: _date,
      weightKg: w,
      heightCm: h,
      headCircumferenceCm: hc,
    );

    context.read<ChildGrowthBloc>().add(RecordGrowthLogEvent(
          log: log,
          child: widget.child,
          userId: widget.userId,
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catat Pertumbuhan (${widget.child.name})'),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Input Pengukuran Antropometri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Catat hasil pengukuran di posyandu atau klinik untuk analisis kurva Z-Score.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),

            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
              leading: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryTeal),
              title: const Text('Tanggal Pengukuran'),
              subtitle: Text(DateHelper.formatIndonesianDate(_date), style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: widget.child.dateOfBirth,
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Berat Badan (kg)',
                hintText: 'Contoh: 7.5',
                prefixIcon: const Icon(Icons.monitor_weight_rounded, color: AppTheme.primaryTeal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Tinggi / Panjang Badan (cm)',
                hintText: 'Contoh: 68.5',
                prefixIcon: const Icon(Icons.height_rounded, color: AppTheme.primaryTeal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _headController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Lingkar Kepala (cm) - Opsional',
                hintText: 'Contoh: 42.0',
                prefixIcon: const Icon(Icons.child_care_rounded, color: AppTheme.primaryTeal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                onPressed: _saveLog,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Evaluasi & Simpan Catatan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
