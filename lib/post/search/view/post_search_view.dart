import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product_app/data/remote/api_url.dart';
import 'package:product_app/post/post/controller/post_controller.dart';
import 'package:product_app/post/post_info/view/post_info_view.dart';

class PostSearchView extends StatelessWidget {
  final PostController postController = Get.find<PostController>();

  PostSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Posts"),
        backgroundColor: const Color(0xFF26247B),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by title or category...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: postController.searchPosts,
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredPosts = postController.filteredPosts;

              if (filteredPosts.isEmpty) {
                return const Center(
                  child: Text(
                    "No posts found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                itemCount: filteredPosts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(25), // Circular avatar
                      child: CachedNetworkImage(
                        imageUrl: "${ApiUrl.imageViewPath}${post.image}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      post.title ?? "No Title",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      post.description ?? "No Description",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () => Get.to(() => PostInfoView(postData: post)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
