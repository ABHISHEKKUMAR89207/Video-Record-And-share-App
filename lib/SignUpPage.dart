import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:signupwithotp/OtpVerification.dart';
import 'package:signupwithotp/SignUpPage.dart';

import 'package:signupwithotp/videos/ExploreVideos.dart';

class PhoneOtpSignupPage extends StatefulWidget {
  @override
  _PhoneOtpSignupPageState createState() => _PhoneOtpSignupPageState();
}

class _PhoneOtpSignupPageState extends State<PhoneOtpSignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isLoading = false;
  Future<void> _verifyPhone(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final phoneNumber =
        _phoneNumberController.text.replaceAll(RegExp(r'\D'), '');

    // Check  phone number exactly 10 digits
    if (phoneNumber.length == 10) {
      final completePhoneNumber = '+91$phoneNumber';
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: completePhoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // This callback is called if the phone number is automatically verified.
            // You can sign in the user here if needed.
            try {
              final UserCredential authResult =
                  await _auth.signInWithCredential(credential);
              final User? user = authResult.user;

              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExploreVideos(),
                  ),
                );
              } else {}
            } catch (e) {
              print(e);
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            // Handle verification failed
            print(e.message);
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OtpEntryPage(verificationId, _phoneNumberController.text),
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
          timeout: Duration(seconds: 60), // Timeout duration
        );
      } catch (e) {
        print(e);
      }
    } else {
      print('Invalid Phone Number');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Phone Number'),
        backgroundColor: Color.fromARGB(255, 4, 94, 97),
      ),
      backgroundColor: Color.fromARGB(255, 244, 233, 233),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Lottie.asset(
                'assets/animation_lmkx1gsg.json',
                width: 300,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  filled: true,
                  fillColor: Color.fromARGB(255, 204, 231, 232),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixText: '+91 ',
                  labelStyle: TextStyle(
                    color: Color.fromARGB(255, 4, 94, 97),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
                cursorColor: Color.fromARGB(255, 91, 201, 205),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      _verifyPhone(context);
                    },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 4, 94, 97),
                onPrimary: Colors.white,
                textStyle: TextStyle(fontSize: 18),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
              child: Text('Next'),
            ),
            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
