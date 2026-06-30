import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_helper.dart';
import '../models/child_model.dart';
import '../models/growth_log_model.dart';

abstract class ChildRemoteDataSource {
  Future<List<ChildModel>> getChildren(String userId);
  Future<ChildModel> addChild(ChildModel child, String userId);
  Future<GrowthLogModel> logGrowth(GrowthLogModel log, ChildModel child, String userId);
  Future<List<GrowthLogModel>> getGrowthLogs(String userId, ChildModel child);
}

class ChildRemoteDataSourceImpl implements ChildRemoteDataSource {
  final FirebaseFirestore firestore;
  ChildRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ChildModel>> getChildren(String userId) async {
    try {
      final snap = await firestore.collection('users').doc(userId).collection('children').orderBy('childOrder').get();
      return snap.docs.map((doc) => ChildModel.fromFirestore(doc.data(), doc.id, userId)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ChildModel> addChild(ChildModel child, String userId) async {
    try {
      final ref = firestore.collection('users').doc(userId).collection('children').doc();
      final model = ChildModel(
        id: ref.id,
        userId: userId,
        name: child.name,
        gender: child.gender,
        dateOfBirth: child.dateOfBirth,
        birthWeightKg: child.birthWeightKg,
        birthLengthCm: child.birthLengthCm,
        childOrder: child.childOrder,
      );
      await ref.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<GrowthLogModel> logGrowth(GrowthLogModel log, ChildModel child, String userId) async {
    try {
      final ref = firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(child.id)
          .collection('growth_logs')
          .doc(log.id.isEmpty ? null : log.id);

      final ageMonths = DateHelper.calculateAgeInMonths(child.dateOfBirth);
      final model = GrowthLogModel.fromFirestore(
        log.toFirestore(),
        ref.id,
        child.id,
        ageMonths: ageMonths,
        gender: child.gender,
      );
      await ref.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<GrowthLogModel>> getGrowthLogs(String userId, ChildModel child) async {
    try {
      final snap = await firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(child.id)
          .collection('growth_logs')
          .orderBy('measurementDate', descending: false)
          .get();

      return snap.docs.map((doc) {
        final date = (doc.data()['measurementDate'] != null)
            ? DateTime.tryParse(doc.data()['measurementDate'].toString()) ?? DateTime.now()
            : DateTime.now();
        final ageM = DateHelper.calculateAgeInMonths(child.dateOfBirth, currentDate: date);
        return GrowthLogModel.fromFirestore(doc.data(), doc.id, child.id, ageMonths: ageM, gender: child.gender);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
