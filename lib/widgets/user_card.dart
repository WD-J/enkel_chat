import 'package:flutter/material.dart';

import '../constants.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    this.index,
    this.usersLength,
    this.onCardTap,
    this.image,
    this.title,
    this.description,
    this.dateTime,
  });

  final int index;
  final int usersLength;
  final Function onCardTap;

  final String image;
  final String title;
  final String description;
  final String dateTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 15.0,
        right: 15.0,
        top: 15.0,
        bottom: index + 1 == usersLength ? 15.0 : 0.0,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: InkWell(
          onTap: onCardTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Hero(
                  tag: 'pfpHero: $index',
                  child: CircleAvatar(
                    radius: 25.0,
                    backgroundImage: image == null
                        ? null
                        : NetworkImage(
                            image,
                          ),
                    child: image != null
                        ? null
                        : Text(
                            title.toString().split(' ').first[0] +
                                title.toString().split(' ').last[0],
                          ),
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            style: kTitleStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            dateTime,
                            style: kDescriptionStyle,
                            softWrap: true,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        description,
                        maxLines: 2,
                        style: kDescriptionStyle,
                        overflow: TextOverflow.ellipsis,
                        // softWrap: true,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
