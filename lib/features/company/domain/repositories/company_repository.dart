import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_info.dart';

abstract class CompanyRepository {
  Future<Either<Failure, CompanyInfo>> getCompanyInfo();
  Future<Either<Failure, void>> updateCompanyInfo(CompanyInfo companyInfo);
}
