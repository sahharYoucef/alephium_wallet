import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MnemonicTextField extends StatefulWidget {
  MnemonicTextField({Key? key}) : super(key: key);

  @override
  State<MnemonicTextField> createState() => MnemonicTextFieldState();
}

class MnemonicTextFieldState extends State<MnemonicTextField> {
  late final TextEditingController _controller;
  bool isActive = true;
  int? editIndex;

  late List<String> words;

  String get mnemonic {
    return words.join(" ").trim();
  }

  @override
  void initState() {
    words = <String>[];
    _controller = TextEditingController()
      ..addListener(() {
        if (_controller.value.text.contains(" ")) {
          final _words = _controller.value.text.split(" ");
          if (_words.length == 1) {
            _addNewWord();
          } else {
            _words.forEach((element) {
              if (words.length >= 24) return;
              if (element.isNotEmpty) words.add(element);
            });
            _controller.clear();
            setState(() {});
          }
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
          spacing: 4.0.w,
          runSpacing: 4.0.h,
          children: [
            ...words.mapIndexed((index, value) {
              return Material(
                color: WalletTheme.instance.buttonsBackground,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: WalletTheme.instance.buttonsForeground,
                        width: 2),
                    borderRadius: BorderRadius.circular(8.0)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${index + 1} - $value",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: WalletTheme.instance.buttonsForeground),
                      ),
                      SizedBox(
                        height: 24.w,
                        width: 24.w,
                        child: IconButton(
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            words.removeAt(index);
                            isActive = words.length < 24;
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: WalletTheme.instance.buttonsForeground,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                elevation: 2,
              );
            }).toList(),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ShakeTextFormField(
          enabled: isActive,
          autofocus: true,
          inputFormatters: [MnemonicInputFormatter()],
          textCapitalization: TextCapitalization.none,
          controller: _controller,
          autocorrect: false,
          enableSuggestions: false,
          style: Theme.of(context).textTheme.bodyMedium,
          onFieldSubmitted: (value) {
            _addNewWord();
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            labelText: 'Mnemonic',
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
