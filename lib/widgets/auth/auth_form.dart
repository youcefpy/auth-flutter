import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading);

  final void Function(String email, String username, String role,String workOn,
      String password, bool isLogin) submitFn;
  final bool isLoading;
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  String _userEamil = "";
  String _userName = "";
  String _userRole = "";
  String _userPassword = "";
  String _userWorkOn = "";
  String _confirmPassword ="";
    String? _passwordToVerify;

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(
        _userEamil.trim(),
        _userName.trim(),
        _userRole.trim(),
        _userWorkOn,
        _userPassword.trim(),
        _isLogin,
      );
    }
  }
    
Row _buildRadioButton(String value, String title) {
  return Row(
    children: [
      Radio(
        value: value,
        groupValue: _userWorkOn,
        onChanged: (String? value) {
          setState(() {
            _userWorkOn = value!;
          });
        },
      ),
      Text(title),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: ValueKey("email"),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains("@")) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email address",
                    ),
                    onSaved: (value) {
                      _userEamil = value!;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('username'),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: "username",
                      ),
                      onSaved: (value) {
                        _userName = value!;
                      },
                    ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('role'),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: "role",
                      ),
                      onSaved: (value) {
                        _userRole = value!;
                      },
                    ),
                    if (!_isLogin)
                      Column(
                        children: [
                          _buildRadioButton('bureau', 'Bureau'),
                          _buildRadioButton('depot', 'Depot'),
                          _buildRadioButton('atelier', 'Atelier'),
                        ],
                      ),
                  TextFormField(
                    key: ValueKey("password"),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        return "Password must be at least 7 caracters longs.";
                      }
                      _passwordToVerify = value;
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "password",
                    ),
                    onSaved: (value) {
                      _userPassword = value!;
                    },
                  ),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey("confirme passowrd"),
                      validator: (value) {
                        if(value != _passwordToVerify){
                          return "veillez verifier votre mot de passe";
                        }
                        return null;

                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "confirm password",
                      ),
                      onSaved: (value){
                       _confirmPassword = value! ; 
                      },
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  if (widget.isLoading) CircularProgressIndicator(),
                  if (!widget.isLoading)
                    ElevatedButton(
                      onPressed: _trySubmit,
                      child: Text(_isLogin ? 'Login' : "Signup"),
                    ),
                  if (!widget.isLoading)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin
                          ? 'Creat a new account'
                          : 'I already have an account'),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
