import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hrm_dump_flutter/res/app_colour.dart';
import 'package:hrm_dump_flutter/res/app_styles.dart';
import 'package:hrm_dump_flutter/screens/login/login.dart';
import 'package:hrm_dump_flutter/screens/login/reset_password.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final uri = Uri.parse('https://api.managifyhr.com/api/employee/forgot-password/request');
    final body = jsonEncode({'email': emailController.text});

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        // Show OTP-sent message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to email: ${emailController.text.trim()}'),
          ),
        );
        // Then navigate
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResetPassword()),
        );
      } else {
        final msg = response.body.isNotEmpty
            ? response.body
            : 'Failed to send OTP';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error, please try again.')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.blue2,
      appBar: AppBar(
        backgroundColor: AppColours.blue2,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              /// Icon Button
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColours.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  height: 35,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.key,
                        size: 25, color: AppColours.onPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              /// Title
              Center(
                child: Text("Forgot Password", style: AppTextStyles.appbar),
              ),

              /// Divider
              Center(
                child: SizedBox(
                  width: 70,
                  child: Divider(
                    color: AppColours.blue,
                    thickness: 5.0,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Form inside Card
              Form(
                key: _formKey,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 8,
                  color: AppColours.fill3,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                );
                              },
                              icon: const Icon(Icons.arrow_back),
                              color: AppColours.blue,
                            ),
                            const SizedBox(width: 5),
                            Text("Back to Login",
                                style: AppTextStyles.textButton),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Text("Email Address",
                            style: AppTextStyles.buttonStyle),
                        const SizedBox(height: 10),

                        /// Email Field
                        TextFormField(
                          controller: emailController,
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: 'Email is required*'),
                          ]).call,
                          style: AppTextStyles.appbar,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color:
                                      Color.fromARGB(115, 108, 105, 105)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color:
                                      Color.fromARGB(115, 108, 105, 105),
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            prefixIcon: const Icon(Icons.email),
                            prefixIconColor: AppColours.blue,
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            hintText: "Enter your email",
                            hintStyle: AppTextStyles.hintText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),

                        const SizedBox(height: 35.0),

                        /// Send OTP and Continue Button
                        MaterialButton(
                          height: 55,
                          minWidth: double.infinity,
                          color: AppColours.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5.0,
                          onPressed: _loading ? null : _sendOtp,
                          child: _loading
                              ? const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                )
                              : const Text(
                                  "Send OTP and Continue",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.buttonStyle,
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
    );
  }
}
