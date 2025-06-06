  import 'dart:convert';
  import 'dart:io';

  import 'package:feed/core/common/custom_textfield.dart';
  import 'package:feed/core/utils/error_notice.dart';
  import 'package:feed/presentation/homescreen/homescreen.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'package:http/http.dart' as http;
  import 'package:image_cropper/image_cropper.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:page_transition/page_transition.dart';

  class ProfileCreation extends StatefulWidget {
    const ProfileCreation({super.key});

    @override
    State<ProfileCreation> createState() => _ProfileCreationState();
  }

  class _ProfileCreationState extends State<ProfileCreation> {
    final storage = const FlutterSecureStorage();
    final _formKey = GlobalKey<FormState>();
    final TextEditingController bio = TextEditingController();
    final TextEditingController username = TextEditingController();

    File? pfpImage;
    File? bannerImage;
    final ImagePicker _picker = ImagePicker();

    bool isLoading = false;

    // Upload profile picture and banner to backend
    Future<bool> pfpANDbanner() async {
      try {
        setState(() => isLoading = true);
        final url = Uri.parse('http://192.168.1.5:3000/upload/profile-banner');
        final token = await storage.read(key: 'jwt_token');

        if (token == null) {
          errorNotice(context, "Invalid Token, Please Login Again");
          setState(() => isLoading = false);
          return false;
        }

        var request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $token';

        if (pfpImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'profile_picture',
            pfpImage!.path,
          ));
        }

        if (bannerImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'banner',
            bannerImage!.path,
          ));
        }

        var response = await request.send();

        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          errorNotice(context, "Upload Successful");
          return true;
        } else {
          errorNotice(context, "Upload failed with status: ${response.statusCode}");
          return false;
        }
      } catch (e) {
        errorNotice(context, "An error occurred: $e");
        return false;
      } finally {
        setState(() => isLoading = false);
      }
    }

    // Send username and bio to backend
    Future<bool> sendUsernameAndBio() async {
      if (!_formKey.currentState!.validate()) return false;

      try {
        setState(() => isLoading = true);
        final url = Uri.parse('http://192.168.1.5:3000/profilecreation');
        final token = await storage.read(key: 'jwt_token');

        if (token == null) {
          errorNotice(context, "Invalid Token, Please Login Again");
          setState(() => isLoading = false);
          return false;
        }

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'username': username.text.trim(),
            'bio': bio.text.trim(),
          }),
        );

        if (response.statusCode == 200) {
          errorNotice(context, "Profile info updated!");
          await storage.write(key: 'profile_completed', value: 'true');
          return true;
        } else {
          errorNotice(context, "Update failed: ${response.statusCode}");
          return false;
        }
      } catch (e) {
        errorNotice(context, "An error occurred: $e");
        return false;
      } finally {
        setState(() => isLoading = false);
      }
    }

    // Pick and crop profile picture image
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

    // Pick and crop banner image
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

    // Dialog to choose camera or gallery
    Future<ImageSource?> _showImageSourceDialog() {
      return showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(
                  "Take a Photo",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(
                  "Choose from Gallery",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    }

    // Crop the selected image
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
            initAspectRatio:
                isPfp ? CropAspectRatioPreset.square : CropAspectRatioPreset.ratio16x9,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  Text("Profile Creation", style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 50),

                  // Username input
                  SizedBox(
                    width: 250,
                    child: Customtextfile(
                      controller: username,
                      obscureText: false,
                      prefixIcon: const Icon(Icons.person),
                      hinttext: "Enter your Username",
                      suffixText: '.feeduser',
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontFamily: "Texxt",
                        fontWeight: FontWeight.normal,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required';
                        }
                        if (value.contains(' ')) {
                          return 'Username cannot contain spaces';
                        }
                        if (value.length > 15) {
                          return 'Username cannot exceed 15 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bio input
                  SizedBox(
                    width: 300,
                    child: Customtextfile(
                      controller: bio,
                      prefixIcon: const Icon(Icons.featured_play_list_rounded),
                      obscureText: false,
                      hinttext: "Bio",
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontFamily: "Texxt",
                        fontWeight: FontWeight.normal,
                      ),
                      validator: (value) {
                        if (value != null && value.length > 200) {
                          return 'Bio cannot exceed 200 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Profile picture picker
                  Center(
                    child: GestureDetector(
                      onTap: pickPfp,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        child: ClipOval(
                          child: pfpImage != null
                              ? Image.file(pfpImage!, width: 100, height: 100, fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/images/pngwing.com.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Text('Profile Picture', style: Theme.of(context).textTheme.bodyLarge),
                  ),

                  const SizedBox(height: 20),

                  // Banner picker
                  GestureDetector(
                    onTap: pickBanner,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 3 / 1,
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: bannerImage != null
                              ? Image.file(bannerImage!, fit: BoxFit.cover)
                              : const Center(child: Icon(Icons.image, size: 40)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Text("Banner", style: Theme.of(context).textTheme.bodyLarge),
                  ),

                  const SizedBox(height: 20),

                  // Create Account button
                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              final bannerSuccess = await pfpANDbanner();
                              final profileSuccess = await sendUsernameAndBio();

                              if (bannerSuccess && profileSuccess) {
                                Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.fade,
                                    duration: const Duration(milliseconds: 300),
                                    reverseDuration: const Duration(milliseconds: 300),
                                    child: const Homescreen(),
                                  ),
                                );
                              } else {
                                errorNotice(context, "Failed to create profile. Please try again.");
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Create Account', style: Theme.of(context).textTheme.bodyMedium),
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
