import 'package:equatable/equatable.dart';
import '../../domain/entities/company_info.dart';

abstract class CompanyEvent extends Equatable {
  const CompanyEvent();

  @override
  List<Object?> get props => [];
}

class LoadCompanyInfoEvent extends CompanyEvent {
  const LoadCompanyInfoEvent();
}

class UpdateCompanyInfoEvent extends CompanyEvent {
  final CompanyInfo companyInfo;

  const UpdateCompanyInfoEvent(this.companyInfo);

  @override
  List<Object?> get props => [companyInfo];
}
