import 'package:flutter/material.dart';

class Dropdown extends StatelessWidget {
  Dropdown({
    Key? key,
    required this.dropdownValue,
    required this.onChange,
    required this.list,
    required this.title,
    required this.validator,
  }) : super(key: key);

  var dropdownValue;
  final onChange;
  final list;
  final title;
  final validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      hint: Text(title),
      value: dropdownValue,
      onChanged: onChange,
      items: list == null
          ? null
          : list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
      decoration: InputDecoration(
        filled: true,
        labelText: dropdownValue != null ? title : null,
      ),
      validator: validator,
    );
  }
}
