import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signupwithotp/Signuppage.dart';
import 'package:signupwithotp/bottomnavigator.dart';
import 'package:signupwithotp/users/AppBar.dart';
import 'package:signupwithotp/videos/SearchVideo.dart';

import 'package:signupwithotp/videos/playSelectedVideo.dart';

class ExploreVideos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 43, 159, 186),
          title: Text(
            'Explore',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SearchVideo(),
                ));
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                _showLogoutConfirmationDialog(context);
              },
              child: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Videos').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            final videos = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                final category = video['category'] ?? '';
                final description = video['description'] ?? '';
                final location = video['location'] ?? '';
                final name = video['name'] ?? '';
                final profileImg = video['profileimg'] ?? '';
                final title = video['title'] ?? '';
                final username = video['username'] ?? '';
                final videoUrl = video['videoUrl'] ?? '';
                final thumbnail = video['thumbnail'] ?? '';
                final documentId = video.id;

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PlaySelectedVideo(
                            documentId: documentId, videoPath: videoUrl),
                      ),
                    );
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
                              // child: Image.asset(
                              //   'assets/download.jpg',
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
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        profileImg,
                                        // child: Image.asset(
                                        //   'assets/profile.png',
                                        width: 40.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    color: Color.fromARGB(255, 68, 218, 75),
                                    size: 32.0,
                                  ),
                                  Icon(
                                    Icons.thumb_down,
                                    color:
                                        const Color.fromARGB(255, 203, 41, 41),
                                    size: 32.0,
                                  ),
                                  Icon(
                                    Icons.share,
                                    color: Color.fromARGB(255, 11, 93, 151),
                                    size: 32.0,
                                  ),
                                ],
                              )
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
        ),
        bottomNavigationBar: BottomNavigatorExample(),
      ),
    );
  }
}

void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Logout",
          style: TextStyle(
            color: Color.fromARGB(255, 4, 94, 97),
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: TextStyle(
            color: Color.fromARGB(255, 4, 94, 97),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PhoneOtpSignupPage()),
              );
            },
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
