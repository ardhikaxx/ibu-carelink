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

      String getBand(int m) {
        if (m <= 3) return '0-3 bln';
        if (m <= 6) return '4-6 bln';
        if (m <= 9) return '7-9 bln';
        if (m <= 12) return '10-12 bln';
        if (m <= 18) return '13-18 bln';
        if (m <= 24) return '19-24 bln';
        return '25-36 bln';
      }

      if (snap.docs.isEmpty || snap.docs.length < AppConstants.developmentalMilestones.length) {
        final existingTitles = snap.docs.map((d) => d.data()['title'] ?? '').toSet();
        final batch = firestore.batch();
        bool hasNew = false;

        for (var item in AppConstants.developmentalMilestones) {
          final desc = item['description'] as String;
          if (!existingTitles.contains(desc)) {
            final docRef = colRef.doc();
            final m = MilestoneModel(
              id: docRef.id,
              childId: childId,
              title: desc,
              domain: item['domain'],
              targetAgeBand: getBand(item['ageMonths']),
              maxMonthBand: item['ageMonths'],
              isAchieved: false,
            );
            batch.set(docRef, m.toFirestore());
            hasNew = true;
          }
        }
        if (hasNew) {
          await batch.commit();
          final updatedSnap = await colRef.orderBy('maxMonthBand').get();
          return updatedSnap.docs.map((doc) => MilestoneModel.fromFirestore(doc.data(), doc.id, childId)).toList();
        }
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
