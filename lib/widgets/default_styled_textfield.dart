import 'package:flutter/material.dart';

class DefaultStyledTextField extends StatelessWidget {
  const DefaultStyledTextField({
    @required this.controller,
    @required this.hintText,
    this.obscureText,
    this.maxLength,
    this.maxLines,
    this.textInputAction,
    this.focusNode,
    this.decoration,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final int maxLength;
  final int maxLines;
  final TextInputAction textInputAction;
  final FocusNode focusNode;
  final InputDecoration decoration;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: Colors.black87,
      obscureText: obscureText != null ? obscureText : false,
      maxLength: maxLength != null ? maxLength : null,
      maxLines: maxLines,
      minLines: 1,
      onChanged: onChanged,
      textInputAction:
          textInputAction != null ? textInputAction : TextInputAction.done,
      focusNode: focusNode != null ? focusNode : null,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: EdgeInsets.all(15.0),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black54,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
