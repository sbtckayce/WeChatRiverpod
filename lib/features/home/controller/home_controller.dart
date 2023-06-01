import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:we_char/features/home/repository/home_repository.dart';
import 'package:we_char/models/user_model.dart';
final homeControllerProvider = Provider<HomeController>((ref) {
  return HomeController(homeRepository: ref.watch(homeRepositoryProvider)
  );
});
final getAllUserModelProvider = StreamProvider.family<List<UserModel>,String>((ref,text)  {
  final homeController = ref.watch(homeControllerProvider);
  return homeController.getAllUserModel(text);
});

final getCurrenUserInfoProvider = StreamProvider<UserModel>((ref)  {
   final homeController = ref.watch(homeControllerProvider);
  return homeController.getCurrentUserInfo();
});
class HomeController{

  final HomeRepository _homeRepository;

  HomeController({required HomeRepository homeRepository}):_homeRepository =homeRepository;

  Stream<List<UserModel>> getAllUserModel(String text){
    return _homeRepository.getAllUserModel(text);
  }
  Stream<UserModel>getCurrentUserInfo(){
    return _homeRepository.getCurrentUserInfo();
  }
  
  Future<void>updateUserInfo(UserModel userModel){
    return _homeRepository.updateUserInfo(userModel);
  }
  Future<bool> addUserModel(String email){
    return _homeRepository.addUserModel(email);
  }
}