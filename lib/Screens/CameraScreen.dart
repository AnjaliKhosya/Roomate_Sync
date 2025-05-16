import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class CameraScreen extends StatefulWidget {
  final String roomCode;
  const CameraScreen({Key? key, required this.roomCode}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? mediaFile;
  String? mediaType; // 'image' or 'video'
  bool isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickMedia(ImageSource source, {required bool isVideo}) async {
    final XFile? pickedFile = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        mediaFile = File(pickedFile.path);
        mediaType = isVideo ? 'video' : 'image';
      });

      final mediaUrl = await uploadMediaToCloudinary(mediaFile!, mediaType!);
      if (mediaUrl != null) {
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomCode)
            .collection('media')
            .add({
          'mediaUrl': mediaUrl,
          'mediaType': mediaType,
          'timestamp': Timestamp.now(),
        });

        print('Media uploaded and saved to Firestore');
      }
    }
  }

  Future<String?> uploadMediaToCloudinary(File file, String type) async {
    try {
      final url = dotenv.env['CLOUDINARY_URL']!;
      final preset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = preset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        final mediaUrl = jsonResponse['secure_url'];

        print('$type uploaded: $mediaUrl');
        return mediaUrl;
      } else {
        print('Upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during upload: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = mediaType == 'video';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Media Display
            Center(
              child: isUploading
                  ? const CircularProgressIndicator()
                  : mediaFile == null
                  ? Image.asset(
                'assets/images/camerabackground.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
                  : isVideo
                  ? const Icon(Icons.videocam, size: 80)
                  : Image.file(
                mediaFile!,
                fit: BoxFit.cover,
              ),
            ),

            // Back Icon
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.arrow_back, color: Colors.amber,size: 30,)
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 5),
              FloatingActionButton(
                heroTag: 'camImg',
                onPressed: () async {
                  setState(() => isUploading = true);
                  await pickMedia(ImageSource.camera, isVideo: false);
                  setState(() => isUploading = false);
                },
                backgroundColor: Colors.amber,
                tooltip: 'Capture Image',
                child: const Icon(Icons.photo_camera,size: 30,),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'camVid',
                onPressed: () async {
                  setState(() => isUploading = true);
                  await pickMedia(ImageSource.camera, isVideo: true);
                  setState(() => isUploading = false);
                },
                tooltip: 'Record Video',
                backgroundColor: Colors.amber,
                child: const Icon(Icons.videocam,size: 30,),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'galImg',
                onPressed: () async {
                  setState(() => isUploading = true);
                  await pickMedia(ImageSource.gallery, isVideo: false);
                  setState(() => isUploading = false);
                },
                tooltip: 'Pick Image from Gallery',
                backgroundColor: Colors.amber,
                child: const Icon(Icons.photo_library,size: 30,),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'galVid',
                onPressed: () async {
                  setState(() => isUploading = true);
                  await pickMedia(ImageSource.gallery, isVideo: true);
                  setState(() => isUploading = false);
                },
                tooltip: 'Pick Video from Gallery',
                backgroundColor: Colors.amber,
                child: const Icon(Icons.video_library,size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
