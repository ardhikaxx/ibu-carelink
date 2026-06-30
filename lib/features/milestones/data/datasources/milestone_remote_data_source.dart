import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/milestone_model.dart';

abstract class MilestoneRemoteDataSource {
  Future<List<MilestoneModel>> getMilestones(String userId, String childId);
  Future<MilestoneModel> updateMilestone(MilestoneModel model, String userId);
}

class MilestoneRemoteDataSourceImpl implements MilestoneRemoteDataSource {
  final FirebaseFirestore firestore;
  MilestoneRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<MilestoneModel>> getMilestones(String userId, String childId) async {
    try {
      final colRef = firestore.collection('users').doc(userId).collection('children').doc(childId).collection('milestones');
      final snap = await colRef.orderBy('maxMonthBand').get();

      if (snap.docs.isEmpty) {
        // Inisialisasi KPSP RI / Denver II jika belum ada
        final batch = firestore.batch();
        final List<MilestoneModel> initialList = [];
        for (var item in AppConstants.developmentalMilestones) {
          final docRef = colRef.doc();
          final m = MilestoneModel(
            id: docRef.id,
            childId: childId,
            title: item['description'],
            domain: item['domain'],
            targetAgeBand: '${item['ageMonths']} Bulan',
            maxMonthBand: item['ageMonths'],
            isAchieved: false,
          );
          batch.set(docRef, m.toFirestore());
          initialList.add(m);
        }
        await batch.commit();
        return initialList;
      }

      return snap.docs.map((doc) => MilestoneModel.fromFirestore(doc.data(), doc.id, childId)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MilestoneModel> updateMilestone(MilestoneModel model, String userId) async {
    try {
      final ref = firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(model.childId)
          .collection('milestones')
          .doc(model.id);
      await ref.set(model.toFirestore(), SetOptions(merge: true));
      return model;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
