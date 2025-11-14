import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_info_model.dart';

abstract class CompanyRemoteDataSource {
  /// Obtiene la información de la empresa
  Future<CompanyInfoModel> getCompanyInfo();

  /// Actualiza la información de la empresa
  Future<void> updateCompanyInfo(CompanyInfoModel companyInfo);
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final FirebaseFirestore firestore;
  static const String _collection = 'company_info';
  static const String _docId = 'main'; // Un solo documento con toda la info

  CompanyRemoteDataSourceImpl({required this.firestore});

  @override
  Future<CompanyInfoModel> getCompanyInfo() async {
    try {
      final doc = await firestore.collection(_collection).doc(_docId).get();

      if (!doc.exists) {
        // Si no existe, crear uno con valores por defecto
        final defaultInfo = CompanyInfoModel(
          id: _docId,
          name: 'Sintético Lima',
          description: 'Cancha de fútbol sintético en Lima',
          address: 'Lima, Perú',
          latitude: -12.0464,
          longitude: -77.0428,
          phoneNumber: '+51999999999',
          yapeNumber: '+51999999999',
          bankAccounts: const [],
          startHour: 8,
          endHour: 22,
          dayPrice: 80.0,
          nightPrice: 100.0,
          nightStartHour: 18,
          updatedAt: DateTime.now(),
        );

        await firestore
            .collection(_collection)
            .doc(_docId)
            .set(defaultInfo.toFirestore());

        return defaultInfo;
      }

      return CompanyInfoModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error al obtener información de la empresa: $e');
    }
  }

  @override
  Future<void> updateCompanyInfo(CompanyInfoModel companyInfo) async {
    try {
      await firestore
          .collection(_collection)
          .doc(_docId)
          .set(companyInfo.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error al actualizar información de la empresa: $e');
    }
  }
}
