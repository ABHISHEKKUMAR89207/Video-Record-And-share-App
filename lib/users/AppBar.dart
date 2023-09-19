// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signupwithotp/users/UserVideos.dart';
import 'package:signupwithotp/videos/ExploreVideos.dart';
import 'package:signupwithotp/videos/SearchVideo.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? userId = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
          .collection('userdatacollection')
          .doc(userId)
          .get();

      if (userDataSnapshot.exists) {
        final Map<String, dynamic> userData =
            userDataSnapshot.data() as Map<String, dynamic>;
        return userData;
      } else {
        return {};
      }
    } catch (error) {
      print('Error fetching user data: $error');
      return {};
    }
  }

  Future<void> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Map<String, dynamic> data = await getUserData(currentUser.uid);
      setState(() {
        userData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          GestureDetector(
            onTap: () {},
            child: UserAccountsDrawerHeader(
              accountName: Text(
                '${userData['name'] ?? 'Loading...'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                'User Email: ${userData['email'] ?? 'Loading...'}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    NetworkImage('${userData['profileimg'] ?? ''}'),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 43, 159, 186),
              ),
            ),
          ),
          _buildDrawerItem(Icons.search, 'Serach Video', SearchVideo()),
          _buildDrawerItem(Icons.home, 'Explore', ExploreVideos()),
          _buildDrawerItem(Icons.person_2_rounded, 'My Videos', UserVideos()),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
