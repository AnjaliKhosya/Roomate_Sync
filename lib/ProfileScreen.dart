import 'dart:convert';
import 'dart:io';
import 'package:roomate_sync/loginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  final String roomCode;

  const ProfileScreen({Key? key, required this.roomCode}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  String profileImage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(
        user.uid).get();
    final data = doc.data() ?? {};

    setState(() {
      nameController.text = data['name'] ?? '';
      upiController.text = data['upiId'] ?? '';
      profileImage = data['profileImage'] ?? '';
      isLoading = false;
    });
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 75);

    if (picked != null) {
      setState(() => isLoading = true);
      final url = await uploadToCloudinary(File(picked.path));
      if (url != null) {
        await FirebaseFirestore.instance.collection('users')
            .doc(user.uid)
            .update({
          'profileImage': url,
        });
        setState(() {
          profileImage = url;
          isLoading = false;
        });
      }
    }
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    const cloudName = 'dflkb3opw';
    const uploadPreset = 'RoomateSyncPreset';

    final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      return data['secure_url'];
    } else {
      debugPrint("Cloudinary Upload Failed: ${response.statusCode}");
      return null;
    }
  }

  Future<void> updateProfileData() async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': nameController.text.trim(),
      'upiId': upiController.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  void logout() async {
    final user = FirebaseAuth.instance.currentUser;

    // Get the list of sign-in methods (providers) for this user
    final providerData = user?.providerData ?? [];

    for (final provider in providerData) {
      if (provider.providerId == 'google.com') {
        await GoogleSignIn().signOut(); // Sign out from Google only if used
        break;
      }
    }

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => loginScreen()),
          (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B0B45),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B45),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: logout,
        backgroundColor: Colors.amber,
        elevation: 4,
        child: const Icon(Icons.logout, color: Colors.black,),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : const AssetImage(
                          'assets/images/DefaultImage.jpg') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_outlined, size: 20,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              buildInputField("Name", nameController),
              const SizedBox(height: 16),
              buildInputField("UPI ID", upiController),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 170,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: updateProfileData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text("Update Profile",
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        labelText: ' ',
        // Prevent floating label animation
        labelStyle: const TextStyle(color: Colors.transparent),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black26),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

}
