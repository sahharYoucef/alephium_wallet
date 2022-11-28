import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class WalletSettingDataDialog extends StatefulWidget {
  final String data;
  final String title;
  final bool isSecure;
  const WalletSettingDataDialog({
    Key? key,
    required this.data,
    required this.title,
    this.isSecure = false,
  }) : super(key: key);

  @override
  State<WalletSettingDataDialog> createState() =>
      _WalletSettingDataDialogState();
}

class _WalletSettingDataDialogState extends State<WalletSettingDataDialog> {
  @override
  void initState() {
    if (widget.isSecure)
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.isSecure)
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: MediaQuery.of(context).viewInsets,
        width: MediaQuery.of(context).size.width * .70,
        child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(16.0),
            color: WalletTheme.instance.primary,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.data,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(wordSpacing: 2.0),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "close".tr(),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
