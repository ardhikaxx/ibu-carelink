import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/immunization_model.dart';

abstract class ImmunizationRemoteDataSource {
  Future<List<ImmunizationModel>> getImmunizations(String userId, String childId);
  Future<ImmunizationModel> updateImmunization(ImmunizationModel model, String userId);
}

class ImmunizationRemoteDataSourceImpl implements ImmunizationRemoteDataSource {
  final FirebaseFirestore firestore;
  ImmunizationRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ImmunizationModel>> getImmunizations(String userId, String childId) async {
    try {
      final colRef = firestore.collection('users').doc(userId).collection('children').doc(childId).collection('vaccinations');
      final snap = await colRef.orderBy('targetAgeMonths').get();

      if (snap.docs.isEmpty || snap.docs.length < AppConstants.idaiVaccineSchedule2024.length) {
        final existingNames = snap.docs.map((d) => d.data()['vaccineName'] ?? '').toSet();
        final batch = firestore.batch();
        bool hasNew = false;

        for (var item in AppConstants.idaiVaccineSchedule2024) {
          final name = item['name'] as String;
          if (!existingNames.contains(name)) {
            final docRef = colRef.doc();
            final m = ImmunizationModel(
              id: docRef.id,
              childId: childId,
              vaccineName: name,
              targetAgeMonths: item['ageMonths'],
              isCompleted: false,
            );
            batch.set(docRef, m.toFirestore());
            hasNew = true;
          }
        }
        if (hasNew) {
          await batch.commit();
          final updatedSnap = await colRef.orderBy('targetAgeMonths').get();
          return updatedSnap.docs.map((doc) => ImmunizationModel.fromFirestore(doc.data(), doc.id, childId)).toList();
        }
      }

      return snap.docs.map((doc) => ImmunizationModel.fromFirestore(doc.data(), doc.id, childId)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ImmunizationModel> updateImmunization(ImmunizationModel model, String userId) async {
    try {
      final ref = firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(model.childId)
          .collection('vaccinations')
          .doc(model.id);
      await ref.set(model.toFirestore(), SetOptions(merge: true));
      return model;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
