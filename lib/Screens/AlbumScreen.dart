import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roomate_sync/Screens/FullScreenImageScreen.dart';
import 'package:roomate_sync/Screens/VideoPlayerScreen.dart';

class AlbumScreen extends StatefulWidget {
  final String roomCode;

  const AlbumScreen({Key? key, required this.roomCode}) : super(key: key);

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  bool selectionMode = false;
  final Set<String> selectedDocIds = {};

  void toggleSelection(String docId) {
    setState(() {
      if (selectedDocIds.contains(docId)) {
        selectedDocIds.remove(docId);
      } else {
        selectedDocIds.add(docId);
      }
      if (selectedDocIds.isEmpty) {
        selectionMode = false;
      }
    });
  }

  void deleteSelectedMedia() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Media'),
        content: Text('Are you sure you want to delete ${selectedDocIds.length} item(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      for (final docId in selectedDocIds) {
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomCode)
            .collection('media')
            .doc(docId)
            .delete();
      }
      setState(() {
        selectionMode = false;
        selectedDocIds.clear();
      });
    }
  }

  void openMedia(BuildContext context, String type, String url, List<QueryDocumentSnapshot> docs, int index) {
    if (selectionMode) return;

    if (type == 'image') {
      final imageUrls = docs
          .where((d) => d['mediaType'] == 'image')
          .map((d) => d['mediaUrl'] as String)
          .toList();
      final imageIndex = imageUrls.indexOf(url);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageScreen(
            imageUrls: imageUrls,
            initialIndex: imageIndex,
          ),
        ),
      );
    } else if (type == 'video') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: url)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B45),
        title: selectionMode
            ? Text('${selectedDocIds.length} selected')
            : const Text('Album', style: TextStyle(color: Colors.white)),
        leading: selectionMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              selectionMode = false;
              selectedDocIds.clear();
            });
          },
        )
            : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B0B45),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .doc(widget.roomCode)
              .collection('media')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  'No media uploaded yet',
                  style: TextStyle(color: Colors.white,fontSize: 20),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              itemCount: docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final url = doc['mediaUrl'];
                final type = doc['mediaType'];
                final docId = doc.id;
                final selected = selectedDocIds.contains(docId);

                return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      selectionMode = true;
                      toggleSelection(docId);
                    });
                  },
                  onTap: () {
                    if (selectionMode) {
                      toggleSelection(docId);
                    } else {
                      openMedia(context, type, url, docs, index);
                    }
                  },
                  child: Stack(
                    children: [
                      Hero(
                        tag: url,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: Colors.black12,
                            child: type == 'image'
                                ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const Center(child: CircularProgressIndicator()),
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 40, color: Colors.white),
                            )
                                : const Center(
                              child: Icon(Icons.play_circle_fill,
                                  color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                      ),
                      if (selectionMode)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => toggleSelection(docId),
                            child: Icon(
                              selected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: selected ? Colors.blue : Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: selectionMode && selectedDocIds.isNotEmpty
          ? FloatingActionButton(
        onPressed: deleteSelectedMedia,
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
      )
          : null,
    );
  }
}
