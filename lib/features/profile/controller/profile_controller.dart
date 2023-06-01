import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_char/features/profile/repository/profile_repository.dart';

import '../../../models/user_model.dart';

final profileControllerProvider = Provider<ProfileController>((ref) {
  return ProfileController(profileRepository: ref.watch(profileRepositoryProvider));
});

class ProfileController {
  final ProfileRepository _profileRepository;

  ProfileController({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  Future<void> updateProfilePicture(
      {required UserModel userModel, required File image}) {
    return _profileRepository.updateProfilePicture(
        userModel: userModel, image: image);
  }
}
