import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class AddressText extends StatefulWidget {
  final String address;
  final TextStyle? style;
  AddressText({
    Key? key,
    required this.address,
    this.style,
  }) : super(key: key);

  @override
  State<AddressText> createState() => _AddressTextState();
}

class _AddressTextState extends State<AddressText> {
  late TextOverflow overflow;

  @override
  void initState() {
    overflow = TextOverflow.ellipsis;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (overflow == TextOverflow.ellipsis)
            overflow = TextOverflow.visible;
          else
            overflow = TextOverflow.ellipsis;
        });
      },
      onLongPress: () async {
        var data = ClipboardData(text: widget.address);
        await Clipboard.setData(data);
        context.showSnackBar("addressCopied".tr());
      },
      child: Text(
        '${widget.address}',
        style: widget.style != null
            ? widget.style!.copyWith(overflow: overflow)
            : TextStyle(overflow: overflow),
      ),
    );
  }
}
