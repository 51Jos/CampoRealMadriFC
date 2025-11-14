import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/company_info.dart';
import '../repositories/company_repository.dart';

class UpdateCompanyInfo {
  final CompanyRepository repository;

  UpdateCompanyInfo(this.repository);

  Future<Either<Failure, void>> call(CompanyInfo companyInfo) async {
    return await repository.updateCompanyInfo(companyInfo);
  }
}
