import 'package:get/get.dart';
import 'package:product_app/post/auth/login/view/login_view.dart';

class HomeController extends GetxController {
  var selectedIndex = 0;

  // List of categories to use in sorting
  List<String> categories = ['Category 1', 'Category 2', 'Category 3'];

  // List of posts (you should replace this with your actual post data)
  List<Map<String, String>> posts = [
    {"title": "Post 1", "category": "Category 1"},
    {"title": "Post 2", "category": "Category 2"},
    {"title": "Post 3", "category": "Category 1"},
    {"title": "Post 4", "category": "Category 3"},
  ];

  // Filtered list based on sorting or search
  var filteredPosts = <Map<String, String>>[].obs;

  void onBottomNavigationTapped(int index) {
    selectedIndex = index;
    update(); // Notify listeners to update the UI
  }

  // Optional: Define a list of titles to use in the app bar
  final titles = ["Home", "My Posts", "Account"];

  String get appBarTitle => titles[selectedIndex];

  // Add logout method to clear session and navigate to login screen
  void logout() {
    Get.offAll(() => LoginView());
  }

  // Sort posts by category
  void sortPosts(String selectedCategory) {
    filteredPosts.value = posts
        .where((post) => post["category"] == selectedCategory)
        .toList();
    update();
  }

  // Search posts by title
  void searchPosts(String query) {
    filteredPosts.value = posts
        .where((post) =>
        post["title"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    update();
  }







}
