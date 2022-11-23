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
              foreground: Paint()
                ..shader = LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    WalletTheme.instance.gradientOne,
                    WalletTheme.instance.gradientTwo,
                  ],
                ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
            );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          if (overflow == TextOverflow.ellipsis)
            overflow = TextOverflow.visible;
          else
            overflow = TextOverflow.ellipsis;
        });
      },
      onTapDown: (details) {
        // _getTapPosition(details);
      },
      onLongPress: () async {
        // _showContextMenu(context);
        var data = ClipboardData(text: widget.address);
        await Clipboard.setData(data);
        context.showSnackBar("addressCopied".tr());
      },
      child: Text(
        '${widget.address}',
        key: key,
        style: style.copyWith(overflow: overflow),
      ),
    );
  }

  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    final _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    setState(() {
      tapPosition = _tapPosition;
    });
  }

  void _showContextMenu(
    BuildContext context,
  ) async {
    final RenderBox overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;

    final RenderBox button = context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(const Offset(0, -65), ancestor: overlay),
        button.localToGlobal(
            button.size.bottomRight(Offset.zero) + const Offset(-50, 0),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        context: context,
        position: position,
        items: [
          PopupMenuItem(
            enabled: false,
            padding: EdgeInsets.zero,
            child: Center(
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: kMinInteractiveDimension,
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Copy'),
                        )),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    // VerticalDivider(
                    //   thickness: 0.5,
                    //   color: Colors.black,
                    // ),
                    SizedBox(
                      height: kMinInteractiveDimension,
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Save'),
                        )),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]);

    // Implement the logic for each choice here
    switch (result) {
      case 'favorites':
        debugPrint('Add To Favorites');
        break;
      case 'comment':
        debugPrint('Write Comment');
        break;
      case 'hide':
        debugPrint('Hide');
        break;
    }
  }
}
