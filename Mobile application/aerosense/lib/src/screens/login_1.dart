import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Image.asset(
          'assets/icons/design.png',
          width: screenSize.width,
          //  height: screenSize.height,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenSize.height * 0.25,
                        left: screenSize.width * 0.05,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Login',
                            style: GoogleFonts.raleway(
                              textStyle: const TextStyle(
                                color: Color(0xFF09FBD3),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(
                              width:
                                  10), // Adding space between "Login" and "Register"
                          Text(
                            'Register',
                            style: GoogleFonts.raleway(
                              textStyle: const TextStyle(
                                color: Color(0xFFA7A3A3),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: screenSize.width * 0.05),
                      child: Container(
                        width: 54,
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1.5,
                              style:
                                  BorderStyle.solid, // Define the border style
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
                        vertical: screenSize.height * 0.07),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
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
                                fontSize: 16,
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
                        SizedBox(height: screenSize.height * 0.03),
                        TextFormField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            fillColor: const Color(0xFF272829),
                            filled: true,
                            labelText: 'Password',
                            labelStyle: GoogleFonts.raleway(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Forgot Password?',
                              style: GoogleFonts.raleway(
                                textStyle: const TextStyle(
                                  color: Color(0xFF09FBD3),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Login(),
  ));
}
