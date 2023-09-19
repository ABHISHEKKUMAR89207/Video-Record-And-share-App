import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:signupwithotp/main.dart';

import 'package:signupwithotp/videos/ExploreVideos.dart';

class OtpEntryPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  OtpEntryPage(this.verificationId, this.phoneNumber);

  @override
  _OtpEntryPageState createState() => _OtpEntryPageState();
}

class _OtpEntryPageState extends State<OtpEntryPage> {
  final TextEditingController _smsCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //maximum of 6 digits
    _smsCodeController.addListener(() {
      if (_smsCodeController.text.length > 6) {
        _smsCodeController.text = _smsCodeController.text.substring(0, 6);
        _smsCodeController.selection = TextSelection.fromPosition(
          TextPosition(offset: _smsCodeController.text.length),
        );
      }
    });
  }

  Future<void> _verifySmsCode() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _smsCodeController.text,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ),
        );
      } else {}
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP'),
        backgroundColor: Color.fromARGB(255, 4, 94, 97),
      ),
      backgroundColor: Color.fromARGB(255, 244, 233, 233),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Enter OTP for ${widget.phoneNumber}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Lottie.asset(
                'assets/animation_lmkx1gsg.json',
                width: 300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _smsCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'SMS Code',
                  filled: true,
                  fillColor: Color.fromARGB(255, 204, 231, 232),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
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
              onPressed: _verifySmsCode,
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
              child: Text('Get Started'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 82, 210, 214),
                onPrimary: Colors.white,
                textStyle: TextStyle(fontSize: 10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text('Did not get otp, Resend'),
            ),
          ],
        ),
      ),
    );
  }
}
