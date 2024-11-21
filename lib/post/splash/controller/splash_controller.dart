import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Import GetStorage
import 'package:product_app/repository/post/login_repository.dart';
import 'package:product_app/routes/app_routes.dart';

class SplashController extends GetxController {
  final _loginRepository = LoginRepository();
  final _box = GetStorage(); // GetStorage instance

  RxBool isLogoVisible = false.obs; // Controls logo animation
  RxBool isTextVisible = false.obs; // Controls text animation

  @override
  void onInit() {
    super.onInit();
    _startAnimations();
    checkFirstLaunch();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    isLogoVisible.value = true;

    await Future.delayed(const Duration(milliseconds: 1000));
    isTextVisible.value = true;
  }

  Future<void> checkFirstLaunch() async {
    bool isFirstLaunch = _box.read('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      _box.write('isFirstLaunch', false);
    }
    await Future.delayed(const Duration(seconds: 3)); // Wait for animations
    checkUserLogin();
  }

  Future<void> checkUserLogin() async {
    var user = await _loginRepository.getUserLocal();

    if (user.accessToken != null) {
      Get.offAllNamed(RouteName.home);
    } else {
      Get.offAllNamed(RouteName.postLogin);
    }
  }
}
