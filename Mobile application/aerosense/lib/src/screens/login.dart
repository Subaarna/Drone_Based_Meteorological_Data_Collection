import 'package:aerosense/src/screens/forgot_password.dart';
import 'package:aerosense/src/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Logger logger = Logger();
  var box = Hive.box('userData');
  bool _isPasswordVisible = false;

  Future<void> loginUser(BuildContext context) async {
    final url = Uri.parse(
        'https://meteorological-data-collection-using-wh35.onrender.com/login');

    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in all fields'),
          duration: Duration(seconds: 1),
        ));
        return; // Exit the function if fields are empty
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      var jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        // Extract access token from the response
        String accessToken = jsonResponse["accessToken"];

        // Store the access token in Hive for later use
        box.put('accessToken', accessToken);

        // Displaying a success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(jsonResponse["message"]),
          ));
        }

        // Navigate to the appropriate screen based on your logic
        Get.offAll(() => Home(accessToken: accessToken),
            transition: Transition.fadeIn);
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
            content: Text('Error: $error'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
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
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => const Login()),
                                // );
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
                                    color: Color(0xFF09FBD3),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            TextButton(
                              onPressed: () {
                                Get.to(() => const Register(),
                                    transition: Transition.fadeIn);
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
                                    color: Color(0xFFA7A3A3),
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
                                    color: Color(0xFF09FBD3),
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
                                  color: Color(0xFF848080),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Form(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: constraints.maxHeight * 0.05),
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
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Get.to(() => const ForgotPassword(),
                                          transition: Transition.fadeIn);
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.raleway(
                                        textStyle: const TextStyle(
                                          color: Color(0xFF09FBD3),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: constraints.maxHeight * 0.06),
                              Center(
                                child: SizedBox(
                                  width: constraints.maxWidth * 0.55,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      loginUser(context);
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
                                          'Login',
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
                              SizedBox(height: constraints.maxHeight * 0.05),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Get.to(() => const Register(),
                                        transition: Transition.fadeIn);
                                    //   MaterialPageRoute(
                                    //    //   builder: (context) => const Login()),
                                    //  );
                                  },
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Don\'t have an account? ',
                                      style: GoogleFonts.raleway(
                                        textStyle: const TextStyle(
                                          color: Color(0xFFA7A3A3),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Register',
                                          style: GoogleFonts.raleway(
                                            textStyle: const TextStyle(
                                              color: Color(0xFF09FBD3),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
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

void main() {
  runApp(const GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: Login(),
  ));
}
