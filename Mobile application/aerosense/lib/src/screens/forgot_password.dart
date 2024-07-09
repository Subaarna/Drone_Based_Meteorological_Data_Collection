import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import './login.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final Logger logger = Logger();
  Future<void> forgotPassword(BuildContext context) async {
    final url = Uri.parse(
        'https://drone-based-meteorological-data.onrender.com/forgotPassword');

    try {
      if (emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter your email'),
          duration: Duration(seconds: 1),
        ));
        return;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
        }),
      );

      var jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        // Display success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(jsonResponse["message"]),
          ));
        }
        // Navigate to login only if the email was successfully sent
        Get.to(() => const Login(), transition: Transition.fadeIn);
      } else {
        var errorMessage = jsonResponse["error"];

        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage ?? "An error occurred"),
            duration: const Duration(seconds: 2),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            Text(
              'Lost your password? Please enter your email address. You will receive a link to create a new password via email.',
              style: GoogleFonts.raleway(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 12,
                  fontWeight: FontWeight.normal, // Bold font weight
                ),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20), // Add some space
            // Button to submit email
            ElevatedButton(
              onPressed: () {
                // Here you can handle the email submission
                String email = emailController.text;
                forgotPassword(context);
                // Add your logic to handle the submitted email
                logger.d('Submitted email: $email');
                // Close the bottom sheet after submission
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
