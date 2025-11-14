import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/company_info.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';
import '../models/company_info_model.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;

  CompanyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CompanyInfo>> getCompanyInfo() async {
    try {
      final companyInfo = await remoteDataSource.getCompanyInfo();
      return Right(companyInfo.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCompanyInfo(CompanyInfo companyInfo) async {
    try {
      final model = CompanyInfoModel(
        id: companyInfo.id,
        name: companyInfo.name,
        description: companyInfo.description,
        address: companyInfo.address,
        latitude: companyInfo.latitude,
        longitude: companyInfo.longitude,
        phoneNumber: companyInfo.phoneNumber,
        yapeNumber: companyInfo.yapeNumber,
        bankAccounts: companyInfo.bankAccounts,
        schedule: companyInfo.schedule,
        dayPrice: companyInfo.dayPrice,
        nightPrice: companyInfo.nightPrice,
        nightStartHour: companyInfo.nightStartHour,
        updatedAt: DateTime.now(),
      );

      await remoteDataSource.updateCompanyInfo(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
