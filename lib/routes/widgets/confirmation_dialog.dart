import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class WalletConfirmationDialog extends StatelessWidget {
  final String data;
  final String title;
  final void Function()? onConfirmTap;
  const WalletConfirmationDialog({
    Key? key,
    required this.data,
    required this.title,
    this.onConfirmTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: MediaQuery.of(context).viewInsets,
        width: MediaQuery.of(context).size.width * .70,
        child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(16.0),
            color: WalletTheme.instance.background,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
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
                    data,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(wordSpacing: 2.0),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  darken(WalletTheme.instance.primary, 25)),
                          child: Text(
                            "close".tr(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onConfirmTap,
                          child: Text(
                            "confirm".tr(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
    ;
  }
}
