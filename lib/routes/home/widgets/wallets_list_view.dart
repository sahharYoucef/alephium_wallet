import 'package:alephium_wallet/routes/home/widgets/wallet_tile.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';

class WalletListView extends StatelessWidget {
  final List<WalletStore> wallets;
  const WalletListView({
    super.key,
    required this.wallets,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        bottom: 100 + context.bottomPadding,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Center(
              child: WalletTile(wallet: wallets[index]),
            );
          },
          childCount: wallets.length,
        ),
      ),
    );
  }
}
