import 'dart:io';

import 'package:flutter/material.dart';

class MessagingTextField extends StatelessWidget {
  const MessagingTextField({
    @required this.controller,
    this.onEditingComplete,
    this.onSubmittedButton,
    this.pickImage,
    this.image,
  });

  final TextEditingController controller;
  final Function onEditingComplete;
  final Function onSubmittedButton;
  final Function pickImage;
  final File image;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onEditingComplete: onEditingComplete,
      cursorColor: Colors.black87,
      maxLines: 5,
      minLines: 1,
      textInputAction: TextInputAction.send,
      decoration: InputDecoration(
        hintText: 'Send a message...',
        contentPadding: EdgeInsets.all(15.0),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 10.0,
            ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: pickImage,
              child: Icon(
                Icons.image,
                color: Colors.black54,
                size: 35.0,
              ),
            ),
            SizedBox(
              width: 5.0,
            ),
            image == null
                ? SizedBox()
                : SizedBox(
                    width: 29.0,
                    height: 29.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: Image.file(image),
                      ),
                    ),
                  ),
            SizedBox(
              width: 15.0,
            ),
          ],
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: InkWell(
            onTap: onSubmittedButton,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Icon(
              Icons.send,
              color: Colors.black54,
              size: 35.0,
            ),
          ),
        ),
      ),
    );
  }
}
