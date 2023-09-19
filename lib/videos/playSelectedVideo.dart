import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlaySelectedVideo extends StatefulWidget {
  final String videoPath;
  final String documentId;
  PlaySelectedVideo({required this.documentId, required this.videoPath});

  @override
  _PlaySelectedVideoState createState() => _PlaySelectedVideoState();
}

class _PlaySelectedVideoState extends State<PlaySelectedVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    final videoUrl = widget.videoPath;

    setState(() {
      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {});
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 43, 159, 186),
        title: Text(
          'Video Play',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: _controller != null && _controller.value.isInitialized
            ? StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Videos')
                    .doc(widget.documentId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final videoData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  if (videoData == null) {
                    return Center(child: Text('Video not found'));
                  }

                  final title = videoData['title'] ?? '';
                  final username = videoData['username'] ?? '';

                  final profileImg =
                      videoData['profileimg'] ?? 'assets/profile.png';
                  final description = videoData['description'] ?? '';
                  final location = videoData['location'] ?? '';
                  final category = videoData['category'] ?? '';
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 300,
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                          SizedBox(height: 1),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_controller.value.isPlaying) {
                                        _controller.pause();
                                      } else {
                                        _controller.play();
                                      }
                                    });
                                  },
                                  child: Icon(
                                    _controller?.value.isPlaying ?? false
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _openFullScreen(context);
                                  },
                                  child: Icon(Icons.fullscreen),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 500,
                        ),
                        color: Colors.black,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 46, 47, 47),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.amber),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                            right: 5.0, left: 5.0),
                                        child: Icon(
                                          Icons.thumb_up,
                                          color:
                                              Color.fromARGB(255, 68, 218, 75),
                                          size: 32.0,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            right: 5.0, left: 5.0),
                                        child: Icon(
                                          Icons.thumb_down,
                                          color: const Color.fromARGB(
                                              255, 203, 41, 41),
                                          size: 32.0,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            right: 5.0, left: 5.0),
                                        child: Icon(
                                          Icons.share,
                                          color:
                                              Color.fromARGB(255, 11, 93, 151),
                                          size: 32.0,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              margin: EdgeInsets.all(4),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 161, 216, 211),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    // child: Image.asset(
                                    //   profileImg,
                                    child: Image.asset(
                                      'assets/profile.png',
                                      width: 40.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(6),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 186, 190, 189),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '#$location',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green),
                                      ),
                                      Text(
                                        ' #$category',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 149, 72, 14)),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              )
            : Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              ),
      ),
    );
  }

  void _openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}
