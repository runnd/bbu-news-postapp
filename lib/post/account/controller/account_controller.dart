import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:product_app/modules/post/login/login_res.dart';

import 'package:product_app/post/auth/login/view/login_view.dart';

class AccountController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var user = Rx<LoginRes?>(null);  // Observable user data
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadUserData();  // Fetch data on initialization
  }

  void loadUserData() {
    try {
      isLoading(true); // Set loading to true at the beginning
      final storedUser = storage.read('USER_KEY'); // Fetch data using storage key
      if (storedUser != null) {
        user.value = LoginRes.fromJson(storedUser);
        errorMessage.value = ''; // Clear any error message
      } else {
        errorMessage.value = 'No user data available.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load user data: $e';
    } finally {
      isLoading(false); // Set loading to false when done
    }
  }

  void logout() {
    Get.offAll(() => LoginView());
  }
}
