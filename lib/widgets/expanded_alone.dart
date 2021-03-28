import 'package:flutter/material.dart';

class ExpandedAlone extends StatelessWidget {
  const ExpandedAlone({this.flex});

  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex != null ? flex : 1,
      child: SizedBox(),
    );
  }
}
