import 'package:alephium_wallet/bloc/create_wallet/create_wallet_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/multisig_wallet/widgets/multisig_slider.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tuple/tuple.dart';

class MultisigWalletPage extends StatelessWidget {
  final CreateWalletBloc bloc;
  MultisigWalletPage({
    super.key,
    required this.bloc,
  });
  final GlobalKey<ShakeTextFormFieldState> _nameKey =
      GlobalKey<ShakeTextFormFieldState>();
  final GlobalKey<ShakeFormFieldState<Tuple2<int, int>>> _sliderKey =
      GlobalKey<ShakeFormFieldState<Tuple2<int, int>>>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      WalletAppBar(
        label: Text(
          'multisigWallet'.tr(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      Expanded(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                  delegate: SliverChildListDelegate(
                [
                  const SizedBox(
                    height: 20,
                  ),
                  ShakeTextFormField(
                    key: _nameKey,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return null;
                      }
                      var validator = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
                      if (!validator.hasMatch(value!)) {
                        return 'Invalid Address';
                      }
                      return null;
                    },
                    onChanged: (value) {},
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'walletName'.tr(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MultisigSlidersFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: _sliderKey,
                    validator: (value) {
                      if (value == null ||
                          (value.item1 == 0 && value.item2 == 0)) {
                        return "Please choose number of wallets and required number!";
                      } else if (value.item2 == 0) {
                        return "Please choose number of required signatures!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              )),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Hero(
                      tag: "Button",
                      child: OutlinedButton(
                        child: Text("next".tr()),
                        onPressed: () {
                          final isValid =
                              _sliderKey.currentState?.validate(shake: true) ??
                                  false;
                          final wallets = _sliderKey.currentState?.value?.item1;
                          final mrequired =
                              _sliderKey.currentState?.value?.item2;
                          final title = _nameKey.currentState?.value;
                          if (isValid) {
                            Navigator.pushNamed(
                                context, Routes.multisigAddresses,
                                arguments: {
                                  "title": title,
                                  "bloc": bloc,
                                  "walletsNum": wallets,
                                  "requiredNum": mrequired,
                                });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )
    ]));
  }
}
