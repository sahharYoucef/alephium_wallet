import 'package:alephium_wallet/routes/restore_wallet/widgets/mnemonic_text_field.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/create_wallet/create_wallet_bloc.dart';

class RestoreWallet extends StatefulWidget {
  final CreateWalletBloc bloc;

  RestoreWallet({super.key, required this.bloc});

  @override
  State<RestoreWallet> createState() => _RestoreWalletState();
}

class _RestoreWalletState extends State<RestoreWallet> {
  final GlobalKey<MnemonicTextFieldState> _key =
      GlobalKey<MnemonicTextFieldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).padding.top + 70,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      child: Text(
                        "enterMnemonic".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        child: MnemonicTextField(
                          key: _key,
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Spacer(),
                        SafeArea(
                          top: false,
                          bottom: true,
                          minimum: EdgeInsets.only(
                              left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
                          child: Hero(
                            tag: "button",
                            child: OutlinedButton(
                              onPressed: () {
                                if (_key.currentState?.mnemonic != null)
                                  widget.bloc.add(
                                    CreateWalletRestore(
                                      mnemonic: _key.currentState!.mnemonic,
                                    ),
                                  );
                              },
                              child: Text("restoreWallet".tr()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            WalletAppBar(
              label: Text(
                'restoreWallet'.tr(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Positioned.fill(
              child: BlocBuilder<CreateWalletBloc, CreateWalletState>(
                  bloc: widget.bloc,
                  buildWhen: (previous, current) {
                    return current is GenerateWalletLoading ||
                        previous is GenerateWalletLoading;
                  },
                  builder: (context, state) {
                    return Visibility(
                      visible: state is GenerateWalletLoading,
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: AlephiumIcon(
                            spinning: true,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
