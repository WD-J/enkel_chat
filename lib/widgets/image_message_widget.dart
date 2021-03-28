import 'package:flutter/material.dart';

class ImageMessageWidget extends StatelessWidget {
  const ImageMessageWidget({
    @required this.isSender,
    @required this.dateTime,
    @required this.image,
  });

  final bool isSender;
  final String dateTime;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: SizedBox(),
        ),
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(7.5),
            child: InkWell(
              onTap: () {},
              onLongPress: () {
                // TODO: implement likes/reactions
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(image),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
