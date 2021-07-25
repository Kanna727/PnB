import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:portfolio_n_budget/constants.dart';

class DateTimePicker extends StatefulWidget {
  DateTimePicker({
    Key? key,
    required this.date,
    required this.onChange,
    required this.title,
    required this.disabled,
  }) : super(key: key);

  var date;
  final onChange;
  final title;
  final disabled;

  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late double _height;
  late double _width;

  DateTime selectedDate = DateTime.now();

  TextEditingController _dateController = TextEditingController();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat(DATE_FORMAT).format(selectedDate);
      });
      widget.onChange(DateFormat(DATE_FORMAT).format(selectedDate));
    }
  }

  @override
  void initState() {
    _dateController.text = DateFormat(DATE_FORMAT).format(DateTime.now());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        if (widget.disabled) return;
        _selectDate(context);
      },
      child: TextFormField(
        textAlign: TextAlign.center,
        enabled: false,
        keyboardType: TextInputType.datetime,
        controller: _dateController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: widget.title,
        ),
      ),
    );
  }
}
