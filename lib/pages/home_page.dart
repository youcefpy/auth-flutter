import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:point_sys_aseel/auth.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().getcurrentuser;

  Future<void> signOut() async {
    await Auth().singOut();
  }

  Widget _title() {
    return const Text("Aseel point system Authentification ");
  }

  Widget _userId() {
    return Text(user?.uid ?? "User email");
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text("Sign OUt"),
    );
  }

  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _userId(),
            _signOutButton(),
          ],
        ),
      ),
    ));
  }
}
