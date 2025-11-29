import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStatisticsEvent extends StatisticsEvent {
  const LoadStatisticsEvent();
}

class RefreshStatisticsEvent extends StatisticsEvent {
  const RefreshStatisticsEvent();
}
