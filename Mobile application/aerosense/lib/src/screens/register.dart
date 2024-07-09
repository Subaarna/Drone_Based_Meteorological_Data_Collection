import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Logger logger = Logger();
  var box = Hive.box('userData');
  bool _isPasswordVisible = false;

  Future<void> registerUser(BuildContext context) async {
    final url = Uri.parse(
        'https://drone-based-meteorological-data.onrender.com/signup');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${box.get("accessToken")}',
        },
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      var jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        // Displaying a success message and navigating to the login screen
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(jsonResponse["message"]),
          ));
        }
        // Transition to the login screen after a delay
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.to(() => const Login(), transition: Transition.fadeIn);
        });
      } else {
        // If the request failed, extract the error message from the response
        var errorMessage =
            jsonResponse["error"]; // Assuming error message key is "error"
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage ?? "An error occurred"),
            duration: const Duration(seconds: 2), // Display for 2 seconds
          ));
        }
      }
    } catch (error) {
      // Handle error
      logger.e('Error: $error');

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'), // Display the error message
            duration: const Duration(seconds: 2), // Display for 2 seconds
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/icons/design.png',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: constraints.maxHeight * 0.25,
                          left: constraints.maxWidth * 0.03,
                        ),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Get.to(() => const Login(),
                                    transition: Transition.fadeIn);
                              },
                              style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Login',
                                style: GoogleFonts.raleway(
                                  textStyle: const TextStyle(
                                    color: Color(0xFFA7A3A3),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            TextButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => const Register()),
                                // );
                              },
                              style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Register',
                                style: GoogleFonts.raleway(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF09FBD3),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: constraints.maxWidth * 0.05),
                            child: Container(
                              width: 54,
                              decoration: const ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                    color: Color(0xFF848080),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Container(
                            width: 80,
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1.5,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: Color(0xFF09FBD3),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Form(
                        key: formKey, // Assign formKey to the key property
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: constraints.maxHeight * 0.05,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.white,
                                  ),
                                  fillColor: const Color(0xFF272829),
                                  filled: true,
                                  labelText: 'Email',
                                  labelStyle: GoogleFonts.raleway(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.7,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your email';
                                  }
                                  if (!EmailValidator.validate(value!)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: constraints.maxHeight * 0.03),
                              TextFormField(
                                controller: passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible; // Toggle the state
                                      });
                                    },
                                  ),
                                  fillColor: const Color(0xFF272829),
                                  filled: true,
                                  labelText: 'Password',
                                  labelStyle: GoogleFonts.raleway(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter your password';
                                  }
                                  if (value!.length < 8) {
                                    return 'Password must be at least 8 characters long';
                                  }

                                  RegExp alphaNumeric =
                                      RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)');
                                  if (!alphaNumeric.hasMatch(value)) {
                                    return 'Password must contain both alphabetic and numeric characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: constraints.maxHeight * 0.06),
                              Center(
                                child: SizedBox(
                                  width: constraints.maxWidth * 0.55,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        registerUser(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4E4E4E),
                                            Color(0xFF2C2D2D)
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minHeight: 48,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'Register',
                                          style: TextStyle(
                                            color: Color(0xFF09FBD3),
                                            fontSize: 16,
                                            fontFamily: 'Raleway',
                                            fontWeight: FontWeight.w700,
                                            height: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
