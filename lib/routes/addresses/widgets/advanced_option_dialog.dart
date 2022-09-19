import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/routes/addresses/widgets/generate_address_dialog.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/utils/constants.dart';
import 'package:alephium_wallet/utils/gradient_input_bordder.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdvancedOptionsDialog extends StatelessWidget {
  final WalletDetailsBloc bloc;
  const AdvancedOptionsDialog({
    Key? key,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: WalletTheme.instance.background,
            borderRadius: BorderRadius.circular(
              16,
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Advanced operations :",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 6,
            ),
            Divider(),
            const SizedBox(
              height: 6,
            ),
            Text(
              "Advanced operations reserved to more experienced users. A \"normal\" user should not need to use them very often, if not at all.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(
              height: 12,
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                      child: Material(
                    color: WalletTheme.instance.primary,
                    shape: GradientOutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xff1902d5),
                            Color(0xfffe594e),
                          ],
                        )),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.walletUtxo,
                            arguments: {
                              "wallet": bloc.wallet,
                              "wallet-details": bloc,
                            });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Consolidate UTXOs",
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),
                            SvgPicture.asset(WalletIcons.utxoIcon),
                            const Spacer(),
                            Text(
                              "Consolidate (merge) your UTXOs into one.",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Material(
                    color: WalletTheme.instance.primary,
                    shape: GradientOutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xff1902d5),
                            Color(0xfffe594e),
                          ],
                        )),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(context);
                        showGeneralDialog(
                          barrierDismissible: true,
                          barrierLabel: "receive",
                          context: context,
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  GenerateWalletDialog(
                            type: GenerationType.group,
                            bloc: bloc,
                          ),
                          transitionDuration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: animation.drive(
                                Tween<Offset>(
                                  begin: Offset(0, 1),
                                  end: Offset.zero,
                                ),
                              ),
                              child: child,
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Generate one address per group",
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SvgPicture.asset(WalletIcons.minerIcon),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Useful for miners or DeFi use.",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
