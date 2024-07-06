import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_proivder.dart';
import '../main_page.dart';
import '../user.dart';
import '../user_provider.dart';
import '../validator.dart';
import '../widgets/widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? _email = "";
  String? _password = "";
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    AuthProvider auth = Provider.of<AuthProvider>(context);

    doLogin() {
      final form = _formKey.currentState;
      if (form!.validate()) {
        print("proslo form validate");
        form.save();

          setState(() {
          _isSubmitting = true;
        });
        

        final Future<Map<String, dynamic>> response =
            auth.login(_email, _password);

        response.then((response) {
           try {
          if (response['status']) {
            User user = response['user'];

           if(!user.roles.contains("Admin")) {
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Not authorized"),
                duration: Duration(seconds: 5),
              ),
            );

              setState(() {
                _isSubmitting = false;
        });
        return;
           }
            Provider.of<UserProvider>(context, listen: false).setUser(user);
               setState(() {
          _isSubmitting = false;

        });
          Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
        );

          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message']),
                duration: Duration(seconds: 5),
              ),
            );

                setState(() {
                _isSubmitting = false;
        });
          }
           } catch (e) {
    // Handle any potential errors here
    print('Error occurred: $e');
    setState(() {
      _isSubmitting = false;
    });
  }
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: !isKeyboardOpen,
                  child: Icon(
                    Icons.person_pin_circle_sharp,
                    size: 100,
                  ),
                ),
                SizedBox(
                  height: 75,
                ),
                Text(
                  'Hello Again!',
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Login to continue.',
                ),
                SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextFormField(
                    autofocus: false,
                    validator: validateEmail,
                    onSaved: (value) => _email = value,
                    decoration:
                        buildInputDecoration("Email", Icons.email_rounded),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextFormField(
                    obscureText: !_isPasswordVisible,
                    autofocus: false,
                    // validator: (value) => value!.isEmpty
                    //     ? ValidationMessages.passwordRequired
                    //     : null,
                    onSaved: (value) => _password = value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      icon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:  () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ElevatedButton(
                    onPressed: _isSubmitting? null: doLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Log In',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
