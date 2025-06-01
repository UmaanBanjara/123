import 'dart:convert';
import 'dart:io';

import 'package:feed/core/utils/error_notice.dart';
import 'package:feed/presentation/profilescreen/profilepageuser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:feed/core/common/custom_textfield.dart';
import 'package:page_transition/page_transition.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController bio = TextEditingController();
  final storage = const FlutterSecureStorage();

  bool isLoading = false;
  File? pfpImage;
  File? bannerImage;

  // For showing existing profile images before edit
  String? pfpNetworkUrl;
  String? bannerNetworkUrl;

  final ImagePicker _picker = ImagePicker();

  Future<Map<String, dynamic>?> updateImage() async {
    setState(() => isLoading = true);
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      setState(() => isLoading = false);
      errorNotice(context, 'Not Authenticated');
      return null;
    }

    final uri = Uri.parse('http://192.168.1.5:3000/uploadfiles');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    if (pfpImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_picture', pfpImage!.path));
    }
    if (bannerImage != null) {
      request.files.add(await http.MultipartFile.fromPath('banner', bannerImage!.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        errorNotice(context, 'Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      setState(() => isLoading = false);
      errorNotice(context, 'An error occurred: $e');
      return null;
    }
  }

  Future<void> fetchUserProfile() async {
    setState(() => isLoading = true);
    final token = await storage.read(key: 'jwt_token');

    if (token == null) {
      setState(() => isLoading = false);
      errorNotice(context, 'Not Authenticated');
      return;
    }

    final url = Uri.parse('http://192.168.1.5:3000/getuserdetail'); // Use your actual endpoint

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // IMPORTANT FIX: Access nested 'user' object inside JSON response
        final data = decoded['user'];

        setState(() {
          username.text = data['username'] ?? '';
          bio.text = data['bio'] ?? '';
          pfpNetworkUrl = data['profile_picture_url'];
          bannerNetworkUrl = data['banner_url'];
        });
      } else {
        final decoded = jsonDecode(response.body);
        errorNotice(context, decoded['error'] ?? 'Failed to load profile');
      }
    } catch (e) {
      errorNotice(context, 'Error fetching profile: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> createProfile(String? profilePictureUrl, String? bannerPictureUrl) async {
    final token = await storage.read(key: 'jwt_token');
    final url = Uri.parse('http://192.168.1.5:3000/profilecreation');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username.text.trim(),
          'bio': bio.text.trim(),
          'profile_picture_url': profilePictureUrl,
          'banner_url': bannerPictureUrl,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        errorNotice(context, "Profile Updated Successfully");
        return true;
      } else {
        errorNotice(context, data['error'] ?? "Profile Update Failed. Please Try Again");
        return false;
      }
    } catch (e) {
      errorNotice(context, "Network Error. Please Try Again Later");
      return false;
    }
  }

  Future<void> pickPfp() async {
    final source = await _showImageSourceDialog();
    if (source != null) {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        File imageFile = File(picked.path);
        final cropped = await cropImage(imageFile, isPfp: true);
        setState(() => pfpImage = cropped ?? imageFile);
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
        setState(() => bannerImage = cropped ?? imageFile);
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

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  void dispose() {
    bio.dispose();
    username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const SizedBox(height: 10),
                      Text("Edit Profile", style: Theme.of(context).textTheme.headlineSmall),
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
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            child: ClipOval(
                              child: pfpImage != null
                                  ? Image.file(pfpImage!, width: 100, height: 100, fit: BoxFit.cover)
                                  : (pfpNetworkUrl != null && pfpNetworkUrl!.isNotEmpty
                                      ? Image.network(pfpNetworkUrl!, width: 100, height: 100, fit: BoxFit.cover)
                                      : Image.asset('assets/images/pngwing.com.png', width: 100, height: 100)),
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
                              color: Colors.grey[300],
                              child: bannerImage != null
                                  ? Image.file(bannerImage!, fit: BoxFit.cover)
                                  : (bannerNetworkUrl != null && bannerNetworkUrl!.isNotEmpty
                                      ? Image.network(bannerNetworkUrl!, fit: BoxFit.cover)
                                      : const Center(child: Icon(Icons.image, size: 40))),
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
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => isLoading = true);

                                    // Upload images first
                                    Map<String, dynamic>? uploadResult = await updateImage();

                                    if (uploadResult == null) {
                                      setState(() => isLoading = false);
                                      return;
                                    }

                                    // Extract URLs or fallback to previous URLs
                                    String? profilePictureUrl =
                                        uploadResult['profile_picture_url'] ?? pfpNetworkUrl;
                                    String? bannerPictureUrl = uploadResult['banner_url'] ?? bannerNetworkUrl;

                                    // Update profile
                                    bool success = await createProfile(profilePictureUrl, bannerPictureUrl);

                                    setState(() => isLoading = false);

                                    if (success) {
                                      Navigator.pop(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.fade,
                                          duration: const Duration(milliseconds: 300),
                                          reverseDuration: const Duration(milliseconds: 300),
                                          child: const UserProfile(),
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: const Text('Update Profile'),
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
