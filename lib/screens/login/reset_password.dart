import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hrm_dump_flutter/res/app_styles.dart';
import 'package:hrm_dump_flutter/screens/login/login.dart';
import 'package:hrm_dump_flutter/theme/colors.dart';
import 'package:http/http.dart' as http;

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _obscureText = false;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  void _toggle() => setState(() => _obscureText = !_obscureText);

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final uri = Uri.parse(
      'https://api.managifyhr.com/api/employee/forgot-password/verify',
    );
    final body = jsonEncode({
      'email': emailController.text,
      'otp': otpController.text,
      'newPassword': passwordController.text,
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // always show the backend's message in a SnackBar
      final snack = SnackBar(content: Text(response.body));

      if (response.statusCode == 200) {
        // success only shows the message
        ScaffoldMessenger.of(context).showSnackBar(snack);
      } else {
        // error shows the message too
        ScaffoldMessenger.of(context).showSnackBar(snack);
      }
    } catch (_) {
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
      backgroundColor: AppColor.blue2,
      appBar: AppBar(
        backgroundColor: AppColor.blue2,
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
                  height: 35,
                  decoration: BoxDecoration(
                    color: AppColor.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.lock,
                      size: 25,
                      color: AppColor.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              /// Title
              Center(
                child: Text("Reset Password", style: AppTextStyles.appbar),
              ),

              /// Divider
              Center(
                child: SizedBox(
                  width: 70,
                  child: Divider(color: AppColor.blue, thickness: 5.0),
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
                  color: AppColor.fill3,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_back),
                              color: AppColor.blue,
                            ),
                            const SizedBox(width: 5),
                            Text("Back", style: AppTextStyles.textButton),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // OTP Field
                        Text("OTP code", style: AppTextStyles.buttonStyle),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: otpController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: RequiredValidator(
                            errorText: 'OTP is required*',
                          ),
                          style: AppTextStyles.appbar,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.key),
                            prefixIconColor: AppColor.blue,
                            hintText: "Enter otp code sent to your email",
                            hintStyle: AppTextStyles.hintText,
                            contentPadding: const EdgeInsets.fromLTRB(
                              20,
                              15,
                              20,
                              15,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(115, 108, 105, 105),
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(115, 108, 105, 105),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // New Password Field
                        Text("New Password", style: AppTextStyles.buttonStyle),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          obscureText: !_obscureText,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: RequiredValidator(
                            errorText: 'Password is required*',
                          ),
                          style: AppTextStyles.appbar,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            prefixIconColor: AppColor.blue,
                            hintText: "Enter new password",
                            hintStyle: AppTextStyles.hintText,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColor.white,
                              ),
                              onPressed: _toggle,
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              20,
                              15,
                              20,
                              15,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(115, 108, 105, 105),
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(115, 108, 105, 105),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Confirm Password Field
                        Text(
                          "Confirm Password",
                          style: AppTextStyles.buttonStyle,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: !_obscureText,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Confirm password is required*';
                            }
                            if (val != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          style: AppTextStyles.appbar,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            prefixIconColor: AppColor.blue,
                            hintText: "Enter confirm password",
                            hintStyle: AppTextStyles.hintText,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColor.white,
                              ),
                              onPressed: _toggle,
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              20,
                              15,
                              20,
                              15,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(115, 108, 105, 105),
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromARGB(115, 108, 105, 105),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),

                        /// Update Password Button
                        MaterialButton(
                          height: 55,
                          minWidth: double.infinity,
                          color: AppColor.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5.0,
                          onPressed: _loading ? null : _updatePassword,
                          child:
                              _loading
                                  ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    "Update Password",
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
