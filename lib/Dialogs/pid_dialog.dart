import 'package:flutter/material.dart';

class PIDDialog extends StatefulWidget {
  const PIDDialog({super.key});

  @override
  State<PIDDialog> createState() => _PIDDialogState();
}

class _PIDDialogState extends State<PIDDialog> {
  final _kP = TextEditingController();
  final _kI = TextEditingController();
  final _kD = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 1.0,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PID SETTINGS',
            style: TextStyle(
              letterSpacing: 1.2,
              color: Colors.black
            ),
          ),
          Divider(
            height: 10.0,
          )
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                flex: 1,
                child: Text(
                  'P Value:',
                  style: TextStyle(
                    color: Colors.black
                  ),
                )
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _kP,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    contentPadding: EdgeInsets.only(top: 14.0),
                    //labelText: '  P Value',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16,),
          Row(
            children: [
              const Expanded(
                flex: 1,
                child: Text(
                  'I Value:',
                  style: TextStyle(
                    color: Colors.black
                  ),
                )
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _kI,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    contentPadding: EdgeInsets.only(top: 14.0),
                    //labelText: '  P Value',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16,),
          Row(
            children: [
              const Expanded(
                flex: 1,
                child: Text(
                  'D Value:',
                  style: TextStyle(
                    color: Colors.black
                  ),
                )
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _kD,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    contentPadding: EdgeInsets.only(top: 14.0),
                    //labelText: '  P Value',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16,),

        ],
      ),
    );
  }
}
