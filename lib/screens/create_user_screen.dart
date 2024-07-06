import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:provider/provider.dart';
import '../auth_proivder.dart';
import '../validation_messages.dart';
import '../validator.dart';
import '../widgets/widgets.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isSubmitting = false;
  bool isAdmin = false;
  bool _passwordVisible = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FlutterPwValidatorState> validatorKey =
      GlobalKey<FlutterPwValidatorState>();

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    doRegister() {
      final form = _formKey.currentState;

      if (form!.validate()) {
        form.save();

        setState(() {
          _isSubmitting = true;
        });

        try {
          auth.register(
            _emailController.text,
            _passwordController.text,
            _firstNameController.text,
            _lastNameController.text,
            isAdmin,
          ).then((response) {
            if (!mounted) return;
            setState(() {
              _isSubmitting = false;
            });

            if (response['isSuccess']) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Success"),
                    content: const Text("User created successfully!"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Confirm"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
              form.reset();
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Error"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: response['errors'].map<Widget>((error) {
                        return Text(error);
                      }).toList(),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          });
        } catch (e) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }

    return GestureDetector(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          title: const Text("Create user"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 250.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                        'Create a user',
                        style: TextStyle(
                          fontSize: 24.0, // Adjust the size as needed
                          fontWeight: FontWeight.w500 , // Optional: to make the text bold
                        ),
                      ),
                    const SizedBox(height: 30),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      controller: _firstNameController,
                      validator: (value) => validateName(value, 'First name'),
                      decoration: buildInputDecoration("First name", Icons.person),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      controller: _lastNameController,
                      validator: (value) => validateName(value, 'Last name'),
                      decoration: buildInputDecoration("Last name", Icons.person),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      validator: validateEmail,
                      decoration: buildInputDecoration("Email", Icons.email_rounded),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text('Make an admin'),
                      subtitle: const Text("This will add admin permissions (admin role)."),
                      value: isAdmin, // set initial value here
                      onChanged: (newValue) {
                        setState(() {
                          isAdmin = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       TextFormField(
      obscureText: !_passwordVisible,
      controller: _passwordController,
      validator: (value) =>
          value!.isEmpty ? ValidationMessages.passwordRequired : null,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
    ),
                        const SizedBox(height: 15),
                        FlutterPwValidator(
                          key: validatorKey,
                          controller: _passwordController,
                          minLength: 8,
                          uppercaseCharCount: 2,
                          numericCharCount: 3,
                          specialCharCount: 1,
                          normalCharCount: 3,
                          width: 400,
                          height: 200,
                          onSuccess: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Password valid."),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : doRegister, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSubmitting)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          const Text(
                            'Create User',
                            style: TextStyle(
                                fontSize: 18.0, 
                                fontWeight: FontWeight.bold, 
                              ),
                          ),

                        ],
                      ),
                    ),
                          const SizedBox(height: 50,)

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
