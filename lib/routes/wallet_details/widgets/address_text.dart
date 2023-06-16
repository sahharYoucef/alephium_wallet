import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class AddressText extends StatefulWidget {
  final String address;
  final TextStyle? style;
  final String? value;
  final TextAlign align;
  final Function? onTap;
  AddressText({
    Key? key,
    required this.address,
    this.onTap,
    this.style,
    this.value,
    this.align = TextAlign.start,
  }) : super(key: key);

  @override
  State<AddressText> createState() => _AddressTextState();
}

class _AddressTextState extends State<AddressText> {
  late TextOverflow overflow;
  GlobalKey key = GlobalKey();
  Offset tapPosition = Offset.zero;
  late TextStyle style;

  @override
  void initState() {
    overflow = TextOverflow.ellipsis;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    style = widget.style ??
        Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
            );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
          return;
        }
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
        widget.value ?? widget.address,
        key: key,
        textAlign: widget.align,
        style: style.copyWith(overflow: overflow),
      ),
    );
  }
}
