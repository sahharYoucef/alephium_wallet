import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/format.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReceiveAmountField extends StatefulWidget {
  final void Function(double?)? onChanged;
  const ReceiveAmountField({Key? key, this.onChanged}) : super(key: key);

  @override
  State<ReceiveAmountField> createState() => _ReceiveAmountFieldState();
}

class _ReceiveAmountFieldState extends State<ReceiveAmountField> {
  bool amountType = false;
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
    if (widget.onChanged != null && amount != null) {
      final double? value = amountType
          ? AppStorage.instance.price != null
              ? amount! / AppStorage.instance.price!
              : null
          : amount;
      widget.onChanged!(value);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  InputDecoration textFieldDecoration(String label) {
    return InputDecoration(
      contentPadding: EdgeInsets.all(8.w),
      labelText: label,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(amountType ? AppStorage.instance.currency.toUpperCase() : "ℵ"),
          SizedBox(
            width: 4.w,
          ),
          IconButton(
            icon: Icon(
              Icons.switch_left,
              color: WalletTheme.instance.textColor,
            ),
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
        ShakeTextFormField(
          controller: controller,
          inputFormatters: [
            AmountFormatter(
              decimals: 17,
            )
          ],
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          autocorrect: false,
          decoration: textFieldDecoration("amount".tr()),
          style: Theme.of(context).textTheme.bodyMedium,
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
