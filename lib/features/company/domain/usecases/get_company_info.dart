import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/company_info.dart';
import '../repositories/company_repository.dart';

class GetCompanyInfo {
  final CompanyRepository repository;

  GetCompanyInfo(this.repository);

  Future<Either<Failure, CompanyInfo>> call() async {
    return await repository.getCompanyInfo();
  }
}
