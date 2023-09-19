import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signupwithotp/videos/ExploreVideos.dart';

class FormUser extends StatefulWidget {
  @override
  _FormUserState createState() => _FormUserState();
}

class _FormUserState extends State<FormUser> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 43, 159, 186),
        title: Text(
          'Create User',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _imageFile != null
                      ? Container(height: 50, child: Image.file(_imageFile!))
                      : Text('No image'),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                    ),
                    child: Text('Pick an Image'),
                  ),
                ],
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email is required';
                  } else if (!RegExp(
                          r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                      .hasMatch(value)) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 15, 122, 120),
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  elevation: 5,
                ),
                onPressed: () async {
                  if (_imageFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select an image.'),
                      ),
                    );
                    return;
                  }
                  String downloadURL = '';

                  if (_imageFile != null) {
                    try {
                      final videoStorageRef =
                          storage.ref().child('user_videos/${user!.uid}/');

                      final uploadTask = videoStorageRef
                          .child('profile.jpg')
                          .putFile(_imageFile!);

                      await uploadTask;
                      downloadURL = await videoStorageRef
                          .child('profile.jpg')
                          .getDownloadURL();

                      print('Image uploaded. URL: $downloadURL');
                    } catch (e) {
                      print('Error uploading image: $e');
                    }
                  }

                  if (_formKey.currentState!.validate()) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final userId = user.uid;
                      final formData = {
                        'profileimg': downloadURL,
                        'username': _usernameController.text,
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'userId': userId,
                        'formdone': 0,
                      };

                      final usernameExists = await checkUsernameAvailability(
                          _usernameController.text);

                      if (usernameExists) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Username is not available.'),
                          ),
                        );
                      } else {
                        try {
                          await FirebaseFirestore.instance
                              .collection('userdatacollection')
                              .doc(userId)
                              .set(formData);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Data saved to Firestore.'),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ExploreVideos()),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Error saving data to Firestore: $e'),
                            ),
                          );
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User is not authenticated.'),
                        ),
                      );
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

Future<bool> checkUsernameAvailability(String username) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('userdatacollection')
      .where('username', isEqualTo: username)
      .get();
  return querySnapshot.docs.isNotEmpty;
}
