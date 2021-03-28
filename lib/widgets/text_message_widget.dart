import 'package:enkel_chat/constants.dart';
import 'package:flutter/material.dart';

class TextMessageWidget extends StatelessWidget {
  const TextMessageWidget({
    @required this.isSender,
    @required this.dateTime,
    @required this.messageText,
  });

  final bool isSender;
  final String dateTime;
  final String messageText;

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
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            color: isSender ? Colors.blue : Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: InkWell(
              onTap: () {},
              onLongPress: () {
                // TODO: implement likes/reactions
              },
              child: Padding(
                padding: const EdgeInsets.all(7.5),
                child: Text(
                  messageText,
                  style: isSender ? kSenderStyle : kRecipientStyle,
                  softWrap: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
