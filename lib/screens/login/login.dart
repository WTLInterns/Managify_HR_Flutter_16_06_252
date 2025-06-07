import 'dart:convert';
import 'package:hrm_dump_flutter/screens/dashbord/dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hrm_dump_flutter/res/app_colour.dart';
import 'package:hrm_dump_flutter/res/app_styles.dart';
import 'package:hrm_dump_flutter/screens/login/forget_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureText = false;
  bool _loading    = false;

  void _toggleObscure() => setState(() => _obscureText = !_obscureText);

  Future<void> _attemptLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final email    = emailController.text.trim();
    final password = passwordController.text;

    final String apiUrl = 'https://api.managifyhr.com/api/employee/login-employee';
    try {
      print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');

      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'email': email,
          'password': password,
        },
      );
      print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');


      if (response.statusCode == 200) {
        print(response.statusCode);
        // Parse the response
        print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');
        final responseData = json.decode(response.body);

        // Save data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullName', responseData['fullName'] ?? '');
        await prefs.setString('empimg', responseData['empimg'] ?? '');
        await prefs.setString('role', responseData['role'] ?? '');
        await prefs.setString('jobRole', responseData['jobRole'] ?? '');
        await prefs.setInt('subadminId', responseData['subadmin']['id'] ?? 0);
        await prefs.setString('registercompanyname', responseData['subadmin']['registercompanyname'] ?? '');
        await prefs.setString('companylogo', responseData['subadmin']['companylogo'] ?? '');
        await prefs.setString('email', email);
        await prefs.setInt('empId', responseData['empId'] ?? 0);
        await prefs.setInt('phone', responseData['phone'] ?? 0);
        await prefs.setString('firstName', responseData['firstName'] ?? '');
        await prefs.setString('lastName', responseData['lastName'] ?? '');
        await prefs.setString('gender', responseData['gender'] ?? '');
        await prefs.setString('address', responseData['address'] ?? '');
        await prefs.setString('birthDate', responseData['birthDate'] ?? '');
        await prefs.setString('panCard', responseData['panCard'] ?? '');
        await prefs.setString('bloodGroup', responseData['bloodGroup'] ?? '');
        await prefs.setString('aadharNo', responseData['aadharNo'] ?? '');

        print('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv');

        // brief pause so user sees it
        await Future.delayed(const Duration(milliseconds: 100));
        // then navigate, passing email to DashboardScreen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => DashboardScreen(),
            transitionsBuilder: (_, animation, __, child) {
              final slideTween = Tween<Offset>(
                begin: const Offset(1.0, 0.0), //Slide from Right
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut));

              return SlideTransition(
                position: animation.drive(slideTween),
                child: child,
              );
            },
          ),
        );
      } else {
      print(response.statusCode);
        // show backend error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please check your credentials.')),
        );
      }
    } catch (e) {
      print(e.toString());
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

              /// Icon
              Center(
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: AppColours.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.balcony_outlined,
                      size: 25,
                      color: AppColours.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              /// Title
              Center(
                child: Text("HRM SYSTEM", style: AppTextStyles.appbar),
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

              /// Login Form
              Form(
                key: _formKey,
                child: Card(
                  color: AppColours.fill3,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text("Welcome Back", style: AppTextStyles.appbar),
                        ),
                        const SizedBox(height: 10),

                        // Email
                        Text("Email or Mobile", style: AppTextStyles.buttonStyle),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: emailController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: RequiredValidator(errorText: 'Email is required*'),
                          style: AppTextStyles.appbar,
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                            hintStyle: AppTextStyles.hintText,
                            prefixIcon: const Icon(Icons.email),
                            prefixIconColor: AppColours.blue,
                            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color.fromARGB(115, 108, 105, 105)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color.fromARGB(115, 108, 105, 105), width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Password
                        Text("Password", style: AppTextStyles.buttonStyle),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          obscureText: !_obscureText,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: RequiredValidator(errorText: 'Password is required*'),
                          style: AppTextStyles.appbar,
                          decoration: InputDecoration(
                            hintText: "Enter your password",
                            hintStyle: AppTextStyles.hintText,
                            prefixIcon: const Icon(Icons.lock),
                            prefixIconColor: AppColours.blue,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                                color: AppColours.onPrimary,
                              ),
                              onPressed: _toggleObscure,
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color.fromARGB(115, 108, 105, 105)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color.fromARGB(115, 108, 105, 105), width: 2.0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Sign In Button
                        MaterialButton(
                          height: 55,
                          minWidth: double.infinity,
                          color: AppColours.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5.0,
                          onPressed: _loading ? null : _attemptLogin,
                          child: _loading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                              : const Text(
                            "Sign In",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.buttonStyle,
                          ),
                        ),

                        // Forgot / Clear
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ForgotPassword()),
                                );
                              },
                              child: Text("Forgot Password?", style: AppTextStyles.textButton),
                            ),
                            TextButton(
                              onPressed: () {
                                emailController.clear();
                                passwordController.clear();
                              },
                              child: Text("Clear", style: AppTextStyles.textButton2),
                            ),
                          ],
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

