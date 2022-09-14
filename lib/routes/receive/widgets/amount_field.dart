import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/format.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ReceiveAmountField extends StatefulWidget {
  final void Function(double?)? onChanged;
  const ReceiveAmountField({Key? key, this.onChanged}) : super(key: key);

  @override
  State<ReceiveAmountField> createState() => _ReceiveAmountFieldState();
}

class _ReceiveAmountFieldState extends State<ReceiveAmountField> {
  bool amountType = true;
  double? amount;
  late final TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController()
      ..addListener(() {
        setState(() {
          amount = double.tryParse(controller.text);
        });
        _onChanged();
      });
    super.initState();
  }

  _onChanged() {
    if (widget.onChanged != null && amount != null)
      widget.onChanged!(amountType
          ? amount
          : AppStorage.instance.price != null
              ? amount! / AppStorage.instance.price!
              : null);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  InputDecoration textFieldDecoration(String label) {
    return InputDecoration(
      contentPadding: EdgeInsets.all(8),
      labelText: label,
      hintStyle: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: Colors.black.withOpacity(.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              amountType ? AppStorage.instance.currency.toUpperCase() : "ALPH"),
          SizedBox(
            width: 4,
          ),
          IconButton(
            icon: Icon(Icons.switch_left),
            onPressed: () {
              amountType = !amountType;
              _onChanged();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  String get getValue {
    var value = amountType
        ? amount! / AppStorage.instance.price!
        : amount! * AppStorage.instance.price!;
    if (amountType) {
      return Format.formatNumber(value);
    }
    return NumberFormat.currency(symbol: "\$").format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          inputFormatters: [AmountFormatter()],
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          autocorrect: false,
          decoration: textFieldDecoration("Amount"),
        ),
        Row(
          children: [
            Spacer(),
            Text(
              amount != null && AppStorage.instance.price != null
                  ? getValue
                  : "",
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
