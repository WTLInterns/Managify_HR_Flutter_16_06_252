import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrm_dump_flutter/theme/colors.dart';

class UiHelper {
  /// Custom Button
  static Widget customButton({
    required VoidCallback callback,
    String? buttonName,
    double? fontSize,
    ButtonStyle? style,
    Color? backgroundColor,
    Color? textColor,
    // Color? borderColor,
    FontWeight? fontWeight,
    Icon? icon,
    double radius = 6.0,
    double? height,
    double? width,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: callback,
        style: style ??
            ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColor.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
                // side: BorderSide(
                //   color: borderColor ?? AppColor.primary,
                // ),
              ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(
                width: 5,
              ),
            ],
            Text(
              buttonName ?? '',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight ?? FontWeight.normal,
                color: textColor ?? AppColor.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Custom Text
  static Widget customText({
    required String text,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    TextStyle? style,
    TextDecoration? decoration,
    Color? decorationColor,
    double? decorationThickness,
    int? maxLines,
  }) {
    return Text(
      text,
      style: style ?? TextStyle(
        fontSize: fontSize,
        color: color ?? AppColor.textColor, // Default to AppColor.textColor if no color provided
        fontWeight: fontWeight ?? FontWeight.normal,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationThickness: decorationThickness,
      ),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
    );
  }


  /// Custom Header
  static Widget customHeader({
    String? text,
    Color backgroundColor = AppColor.secondary,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? width,
    TextStyle? textStyle,
    Widget? leading,
    Widget? trailing,
  }) {
    return Container(
      height: height,
      width: width,
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leading ?? const SizedBox.shrink(),
          Expanded(
            child: Text(
              text ?? '',
              textAlign: TextAlign.start,
              style: textStyle ??
                  TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  ),
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }

  static Widget customTextField({
    TextEditingController? controller,
    String? hintText,
    bool? filled,
    Color? fillColor,
    Color? textColor,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    InputBorder? border,
    BorderSide? borderSide,
    Color? borderColor,
    int? maxLines,
    int? minLines,
    String? labelText,
    double? width,
    double? height,
    String? Function(String?)? validator,
    Color? hintTextColor,
    double? fontSize,
    Function(dynamic value)? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines ?? 1,
        minLines: minLines,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(color: hintTextColor, fontSize: fontSize),
          filled: filled,
          fillColor: fillColor,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: border ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: borderSide ??
                    BorderSide(
                      color: borderColor ?? AppColor.darker,
                    ),
              ),
        ),
        validator: validator,
      ),
    );
  }

  static Route customAnimation({
    required RoutePageBuilder pageBuilder,
    bool isRightToLeft = true,
  }) {
    return PageRouteBuilder(
      pageBuilder: pageBuilder,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = isRightToLeft ? Offset(1.0, 0.0) : Offset(-1.0, 0.0);
        final end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
