import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product_app/data/remote/api_url.dart';
import 'package:product_app/data/status.dart';
import 'package:product_app/post/post/controller/post_controller.dart';
import 'package:product_app/post/Create_Post/view/create_post_view.dart';
import 'package:product_app/post/post_info/view/post_info_view.dart';

class UserPostView extends StatelessWidget {
  final PostController viewModel = Get.put(PostController());

  UserPostView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Obx(() {
        switch (viewModel.requestLoadingPostStatus.value) {
          case Status.loading:
            return const Center(child: CircularProgressIndicator());
          case Status.error:
            return const Center(child: Text("Error loading user posts"));
          case Status.completed:
            final posts = viewModel.userPost;

            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  "No posts found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  title: post.title ?? "No Title",
                  views: post.totalView ?? 0,
                  category: post.category?.name ?? "No Category",
                  userName: post.user?.username ?? "Unknown User",
                  imagePath: post.image != null
                      ? "${ApiUrl.imageViewPath}${post.image}"
                      : "assets/images/icons/no-image.jpg",
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreatePostView()),
                    );
                  },
                  onDelete: () {
                    // Implement delete logic here
                  },
                  onTap: () {
                    Get.to(PostInfoView(postData: post));
                  },
                );
              },
            );
          default:
            return const SizedBox();
        }
      }),
    );
  }
}

class PostCard extends StatelessWidget {
  final String title;
  final int views;
  final String category;
  final String userName;
  final String imagePath;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const PostCard({
    Key? key,
    required this.title,
    required this.views,
    required this.category,
    required this.userName,
    required this.imagePath,
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Views and User Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$views views',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person,
                              size: 20, color: Color(0xFF26247B)),
                          const SizedBox(width: 5),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category Badge
                      Chip(
                        label: Text(category),
                        backgroundColor:
                        Colors.white,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF26247B),
                        ),
                      ),
                      // Edit and Delete Icons
                      Row(
                        children: [
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF26247B)),
                          ),
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
