import 'package:flutter/material.dart';

class FormController  {
  String selectedGender = '';
  bool isObscure = true;

  void toggleVisibility() {
    isObscure = !isObscure;
  }




  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
}