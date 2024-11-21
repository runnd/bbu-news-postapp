import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:product_app/post/create_post/controller/create_post_controller.dart';
import 'package:product_app/post/category/view_model/post_category_view_model.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({Key? key}) : super(key: key);

  @override
  _CreatePostViewState createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final CreatePostController postController = Get.put(CreatePostController());
  final PostCategoryViewModel categoryViewModel = Get.put(PostCategoryViewModel());

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _selectedCategoryName;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Add a delay to allow time for imageFilePath to be set in viewModel
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {}); // Rebuild the widget after the delay
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26247B),
        title: Text(
          postController.postRequest.value.id != 0 ? 'Update Post' : 'Create Post',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_selectedCategoryId == null || _selectedImage == null) {
                Get.snackbar("Error", "Please select a category and image");
                return;
              }
              postController.onCreateOrUpdatePost(
                postController.postRequest.value.id ?? 0,
              );
            },
            child: Text(
              postController.postRequest.value.id != 0 ? 'UPDATE' : 'CREATE',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Picker
              GestureDetector(
                onTap: () async {
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                      postController.selectedImage = _selectedImage;
                    });
                  }
                },
                child: Column(
                  children: [
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (postController.postRequest.value.id != 0)
                      Image.network(
                        "${postController.imageFilePath}${postController.imageFilePath}",
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else
                      Image.asset(
                        'assets/images/icons/no-image.jpg',
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 10),
                    const Text('Choose Image', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title Input Field
              TextField(
                controller: postController.postTitleController.value,
                decoration: InputDecoration(
                  hintText: 'Title',
                  prefixIcon: const Icon(Icons.edit, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              // Description Input Field
              TextField(
                controller: postController.postDescriptionController.value,
                decoration: InputDecoration(
                  hintText: 'Description',
                  prefixIcon: const Icon(Icons.description, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              // Category Dropdown
              Obx(() {
                if (categoryViewModel.categoryList.isEmpty) {
                  return const CircularProgressIndicator();
                }

                return DropdownButton<int>(
                  value: _selectedCategoryId,
                  hint: const Text("Select Category"),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategoryId = newValue;
                      _selectedCategoryName = categoryViewModel
                          .categoryList
                          .firstWhere((category) => category.id == newValue)
                          .name;
                      postController.selectedCategory.value =
                          categoryViewModel.categoryList.firstWhere((category) => category.id == newValue);
                    });
                  },
                  items: categoryViewModel.categoryList.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name ?? "Unknown Category"),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 30),

              // Create Button
              ElevatedButton(
                onPressed: () {
                  if (_selectedCategoryId == null || _selectedImage == null) {
                    Get.snackbar("Error", "Please select a category and image");
                    return;
                  }
                  // Call the method to create a new post
                  postController.onCreateOrUpdatePost(0); // Pass 0 or nothing if only creation is needed
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26247B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'CREATE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
