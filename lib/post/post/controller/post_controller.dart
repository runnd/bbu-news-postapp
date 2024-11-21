import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:product_app/data/status.dart';
import 'package:product_app/modules/post/post_base_request.dart';
import 'package:product_app/modules/post/post_category.dart';
import 'package:product_app/modules/post/post_request.dart';
import 'package:product_app/modules/post/response/post_response.dart';
import 'package:product_app/repository/post/post_repository.dart';

class PostController extends GetxController {
  var categoryList = <PostCategory>[].obs; // List to hold categories
  var isLoading = false.obs;
  var postList = <PostResponse>[].obs; // All posts
  var filteredPosts = <PostResponse>[].obs; // Filtered posts for search
  var userPost = <PostResponse>[].obs; // Filtered posts for search
  var requestLoadingPostStatus = Status.loading.obs;
  var loadingMore = false.obs;
  var currentPage = 1.obs;
  var storage = GetStorage();
  var baseRequest = PostRequest().obs;

  final _postRepository = PostRepository();
  var selectedCategoryId = 0.obs;  // Track selected category
  var onCreateLoading = false.obs;

  void setRequestLoadingPostStatus(Status value) {
    requestLoadingPostStatus.value = value;
  }

  @override
  void onInit() {
    loadingData();
    super.onInit();
  }

  // Method to load all data (posts, categories, and user posts)

  loadingData() async {
    print('loading');
    setRequestLoadingPostStatus(Status.loading);
    try {
      await _getAllPost();
      await fetchUserPosts();
      filteredPosts.assignAll(postList); // Initialize filteredPosts with all posts
      setRequestLoadingPostStatus(Status.completed);
    } catch (e) {
      setRequestLoadingPostStatus(Status.error);
      print("Error loading data: $e");
    }
  }

  // Fetch all posts
  _getAllPost() async {
    var request = PostBaseRequest();
    var response = await _postRepository.getAllPosts(request);
    print("API Response: ${response.data}");

    if (response.data != null && response.data is List) {
      postList.value = [];
      try {
        postList.assignAll(
          (response.data as List).map((data) => PostResponse.fromJson(data)).toList(),
        );
        filteredPosts.assignAll(postList); // Initialize filtered posts
      } catch (e) {
        print("Error parsing posts: $e");
        throw Exception("Failed to parse posts");
      }
    } else {
      throw Exception("No data available or invalid data format");
    }
  }

  // Filter posts by category
  void filterPostsByCategory(int categoryId) {
    selectedCategoryId.value = categoryId;
    if (categoryId == 0) {
      filteredPosts.assignAll(postList); // No filter applied, show all posts
    } else {
      filteredPosts.assignAll(postList.where((post) => post.category?.id == categoryId).toList());
    }
  }



  // Fetch posts (reset for page 1)
  fetchPosts() async {
    setRequestLoadingPostStatus(Status.loading);
    try {
      currentPage.value = 1;
      var request = PostBaseRequest();
      var response = await _postRepository.getAllPosts(request);

      if (response.data != null && response.data is List) {
        postList.assignAll(
          (response.data as List).map((data) => PostResponse.fromJson(data)).toList(),
        );
        filteredPosts.assignAll(postList); // Reset filtered posts
      } else {
        throw Exception("Invalid or empty data");
      }
      setRequestLoadingPostStatus(Status.completed);
    } catch (e) {
      setRequestLoadingPostStatus(Status.error);
      print("Error in fetchPosts: $e");
    }
  }

  // Fetch more posts for pagination
  getAllPostMore() async {
    if (loadingMore.value) return;
    loadingMore.value = true;
    try {

      var request = PostBaseRequest();
      var totalPage = postList.value.length;
      var limitPage = request.limit;
      var current = 0;
      // Ensure limitPage is not zero to avoid division by zero error
      if (limitPage != null && limitPage > 0) {
        current = (totalPage / limitPage)
            .ceil(); // .ceil() rounds up to the nearest integer
      }
      // current = (totalPage/limitPage!) as dynamic;

      print(
          "LOADING DATA MORE ${totalPage} AND CURRENT ${current} LIMIT ${limitPage}");
      current += 1;


      var response = await _postRepository.getAllPosts(request);

      if (response.data != null && response.data is List) {
        postList.addAll(
          (response.data as List).map((data) => PostResponse.fromJson(data)).toList(),
        );
        filteredPosts.assignAll(postList); // Update filtered posts
        currentPage.value++;
      }
    } catch (e) {
      print("Error loading more posts: $e");
    } finally {
      loadingMore.value = false;
    }
  }

  // Fetch posts for the current logged-in user
  fetchUserPosts() async {
    var data = storage.read('USER_KEY');
    var userID = data['user']['id'];
    setRequestLoadingPostStatus(Status.loading);
    try {
      var request = PostBaseRequest(userId: userID, status: 'ACT'); // Update request to include userId and status
      var response = await _postRepository.getAllPosts(request);
      print('UserResponse ${response.data}');

      if (response.data != null && response.data is List) {
        userPost.assignAll(
          (response.data as List).map((data) => PostResponse.fromJson(data)).toList(),
        );
      } else {
        throw Exception("Invalid or empty data");
      }
      setRequestLoadingPostStatus(Status.completed);
    } catch (e) {
      setRequestLoadingPostStatus(Status.error);
      print("Error fetching user posts: $e");
    }
  }
  void searchPosts(String query) {
    if (query.isEmpty) {
      filteredPosts.assignAll(postList); // Reset to all posts
    } else {
      filteredPosts.assignAll(postList.where((post) {
        final title = post.title?.toLowerCase() ?? '';
        final description = post.description?.toLowerCase() ?? '';
        return title.contains(query.toLowerCase()) || description.contains(query.toLowerCase());
      }).toList());
    }
  }
  Future<void> refreshUserPosts() async {
    try {
      await fetchUserPosts(); // Logic to fetch user posts
    } catch (e) {
      // Handle errors
    }
  }


}
