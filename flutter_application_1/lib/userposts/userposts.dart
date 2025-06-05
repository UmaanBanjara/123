import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:feed/core/common/custom_textfield.dart';
import 'package:feed/core/utils/error_notice.dart';
import 'package:feed/gifs/userchoosengifs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final storage = FlutterSecureStorage();
  Position? _currentPosition;
  String? _locationText;
  LatLng? _userLatLng;

  final List<String> _gifUrls = [];
  final TextEditingController postController = TextEditingController();
  final List<XFile> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();
  final Map<String, VideoPlayerController> _videoControllers = {};

  // Removed compressVideo and storeindb methods entirely

  Future<void> _initializeVideoController(XFile file) async {
    final controller = VideoPlayerController.file(File(file.path));
    await controller.initialize();
    controller.setLooping(true);
    controller.setVolume(0);
    controller.play();

    setState(() {
      _videoControllers[file.path] = controller;
    });
  }

  Future<void> _handleLocationPermission() async {
    var status = await Permission.location.status;

    if (!status.isGranted) {
      status = await Permission.location.request();
    }

    if (status.isGranted) {
      await _getCurrentLocation();
    } else {
      errorNotice(context, 'Location Permission Denied');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final placemark = placemarks.first;
      final locationName = '${placemark.locality}, ${placemark.administrativeArea}';

      setState(() {
        _currentPosition = position;
        _locationText = locationName;
        _userLatLng = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      errorNotice(context, 'Error getting Location $e');
    }
  }

  Future<void> pickMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
    );

    if (result != null) {
      final List<XFile> selectedFiles =
          result.files.map((file) => XFile(file.path!)).toList();

      setState(() {
        _mediaFiles.addAll(selectedFiles);
      });

      for (var file in selectedFiles) {
        if (file.path.toLowerCase().endsWith('.mp4') ||
            file.path.toLowerCase().endsWith('.mov') ||
            file.path.toLowerCase().endsWith('.avi')) {
          await _initializeVideoController(file);
        }
      }
    }
  }

  Future<void> pickFromCamera() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      File imageFile = File(picked.path);
      final cropped = await cropImage(imageFile, isPfp: true);
      setState(() {
        _mediaFiles.add(XFile((cropped ?? imageFile).path));
      });
    }
  }

  Future<void> showMediaSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add Media',
          style: TextStyle(fontSize: 20, fontFamily: "rEGULAR"),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(
                "Choose from Gallery",
                style: TextStyle(fontSize: 20, fontFamily: "rEGULAR"),
              ),
              onTap: () {
                Navigator.pop(context);
                pickMedia();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(
                "Take a Photo",
                style: TextStyle(fontSize: 20, fontFamily: "rEGULAR"),
              ),
              onTap: () {
                Navigator.pop(context);
                pickFromCamera();
              },
            ),
          ],
        ),
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
          initAspectRatio: isPfp
              ? CropAspectRatioPreset.square
              : CropAspectRatioPreset.ratio16x9,
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
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close, size: 30),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: TextButton(
              onPressed: () async {
                // Backend-related logic removed; do nothing here
              },
              child: const Text(
                'Post',
                style: TextStyle(fontSize: 20, fontFamily: "bOLD"),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Customtextfile(
              controller: postController,
              obscureText: false,
              minlines: 1,
              maxlines: 15,
              cursorHeight: 20,
              hinttext: "What's up?",
              hintStyle: const TextStyle(fontFamily: "hEAVY"),
              textStyle: const TextStyle(fontSize: 14, fontFamily: "rEGULAR"),
            ),
          ),
          if (_gifUrls.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _gifUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _gifUrls[index],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _gifUrls.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: MasonryGridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                itemCount: _mediaFiles.length,
                itemBuilder: (context, index) {
                  final file = _mediaFiles[index];
                  final isVideo = file.path.toLowerCase().endsWith(".mp4") ||
                      file.path.toLowerCase().endsWith(".mov") ||
                      file.path.toLowerCase().endsWith(".avi");

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: isVideo
                            ? (_videoControllers[file.path] != null &&
                                    _videoControllers[file.path]!.value.isInitialized)
                                ? AspectRatio(
                                    aspectRatio:
                                        _videoControllers[file.path]!.value.aspectRatio,
                                    child: VideoPlayer(_videoControllers[file.path]!),
                                  )
                                : Container(
                                    height: 150,
                                    color: Colors.black12,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                            : Image.file(
                                File(file.path),
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              final removedFile = _mediaFiles.removeAt(index);
                              if (_videoControllers.containsKey(removedFile.path)) {
                                _videoControllers[removedFile.path]!.dispose();
                                _videoControllers.remove(removedFile.path);
                              }
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Map and Location Info Section
          if (_userLatLng != null)
            Column(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _userLatLng!,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80,
                            height: 80,
                            point: _userLatLng!,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _locationText ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: showMediaSourceDialog,
                icon: const Icon(Icons.photo_library, size: 30),
              ),
              IconButton(
                onPressed: () async {
                  final selectedGif = await Navigator.push<String>(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      duration: const Duration(milliseconds: 300),
                      reverseDuration: const Duration(milliseconds: 300),
                      child: const Userchoosengifs(),
                    ),
                  );

                  if (selectedGif != null && selectedGif.isNotEmpty) {
                    setState(() {
                      _gifUrls.add(selectedGif);
                    });
                  }
                },
                icon: const Icon(Icons.gif, size: 30),
              ),
              IconButton(
                onPressed: () {
                  _handleLocationPermission();
                },
                icon: const Icon(Icons.location_on, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
