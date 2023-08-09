import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/auth/auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(String email, String username, String role,String workOn,
      String password, bool isLogin) async {
    dynamic authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance
            .collection("users")
            .doc(authResult.user.uid)
            .set({
          "email": email,
          "username": username,
          "role": role,
          "workOn": workOn,
          "userId": authResult.user.uid,
        });
      }
    } on PlatformException catch (err) {
      String? message = "An error occurred, pelase check your credentials !";
      if (err.message != null) {
        message = err.message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message!),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(child: Column(children: [
      SizedBox(height: 50), 
      Image.asset("assets/images/logo_assel.jpg", height: 150,),
      Text("E-Pointing Assil", style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),), 
      AuthForm(_submitAuthForm, _isLoading),
        
      ],),), 
    );
  }
}
