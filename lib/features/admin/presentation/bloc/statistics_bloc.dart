import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_statistics_usecase.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatisticsUseCase getStatisticsUseCase;

  StatisticsBloc({required this.getStatisticsUseCase})
      : super(const StatisticsInitial()) {
    on<LoadStatisticsEvent>(_onLoadStatistics);
    on<RefreshStatisticsEvent>(_onRefreshStatistics);
  }

  Future<void> _onLoadStatistics(
    LoadStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());
    await _fetchStatistics(emit);
  }

  Future<void> _onRefreshStatistics(
    RefreshStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    await _fetchStatistics(emit);
  }

  Future<void> _fetchStatistics(Emitter<StatisticsState> emit) async {
    final result = await getStatisticsUseCase();

    result.fold(
      (failure) => emit(StatisticsError(message: failure.message)),
      (statistics) => emit(StatisticsLoaded(statistics: statistics)),
    );
  }
}
