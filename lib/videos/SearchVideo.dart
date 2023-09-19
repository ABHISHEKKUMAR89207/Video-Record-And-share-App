import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:signupwithotp/videos/playSelectedVideo.dart';

class SearchVideo extends StatefulWidget {
  @override
  _SearchVideoState createState() => _SearchVideoState();
}

class _SearchVideoState extends State<SearchVideo> {
  String searchQuery = '';
  List<QueryDocumentSnapshot> filteredVideos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 43, 159, 186),
        title: Text(
          'Search Videos',
          style: TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(58.0),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search videos...',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 23, 134, 49),
                    fontSize: 16.0,
                  ),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  suffixIcon: IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 23, 134, 49),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 32.0,
                      ),
                    ),
                    onPressed: () {
                      _performSearch();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
        ),
        itemCount: filteredVideos.length,
        itemBuilder: (context, index) {
          final video = filteredVideos[index];
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.thumb_up,
                              color: Color.fromARGB(255, 68, 218, 75),
                              size: 32.0,
                            ),
                            Icon(
                              Icons.thumb_down,
                              color: const Color.fromARGB(255, 203, 41, 41),
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
      ),
    );
  }

  void _performSearch() {
    if (searchQuery.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a something.'),
        ),
      );
      return;
    }

    String lowercaseSearchQuery = searchQuery.toLowerCase();

    FirebaseFirestore.instance
        .collection('Videos')
        .where('title', isGreaterThanOrEqualTo: lowercaseSearchQuery)
        .where('title', isLessThan: lowercaseSearchQuery + 'z')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        filteredVideos = querySnapshot.docs;
      });
    }).catchError((error) {});
  }
}
