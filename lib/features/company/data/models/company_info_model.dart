import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/company_info.dart';

class CompanyInfoModel extends CompanyInfo {
  const CompanyInfoModel({
    required super.id,
    required super.name,
    required super.description,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.phoneNumber,
    required super.yapeNumber,
    required super.bankAccounts,
    required super.startHour,
    required super.endHour,
    required super.dayPrice,
    required super.nightPrice,
    required super.nightStartHour,
    required super.updatedAt,
  });

  factory CompanyInfoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CompanyInfoModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      phoneNumber: data['phoneNumber'] ?? '',
      yapeNumber: data['yapeNumber'] ?? '',
      bankAccounts: (data['bankAccounts'] as List<dynamic>?)
              ?.map((account) => BankAccountModel.fromMap(account))
              .toList() ??
          [],
      startHour: data['startHour'] ?? 8,
      endHour: data['endHour'] ?? 22,
      dayPrice: (data['dayPrice'] ?? 0.0).toDouble(),
      nightPrice: (data['nightPrice'] ?? 0.0).toDouble(),
      nightStartHour: data['nightStartHour'] ?? 18,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'yapeNumber': yapeNumber,
      'bankAccounts': bankAccounts
          .map((account) => (account as BankAccountModel).toMap())
          .toList(),
      'startHour': startHour,
      'endHour': endHour,
      'dayPrice': dayPrice,
      'nightPrice': nightPrice,
      'nightStartHour': nightStartHour,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CompanyInfo toEntity() {
    return CompanyInfo(
      id: id,
      name: name,
      description: description,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phoneNumber: phoneNumber,
      yapeNumber: yapeNumber,
      bankAccounts: bankAccounts,
      startHour: startHour,
      endHour: endHour,
      dayPrice: dayPrice,
      nightPrice: nightPrice,
      nightStartHour: nightStartHour,
      updatedAt: updatedAt,
    );
  }
}

class BankAccountModel extends BankAccount {
  const BankAccountModel({
    required super.bankName,
    required super.accountNumber,
    required super.accountType,
    super.accountHolderName,
  });

  factory BankAccountModel.fromMap(Map<String, dynamic> map) {
    return BankAccountModel(
      bankName: map['bankName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      accountType: map['accountType'] ?? '',
      accountHolderName: map['accountHolderName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'accountHolderName': accountHolderName,
    };
  }
}
