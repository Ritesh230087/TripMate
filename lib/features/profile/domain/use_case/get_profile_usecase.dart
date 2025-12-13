import 'package:dartz/dartz.dart';
import 'package:tripmate/app/use_case/usecase.dart';
import 'package:tripmate/core/error/failure.dart';
import 'package:tripmate/features/profile/domain/repository/profile_repository.dart';
import '../entity/profile_entity.dart';

class GetProfileUseCase implements UsecaseWithoutParams<ProfileEntity> {
  final IProfileRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call() {
    return repository.getUserProfile();
  }
}