import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/Methods/pick_date_time.dart';

class DateTimePickerButton extends StatefulWidget {
  const DateTimePickerButton({
    super.key,
    required this.text,
    required this.onDateTimePicked,
  });

  final String text;
  final void Function(DateTime) onDateTimePicked;

  @override
  State<DateTimePickerButton> createState() => _DateTimePickerButtonState();
}

class _DateTimePickerButtonState extends State<DateTimePickerButton> {
  late DateTime time;

  @override
  void initState() {
    super.initState();
    time = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        iconColor: const WidgetStatePropertyAll(Colors.white),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        backgroundColor: const WidgetStatePropertyAll(
          Color.fromARGB(255, 134, 129, 129),
        ),
      ),
      onPressed: () async {
        time = await pickDateTime(DateTime.now(), context);
        setState(() {});
        widget.onDateTimePicked(time); // Return the picked time
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 300,
          height: 70,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 30,
                width: 30,
                color: Colors.grey,
                child: const Icon(Icons.play_arrow),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.text,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      time.toString().substring(0, 16),
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
