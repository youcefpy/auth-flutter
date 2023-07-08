import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:point_sys_aseel/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    String? errorMsg = "";
    bool isLogin = true;
    final TextEditingController _controllerEmail = TextEditingController();
    final TextEditingController _controllerPassword = TextEditingController();

    //create a future function signin with email and password

    Future<void> signInWithEmailAndPassword() async {
      try {
        await Auth().singInWithEmailAndPassword(
            email: _controllerEmail.text, password: _controllerPassword.text);
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMsg = e.message;
        });
      }
    }

    Future<void> createUserWithEmailAndPassword() async {
      try {
        await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text,
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMsg = e.message;
        });
      }
    }

    Widget _title() {
      return const Text("Aseel Authentification");
    }

    Widget _entryField(String title, TextEditingController controller) {
      return TextField(
        controller: controller,
        decoration: InputDecoration(labelText: title),
      );
    }

    Widget _errorMessage() {
      return Text(
          errorMsg == '' ? '' : 'eror of connection, try again $errorMsg');
    }

    Widget _submitButton() {
      return ElevatedButton(
        onPressed: isLogin
            ? signInWithEmailAndPassword
            : createUserWithEmailAndPassword,
        child: Text(isLogin ? "Login" : "Regester"),
      );
    }

    Widget _loginOrRegestration() {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            isLogin = !isLogin;
          });
        },
        child: Text(isLogin ? "Regester" : "Login"),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _entryField("email", _controllerEmail),
            _entryField("password", _controllerPassword),
            _errorMessage(),
            _submitButton(),
            _loginOrRegestration(),
          ],
        ),
      ),
    );
  }
}
