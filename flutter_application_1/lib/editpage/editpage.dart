import 'dart:convert';
import 'dart:io';

import 'package:feed/core/utils/error_notice.dart';
import 'package:feed/presentation/homescreen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // Add http package in pubspec.yaml
import 'package:feed/core/common/custom_textfield.dart';
import 'package:page_transition/page_transition.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController bio = TextEditingController();

  bool isLoading = true;
  bool isError = false;

  File? pfpImage;
  File? bannerImage;

  // For remote images (URLs)
  String? pfpUrl;
  String? bannerUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final token = await storage.read(key: 'jwt_token');

      final response = await http.get(
        Uri.parse('http://192.168.1.5:3000/getuserdetails'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userDetails = data['userDetails'];

        setState(() {
          username.text = userDetails['username'] ?? '';
          bio.text = userDetails['bio'] ?? '';
          pfpUrl = userDetails['profile_picture_url'];
          bannerUrl = userDetails['banner_url'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Future<void> pickPfp() async {
    final source = await _showImageSourceDialog();
    if (source != null) {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        File imageFile = File(picked.path);
        final cropped = await cropImage(imageFile, isPfp: true);
        setState(() {
          pfpImage = cropped ?? imageFile;
          pfpUrl = null; // Clear URL because user picked a new image
        });
      }
    }
  }

  Future<void> pickBanner() async {
    final source = await _showImageSourceDialog();
    if (source != null) {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        File imageFile = File(picked.path);
        final cropped = await cropImage(imageFile, isPfp: false);
        setState(() {
          bannerImage = cropped ?? imageFile;
          bannerUrl = null; // Clear URL because user picked a new image
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<File?> cropImage(File imageFile, {required bool isPfp}) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: isPfp
          ? const CropAspectRatio(ratioX: 1, ratioY: 1)
          : const CropAspectRatio(ratioX: 3, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final token = await storage.read(key: 'jwt_token');

      // For now, send URLs if images are not changed, empty strings otherwise
      // TODO: implement image upload and set URLs accordingly
      final profilePictureToSend = pfpUrl ?? '';
      final bannerToSend = bannerUrl ?? '';

      final response = await http.post(
        Uri.parse('http://192.168.1.5:3000/profilecreation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username.text.trim(),
          'profile_picture_url': profilePictureToSend,
          'banner_url': bannerToSend,
          'bio': bio.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        errorNotice(context, data['message'] ?? 'Profile updated successfully!');
      } else {
        final data = jsonDecode(response.body);
        errorNotice(context, data['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      errorNotice(context, 'Error updating profile. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    bio.dispose();
    username.dispose();
    super.dispose();
  }

  Widget _buildProfilePicture() {
    if (pfpImage != null) {
      return Image.file(pfpImage!, width: 100, height: 100, fit: BoxFit.cover);
    } else if (pfpUrl != null && pfpUrl!.isNotEmpty) {
      return Image.network(pfpUrl!, width: 100, height: 100, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/images/pngwing.com.png', width: 100, height: 100);
      });
    } else {
      return Image.asset('assets/images/pngwing.com.png', width: 100, height: 100);
    }
  }

  Widget _buildBannerImage() {
    if (bannerImage != null) {
      return Image.file(bannerImage!, fit: BoxFit.cover);
    } else if (bannerUrl != null && bannerUrl!.isNotEmpty) {
      return Image.network(bannerUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.image, size: 40));
      });
    } else {
      return const Center(child: Icon(Icons.image, size: 40));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load user data.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchUserDetails,
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 10),
                const Text("Edit Profile", style: TextStyle(fontFamily: "Primary", fontSize: 25)),
                const SizedBox(height: 30),

                // Username
                Customtextfile(
                  controller: username,
                  obscureText: false,
                  prefixIcon: const Icon(Icons.person),
                  suffixText: '.feeduser',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Username required';
                    if (value.contains(' ')) return 'No spaces allowed';
                    if (value.length > 10) return 'Max 10 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Bio
                Customtextfile(
                  controller: bio,
                  prefixIcon: const Icon(Icons.info_outline),
                  obscureText: false,
                  hinttext: 'Bio',
                  validator: (value) {
                    if (value != null && value.length > 300) return 'Max 300 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Profile Picture
                Center(
                  child: GestureDetector(
                    onTap: pickPfp,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      radius: 50,
                      child: ClipOval(
                        child: _buildProfilePicture(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(child: Text('Profile Picture')),

                const SizedBox(height: 20),

                // Banner
                GestureDetector(
                  onTap: pickBanner,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 3 / 1,
                      child: Container(
                        child: _buildBannerImage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(child: Text("Banner")),

                const SizedBox(height: 30),

                // Submit button
                Center(
                  child: ElevatedButton(
                    onPressed:(){ 
                      
                      _updateProfile();
                      Navigator.push(context, PageTransition(
                        type: PageTransitionType.fade , 
                        duration: Duration(milliseconds: 300) , 
                        reverseDuration: Duration(milliseconds: 300) , 
                        child: Homescreen()
                      ));
                      
                      },
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
