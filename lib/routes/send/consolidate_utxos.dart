import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/routes/send/widgets/address_from.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/constants.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../utils/helpers.dart';

class ConsolidateUtxosRoute extends StatefulWidget {
  final WalletStore wallet;
  final WalletDetailsBloc detailsBloc;
  ConsolidateUtxosRoute({
    Key? key,
    required this.wallet,
    required this.detailsBloc,
  }) : super(key: key);

  @override
  State<ConsolidateUtxosRoute> createState() => _ConsolidateUtxosRouteState();
}

class _ConsolidateUtxosRouteState extends State<ConsolidateUtxosRoute> {
  late AddressStore _fromAddressStore;
  late AddressStore _toAddressStore;
  late List<AddressStore> fromAddresses;
  late TransactionBloc _bloc;
  @override
  void initState() {
    fromAddresses = widget.wallet.addresses
        .where(
          (element) => element.balance != 0,
        )
        .toList();
    _fromAddressStore = fromAddresses.first;
    _bloc = TransactionBloc(
      getIt.get<BaseApiRepository>(),
      getIt.get<BaseWalletService>(),
      widget.wallet,
    );
    _bloc.fromAddress = _fromAddressStore;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is TransactionError) {
          context.showSnackBar(state.message, level: Level.error);
        }
        if (state is TransactionSendingCompleted) {
          widget.detailsBloc.add(AddPendingTxs(state.transactions));
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            WalletAppBar(
              label: Text(
                'consolidateUTXOs'.tr(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              WalletTheme.instance.gradientOne,
                              WalletTheme.instance.gradientTwo,
                            ],
                          ).createShader(bounds);
                        },
                        child: SvgPicture.asset(
                          WalletIcons.sendIcon,
                          color: Colors.white,
                        ),
                      ),
                      AddressFromDropDownMenu(
                        label: "fromAddress".tr(),
                        addresses: fromAddresses,
                        onChanged: (value) {
                          setState(() {
                            _fromAddressStore = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      AddressFromDropDownMenu(
                        label: "toAddress".tr(),
                        addresses: widget.wallet.addresses.toList(),
                        onChanged: (value) {
                          _toAddressStore = value;
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "${'availableBalance'.tr()}: ${_fromAddressStore.formattedBalance}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Spacer(),
                      Hero(
                        tag: "button",
                        child: OutlinedButton(
                          child: Text('sweep'.tr().toUpperCase()),
                          onPressed: () {
                            _bloc.add(SweepTransaction(
                                _fromAddressStore, _toAddressStore));
                          },
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
