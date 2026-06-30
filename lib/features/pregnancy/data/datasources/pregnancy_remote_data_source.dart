import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_helper.dart';
import '../models/pregnancy_model.dart';
import '../models/symptom_log_model.dart';

abstract class PregnancyRemoteDataSource {
  Future<PregnancyModel?> getActivePregnancy(String userId);
  Future<PregnancyModel> createPregnancy(String userId, DateTime hpht, double preWeight);
  Future<SymptomLogModel> logSymptom(SymptomLogModel log, String userId);
  Future<List<SymptomLogModel>> getSymptomLogs(String userId, String pregnancyId);
}

class PregnancyRemoteDataSourceImpl implements PregnancyRemoteDataSource {
  final FirebaseFirestore firestore;
  PregnancyRemoteDataSourceImpl({required this.firestore});

  @override
  Future<PregnancyModel?> getActivePregnancy(String userId) async {
    try {
      final snap = await firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancies')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        return PregnancyModel.fromFirestore(snap.docs.first.data(), snap.docs.first.id, userId);
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PregnancyModel> createPregnancy(String userId, DateTime hpht, double preWeight) async {
    try {
      final dueDate = DateHelper.calculateDueDateNaegele(hpht);
      final ref = firestore.collection('users').doc(userId).collection('pregnancies').doc();
      final model = PregnancyModel(
        id: ref.id,
        userId: userId,
        hpht: hpht,
        estimatedDueDate: dueDate,
        prePregnancyWeight: preWeight,
        isActive: true,
      );
      await ref.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<SymptomLogModel> logSymptom(SymptomLogModel log, String userId) async {
    try {
      final ref = firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancies')
          .doc(log.pregnancyId)
          .collection('symptom_logs')
          .doc(log.id.isEmpty ? null : log.id);
      
      final model = SymptomLogModel(
        id: ref.id,
        pregnancyId: log.pregnancyId,
        date: log.date,
        nauseaLevel: log.nauseaLevel,
        fatigueLevel: log.fatigueLevel,
        moodNote: log.moodNote,
        triggers: log.triggers,
      );
      await ref.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<SymptomLogModel>> getSymptomLogs(String userId, String pregnancyId) async {
    try {
      final snap = await firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancies')
          .doc(pregnancyId)
          .collection('symptom_logs')
          .orderBy('date', descending: true)
          .limit(30)
          .get();
      return snap.docs
          .map((doc) => SymptomLogModel.fromFirestore(doc.data(), doc.id, pregnancyId))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
