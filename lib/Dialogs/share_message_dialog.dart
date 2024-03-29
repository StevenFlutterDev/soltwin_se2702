import 'package:flutter/material.dart';

class ShareMessageDialog extends StatelessWidget {
  final String contentMessage;
  const ShareMessageDialog({Key? key, required this.contentMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 1.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message',
            style: TextStyle(
              letterSpacing: 1.2,
            ),
          ),
          Divider(
            height: 10.0,
          )
        ],
      ),
      content: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contentMessage,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Close',
            )
        ),
      ],
    );
  }
}
