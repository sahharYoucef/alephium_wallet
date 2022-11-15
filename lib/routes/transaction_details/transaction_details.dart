import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:alephium_wallet/api/repositories/alephium/alephium_api_repository.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/main.dart';

class TransactionDetails extends StatefulWidget {
  final TransactionStore transaction;
  const TransactionDetails({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  late final ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.transaction.txStatus == TXStatus.completed;
    final title = widget.transaction.blockHash != null
        ? "Hash"
        : "${'transaction'.tr()} id";
    final value = widget.transaction.blockHash != null
        ? widget.transaction.blockHash
        : widget.transaction.transactionID;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.only(
                top: 20 + 70 + context.topPadding,
                bottom: 32,
              ),
              controller: scrollController,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Material(
                    color: Theme.of(context).primaryColor,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (value != null) ...[
                            Text(
                              title,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            AddressText(
                              address: "${widget.transaction.blockHash}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    foreground: Paint()
                                      ..shader = LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          WalletTheme.instance.gradientOne,
                                          WalletTheme.instance.gradientTwo,
                                        ],
                                      ).createShader(
                                          Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                  ),
                            ),
                            const Divider(),
                          ],
                          Row(
                            children: [
                              Text(
                                "network".tr(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Spacer(),
                              Text(
                                widget.transaction.network.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Text(
                                "status".tr(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Spacer(),
                              Text(
                                status ? "confirmed".tr() : "pending".tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Text(
                                "amount".tr(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Spacer(),
                              Text(
                                "${widget.transaction.txAmount}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "timestamp".tr(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(
                                        widget.transaction.timeStamp)
                                    .toIso8601String(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            "incomingAmounts".tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          ...widget.transaction.refsIn.map(
                            (ref) => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "\u2022  ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AddressText(
                                        address: "${ref.address}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              foreground: Paint()
                                                ..shader = LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                  colors: [
                                                    WalletTheme
                                                        .instance.gradientOne,
                                                    WalletTheme
                                                        .instance.gradientTwo,
                                                  ],
                                                ).createShader(Rect.fromLTWH(
                                                    0.0, 0.0, 200.0, 70.0)),
                                            ),
                                      ),
                                      Text(
                                        "${ref.txAmount}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Text(
                            "outgoingAmounts".tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          ...widget.transaction.refsOut.map(
                            (ref) => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "\u2022  ",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AddressText(
                                        address: "${ref.address}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              foreground: Paint()
                                                ..shader = LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                  colors: [
                                                    WalletTheme
                                                        .instance.gradientOne,
                                                    WalletTheme
                                                        .instance.gradientTwo,
                                                  ],
                                                ).createShader(Rect.fromLTWH(
                                                    0.0, 0.0, 200.0, 70.0)),
                                            ),
                                      ),
                                      Text(
                                        "${ref.txAmount}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "gasAmount".tr(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                widget.transaction.fee,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "gasPrice".tr(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                "${widget.transaction.transactionGas}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: AlephiumIcon(
                      spinning: true,
                    ),
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: WalletAppBar(
                controller: scrollController,
                label: Text(
                  'transactionDetails'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                action: AppBarIconButton(
                  tooltip: "launchUrl".tr(),
                  onPressed: _launchUrl,
                  icon: Icon(
                    Icons.launch,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl() async {
    final repo = getIt.get<BaseApiRepository>() as AlephiumApiRepository;
    final url =
        "${repo.network.explorerUrl}/transactions/${widget.transaction.txHash}";
    await launch(url);
  }
}
