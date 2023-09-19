import 'package:flutter/material.dart';
import 'package:signupwithotp/components/RecordVideo.dart';
import 'package:signupwithotp/users/UserVideos.dart';
import 'package:signupwithotp/videos/ExploreVideos.dart';

class BottomNavigatorExample extends StatefulWidget {
  @override
  _BottomNavigatorExampleState createState() => _BottomNavigatorExampleState();
}

class _BottomNavigatorExampleState extends State<BottomNavigatorExample> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color.fromARGB(255, 43, 159, 186),
      ),
      child: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.play_arrow_outlined,
              color: Colors.white,
            ),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.camera,
              color: Colors.white,
            ),
            label: 'camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_file),
            label: 'Category',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: 'Person',
          // ),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExploreVideos()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserVideos()),
            );
          }
        },
      ),
    );
  }
}
