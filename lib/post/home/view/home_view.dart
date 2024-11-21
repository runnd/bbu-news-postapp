import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product_app/post/home/controller/home_controller.dart';
import 'package:product_app/post/post/views/post_view.dart';
import 'package:product_app/post/account/view/account_view.dart';
import 'package:product_app/post/create_post/view/create_post_view.dart';
import 'package:product_app/post/search/view/post_search_view.dart';
import 'package:product_app/post/user_post/view/user_post_view.dart'; // Correct import for CreatePostView


class HomeView extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 20.0,
            title: Text(
              controller.appBarTitle,
              style: TextStyle(
                color: Color(0xFF26247B),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // Show Sort and Search icons only on HomeView (Index 0)
              if (controller.selectedIndex == 0) ...[
                IconButton(
                  icon: Icon(Icons.sort, color: Color(0xFF26247B)), // Sort icon
                  onPressed: () {
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Color(0xFF26247B)), // Search icon
                  onPressed: () {
                    Get.to(PostSearchView()); // Navigate to the Search Screen
                  },
                ),
              ],
              // Show Create New icon only on MyPostsView (Index 1)
              if (controller.selectedIndex == 1)
                IconButton(
                  icon: Icon(Icons.add, color: Color(0xFF26247B)), // Create New icon
                  onPressed: () {
                    Get.to(() => CreatePostView());
                  },
                ),
              // Show Logout icon only on AccountView (Index 2)
              if (controller.selectedIndex == 2)
                IconButton(
                  icon: Icon(Icons.logout, color: Color(0xFF26247B)), // Logout icon
                  onPressed: () {
                    controller.logout(); // Call logout logic
                  },
                ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF26247B), Color(0xFF26247B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: IndexedStack(
              index: controller.selectedIndex,
              children: [
                PostView(),
                UserPostView(),
                AccountView(),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xFF26247B),
                unselectedItemColor: Colors.grey,
                currentIndex: controller.selectedIndex,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.post_add_outlined),
                    activeIcon: Icon(Icons.post_add),
                    label: "My Posts",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle_outlined),
                    activeIcon: Icon(Icons.account_circle),
                    label: "Account",
                  ),
                ],
                onTap: (index) {
                  controller.onBottomNavigationTapped(index);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
