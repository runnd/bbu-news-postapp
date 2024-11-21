import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product_app/data/remote/api_url.dart';
import 'package:product_app/post/account/controller/account_controller.dart';
import 'package:product_app/post/auth/register/view/register_view.dart';

class AccountView extends StatelessWidget {
  AccountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AccountController controller = Get.put(AccountController());

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final user = controller.user.value?.user;
        if (user == null) {
          return const Center(child: Text('No user data available.'));
        }

        final profileImageUrl = '${ApiUrl.imageViewPath}${user.profile ?? ""}';

        // Check if the user has ROLE_ADMIN
        final isAdmin = user.roles?.any((role) => role.name == 'ROLE_ADMIN') ?? true;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User profile picture with CachedNetworkImage
              CachedNetworkImage(
                imageUrl: profileImageUrl,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 50,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: const CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // User name and admin status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${user.firstName ?? "Not Available"} ${user.lastName ?? "Not Available"}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 8),
                  if (isAdmin)
                    Tooltip(
                      message: 'This user is verified',
                      preferBelow: true,
                      verticalOffset: 20,
                      child: const Icon(
                        Icons.verified,
                        color: Colors.blueAccent,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                user.username ?? "Not Available",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // "My Profile" section
              _buildSettingItem(
                icon: Icons.person,
                label: 'My Account',
                onTap: () {
                  Get.to(() => RegisterView());
                },
              ),
              const SizedBox(height: 12),

              // "Language" section
              _buildSettingItem(
                icon: Icons.language,
                label: 'Language',
                trailing: const Text(
                  'English',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                onTap: () {
                  // Add language selection logic
                },
              ),
              const SizedBox(height: 12),

              // "Logout" section
              _buildSettingItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () {
                  controller.logout();
                },
              ),
              const SizedBox(height: 20),

              // Additional user info sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.phone, 'Phone', user.phoneNumber ?? "Not Available"),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.email, 'Email', user.email ?? "Not Available"),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.verified_user,
                      'Role',
                      user.roles?.isNotEmpty == true
                          ? user.roles!.first.name ?? "Not Available"
                          : "Not Available",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: Colors.black54),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.black54,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF26247B)),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
