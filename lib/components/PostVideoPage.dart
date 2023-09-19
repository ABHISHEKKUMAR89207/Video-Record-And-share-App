import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signupwithotp/components/RecordVideo.dart';

class PostVideoPage extends StatefulWidget {
  final String videoUrl;
  final String address;

  PostVideoPage({required this.videoUrl, required this.address});

  @override
  _PostVideoPageState createState() => _PostVideoPageState();
}

class _PostVideoPageState extends State<PostVideoPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final locationController = TextEditingController();
  File? _imageFile;
  final picker = ImagePicker();
  final storage = FirebaseStorage.instance;
  final user = FirebaseAuth.instance.currentUser;
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _saveVideoDataToFirestore() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image.'),
        ),
      );
      return;
    }
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final videoFile = File('${widget.videoUrl}');

    final storage = FirebaseStorage.instance;

    final videoStorageRef = storage.ref().child('user_videos/${user.uid}/');

    final videoFileName = widget.videoUrl.split('/').last;
    String downloadURL = '';
    if (_imageFile != null) {
      try {
        final videoStorageRef =
            storage.ref().child('user_videos/${user!.uid}/');

        final uploadTask =
            videoStorageRef.child('$videoFileName.jpg').putFile(_imageFile!);

        await uploadTask;
        downloadURL =
            await videoStorageRef.child('$videoFileName.jpg').getDownloadURL();

        print('Image uploaded. URL: $downloadURL');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    final videoRef = videoStorageRef.child(videoFileName);

    try {
      await videoRef.putFile(videoFile);

      final videoUrl = await videoRef.getDownloadURL();

      CollectionReference userDataCollection =
          FirebaseFirestore.instance.collection('userdatacollection');
      DocumentReference userDocRef = userDataCollection.doc(user.uid);
      CollectionReference videosCollection = userDocRef.collection('videos');
      CollectionReference videosCategoryCollection =
          FirebaseFirestore.instance.collection('Videos');

      if (!(await userDocRef.get()).exists) {
        await userDocRef.set(<String, dynamic>{});
      }

      Map<String, dynamic> videoData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'videoUrl': videoUrl,
        'location': '${widget.address}',
        'thumbnail': downloadURL,
      };

      //upload on video collection
      String? name = '', profileImg = '', username = '';
      try {
        DocumentSnapshot userDocument = await userDocRef.get();
        if (userDocument.exists) {
          name = (userDocument.data() as Map<String, dynamic>?)?['name'];

          profileImg =
              (userDocument.data() as Map<String, dynamic>?)?['profileimg'];

          username =
              (userDocument.data() as Map<String, dynamic>?)?['username'];
        } else {
          print('Document does not exist');
        }
      } catch (e) {
        print('Error accessing document: $e');
      }
      Map<String, dynamic> videoData2 = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'videoUrl': videoUrl,
        'location': '${widget.address}',
        'user': '${user.uid}',
        'name': name,
        'profileimg': profileImg,
        'username': username,
        'thumbnail': downloadURL,
      };
      // Add video subcollection
      try {
        await videosCollection.add(videoData);
        await videosCategoryCollection.add(videoData2);

        debugPrint('Video data saved successfully');
      } catch (error) {
        debugPrint('Error saving video data: $error');
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraPage()),
      );
    } catch (error) {
      print('Error uploading video: $error');
    }
  }

  String? _errorText;
  String? _selectedCategory;
  List<String> categories = [
    'Entertainment',
    'Musics',
    'Sports',
    'People & Blog',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 43, 159, 186),
        title: Text(
          'Post Video',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: _imageFile != null
                        ? Container(height: 100, child: Image.file(_imageFile!))
                        : Text('No image selected.'),
                  ),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Pick an Image'),
                  ),
                ],
              ),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: '${widget.address}',
                  border: OutlineInputBorder(),
                  disabledBorder: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Video Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Video Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                hint: Text('Select a category'),
                decoration: InputDecoration(
                  labelText: 'Video Category',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isEmpty ||
                      _descriptionController.text.isEmpty ||
                      _selectedCategory == null) {
                    setState(() {
                      _errorText = 'Please enter all values.';
                    });
                    _showErrorSnackbar();
                  } else {
                    _saveVideoDataToFirestore();
                  }
                },
                child: Text('Post Video'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 43, 159, 186),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar() {
    if (_errorText != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorText!),
        ),
      );
    }
  }
}
