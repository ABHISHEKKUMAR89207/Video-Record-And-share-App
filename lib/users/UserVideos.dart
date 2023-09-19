import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signupwithotp/Signuppage.dart';
import 'package:signupwithotp/bottomnavigator.dart';
import 'package:signupwithotp/users/AppBar.dart';
import 'package:signupwithotp/videos/SearchVideo.dart';

import 'package:signupwithotp/videos/playSelectedVideo.dart';

class UserVideos extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    String documentId,
    String thumbnail,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Video"),
          content: Text("Are you sure you want to delete this video?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final videoReference = FirebaseFirestore.instance
                    .collection('userdatacollection')
                    .doc(user?.uid)
                    .collection('videos')
                    .doc(documentId);

                await videoReference.delete();

                final vdCollection =
                    FirebaseFirestore.instance.collection('Videos');
                final querySnapshot = await vdCollection
                    .where('thumbnail', isEqualTo: thumbnail)
                    .get();

                final batch = FirebaseFirestore.instance.batch();
                querySnapshot.docs.forEach((doc) {
                  batch.delete(doc.reference);
                });
                await batch.commit();

                Navigator.of(context).pop();
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 43, 159, 186),
        title: Text(
          'User Videos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userdatacollection')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('No data available'),
            );
          }

          final userData = snapshot.data;
          final videosCollection = userData!.reference.collection('videos');

          return StreamBuilder<QuerySnapshot>(
            stream: videosCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final videos = snapshot.data!.docs;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                ),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];

                  final title = video['title'] ?? '';
                  final videoUrl = video['videoUrl'] ?? '';
                  final thumbnail = video['thumbnail'] ?? '';
                  final documentId = video.id;

                  return GestureDetector(
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => PlaySelectedVideo(
                      //         documentId: documentId, videoPath: videoUrl),
                      //   ),
                      // );
                    },
                    child: Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        color: Color.fromARGB(255, 184, 214, 214),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.network(
                                thumbnail,
                                width: double.infinity,
                                height: 260.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          color:
                                              Color.fromARGB(255, 68, 218, 75),
                                          size: 32.0,
                                        ),
                                        Icon(
                                          Icons.thumb_down,
                                          color: const Color.fromARGB(
                                              255, 203, 41, 41),
                                          size: 32.0,
                                        ),
                                        Icon(
                                          Icons.share,
                                          color:
                                              Color.fromARGB(255, 11, 93, 151),
                                          size: 32.0,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showDeleteConfirmationDialog(
                                        context, documentId, thumbnail);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 7.0),
                                    child: Icon(
                                      Icons.delete,
                                      color: Color.fromARGB(255, 11, 93, 151),
                                      size: 32.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigatorExample(),
    );
  }
}
