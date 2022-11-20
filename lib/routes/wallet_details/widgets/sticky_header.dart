import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:easy_localization/easy_localization.dart';

class StickyHeader extends StatelessWidget {
  final WalletDetailsState state;
  final Widget sliver;
  const StickyHeader(this.state, {super.key, required this.sliver});

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
        sliver: sliver,
        header: Material(
            color: Theme.of(context).primaryColor,
            shadowColor: WalletTheme.instance.gradientOne,
            elevation: 2,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'transactions'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Spacer(),
                  AlephiumIcon(
                    spinning: state is WalletDetailsCompleted &&
                        (state as WalletDetailsCompleted).withLoadingIndicator,
                  )
                ],
              ),
            )));
  }
}
