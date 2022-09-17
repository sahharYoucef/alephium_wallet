import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:collection/collection.dart';

class MnemonicTextField extends StatefulWidget {
  MnemonicTextField({Key? key}) : super(key: key);

  @override
  State<MnemonicTextField> createState() => MnemonicTextFieldState();
}

class MnemonicTextFieldState extends State<MnemonicTextField> {
  late final TextEditingController _controller;
  bool isActive = true;
  int? editIndex;

  List<String> words = <String>[];

  String get mnemonic {
    return words.join(" ").trim();
  }

  @override
  void initState() {
    _controller = TextEditingController()
      ..addListener(() {
        if (_controller.value.text.contains(" ")) {
          _addNewWord();
        }
      });
    super.initState();
  }

  _addNewWord() {
    if (editIndex != null)
      words.insert(editIndex!, _controller.value.text.trim());
    else
      words.add(_controller.value.text.trim());
    _controller.clear();
    isActive = words.length < 24;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 4.0,
          runSpacing: 2.0,
          children: [
            ...words.mapIndexed((index, value) {
              return Chip(
                padding: EdgeInsets.symmetric(horizontal: 4),
                onDeleted: () {
                  words.removeAt(index);
                  isActive = words.length < 24;
                  setState(() {});
                },
                deleteIcon: Icon(
                  Icons.close,
                ),
                label: Text(
                  "${index + 1}-$value",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                elevation: 2,
              );
            }).toList(),
          ],
        ),
        TextFormField(
          enabled: isActive,
          autofocus: true,
          inputFormatters: [MnemonicInputFormatter()],
          textCapitalization: TextCapitalization.none,
          style: Theme.of(context).textTheme.headline6,
          controller: _controller,
          autocorrect: false,
          enableSuggestions: false,
          onFieldSubmitted: (value) {
            _addNewWord();
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            border: UnderlineInputBorder(),
            labelText: 'Mnemonic',
            labelStyle: Theme.of(context).textTheme.bodyMedium,
          ),
          maxLines: 1,
        ),
      ],
    );
  }
}

class MnemonicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.trim().isEmpty) {
      return TextEditingValue(text: "");
    }
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}
