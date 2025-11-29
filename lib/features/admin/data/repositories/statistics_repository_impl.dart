import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_datasource.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;

  StatisticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Statistics>> getStatistics() async {
    try {
      final statistics = await remoteDataSource.getStatistics();
      return Right(statistics);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
