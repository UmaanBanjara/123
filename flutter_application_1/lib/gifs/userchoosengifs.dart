import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feed/core/common/custom_textfield.dart';
import 'package:feed/core/utils/error_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

class Userchoosengifs extends StatefulWidget {
  const Userchoosengifs({super.key});

  @override
  State<Userchoosengifs> createState() => _UserchoosengifsState();
}

class _UserchoosengifsState extends State<Userchoosengifs> {
  final TextEditingController _searchgifs = TextEditingController();
  List gifs = [];
  bool isLoading = false;

  Timer? _debounce;

  Future<void> fetchGifs(String query) async {
    if (query.isEmpty) {
      setState(() {
        gifs = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.1.5:3000/search?q=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          gifs = data['results'] ?? [];
        });
      } else {
        errorNotice(context, "Something went wrong");
      }
    } catch (error) {
      errorNotice(context, "Something went wrong");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Debounce the search input
    _searchgifs.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        fetchGifs(_searchgifs.text.trim());
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchgifs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // No GIF selected
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Customtextfile(
              controller: _searchgifs,
              obscureText: false,
              minlines: 1,
              maxlines: 1,
              cursorHeight: 20,
              hinttext: "Search for GIFs",
              textStyle: const TextStyle(fontSize: 14, fontFamily: "rEGULAR"),
              hintStyle: const TextStyle(fontFamily: "hEAVY"),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : gifs.isEmpty
                    ? const Center(child: Text("No GIFs found"))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: MasonryGridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          itemCount: gifs.length,
                          itemBuilder: (context, index) {
                            final gif = gifs[index];
                            final gifUrl =
                                gif['media_formats']?['gif']?['url'] ?? '';

                            if (gifUrl.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context, gifUrl); // Return selected GIF
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: gifUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error, color: Colors.red),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
