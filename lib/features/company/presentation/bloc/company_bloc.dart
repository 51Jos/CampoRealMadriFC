import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_company_info.dart';
import '../../domain/usecases/update_company_info.dart';
import 'company_event.dart';
import 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final GetCompanyInfo getCompanyInfo;
  final UpdateCompanyInfo updateCompanyInfo;

  CompanyBloc({
    required this.getCompanyInfo,
    required this.updateCompanyInfo,
  }) : super(const CompanyInitial()) {
    on<LoadCompanyInfoEvent>(_onLoadCompanyInfo);
    on<UpdateCompanyInfoEvent>(_onUpdateCompanyInfo);
  }

  Future<void> _onLoadCompanyInfo(
    LoadCompanyInfoEvent event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());

    final result = await getCompanyInfo();

    result.fold(
      (failure) => emit(CompanyError(failure.message)),
      (companyInfo) => emit(CompanyLoaded(companyInfo)),
    );
  }

  Future<void> _onUpdateCompanyInfo(
    UpdateCompanyInfoEvent event,
    Emitter<CompanyState> emit,
  ) async {
    emit(const CompanyLoading());

    final result = await updateCompanyInfo(event.companyInfo);

    result.fold(
      (failure) => emit(CompanyError(failure.message)),
      (_) => emit(CompanyUpdated(event.companyInfo)),
    );
  }
}
