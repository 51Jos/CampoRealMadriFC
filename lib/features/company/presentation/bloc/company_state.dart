import 'package:equatable/equatable.dart';
import '../../domain/entities/company_info.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {
  const CompanyInitial();
}

class CompanyLoading extends CompanyState {
  const CompanyLoading();
}

class CompanyLoaded extends CompanyState {
  final CompanyInfo companyInfo;

  const CompanyLoaded(this.companyInfo);

  @override
  List<Object?> get props => [companyInfo];
}

class CompanyUpdated extends CompanyState {
  final CompanyInfo companyInfo;

  const CompanyUpdated(this.companyInfo);

  @override
  List<Object?> get props => [companyInfo];
}

class CompanyError extends CompanyState {
  final String message;

  const CompanyError(this.message);

  @override
  List<Object?> get props => [message];
}
