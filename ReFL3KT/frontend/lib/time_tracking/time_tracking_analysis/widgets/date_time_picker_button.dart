import 'package:flutter/material.dart';
import 'package:frontend/time_tracking/Methods/pick_date_time.dart';

class DateTimePickerButton extends StatefulWidget {
  const DateTimePickerButton({super.key, required this.text});

  final String text;

  @override
  State<DateTimePickerButton> createState() => _DateTimePickerButtonState();
}

class _DateTimePickerButtonState extends State<DateTimePickerButton> {
  // get newStartTime => null;

  late DateTime time;
  // late DateTime endTime;
  @override
  void initState() {
    super.initState();
    time = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
          iconColor: WidgetStatePropertyAll(Colors.white),
          shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          backgroundColor: WidgetStatePropertyAll(
            const Color.fromARGB(255, 134, 129, 129),
          )),
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
                  child: Icon(Icons.play_arrow)),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.text,
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      time.toString().substring(0, 16),
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onPressed: () async {
        time = await pickDateTime(DateTime.now(), context);
        // print(time);
        setState(() {});

        // print(widget.timeEntry.startTime);
      },
    );
  }
}
