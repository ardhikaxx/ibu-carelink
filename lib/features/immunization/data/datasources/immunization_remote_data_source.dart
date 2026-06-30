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
      final colRef = firestore.collection('users').doc(userId).collection('children').doc(childId).collection('immunizations');
      final snap = await colRef.orderBy('targetAgeMonths').get();

      if (snap.docs.isEmpty) {
        // Inisialisasi jadwal IDAI 2024 jika belum ada
        final batch = firestore.batch();
        final List<ImmunizationModel> initialList = [];
        for (var item in AppConstants.idaiVaccineSchedule2024) {
          final docRef = colRef.doc();
          final m = ImmunizationModel(
            id: docRef.id,
            childId: childId,
            vaccineName: item['name'],
            targetAgeMonths: item['ageMonths'],
            isCompleted: false,
          );
          batch.set(docRef, m.toFirestore());
          initialList.add(m);
        }
        await batch.commit();
        return initialList;
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
          .collection('immunizations')
          .doc(model.id);
      await ref.set(model.toFirestore(), SetOptions(merge: true));
      return model;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
