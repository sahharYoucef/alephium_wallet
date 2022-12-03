import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/routes/send/widgets/add_token_button.dart';
import 'package:alephium_wallet/routes/send/widgets/added_tokens_list.dart';
import 'package:alephium_wallet/routes/send/widgets/amount_field.dart';
import 'package:alephium_wallet/routes/send/widgets/available_balance_tile.dart';
import 'package:alephium_wallet/routes/send/widgets/check_tx_result.dart';
import 'package:alephium_wallet/routes/send/widgets/gas_advanced_options.dart';
import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/routes/send/widgets/success_dialog.dart';
import 'package:alephium_wallet/routes/send/widgets/to_address_field.dart';
import 'package:alephium_wallet/routes/send/widgets/wait_for_signatures.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/shake_widget.dart';
import 'package:alephium_wallet/services/authentication_service.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/routes/send/widgets/address_from.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/constants.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:alephium_wallet/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../bloc/transaction/transaction_bloc.dart';

class SendTransactionPage extends StatefulWidget {
  final AddressStore? addressStore;
  final WalletStore wallet;
  final WalletDetailsBloc? detailsBloc;
  final Map<String, dynamic>? initialData;
  SendTransactionPage({
    Key? key,
    this.addressStore,
    this.initialData,
    required this.wallet,
    this.detailsBloc,
  }) : super(key: key);

  @override
  State<SendTransactionPage> createState() => _SendTransactionPageState();
}

class _SendTransactionPageState extends State<SendTransactionPage>
    with InputValidators {
  GlobalKey<ShakeFormState> _formKey = GlobalKey<ShakeFormState>();
  GlobalKey<ShakeErrorState> _ShakeWidgetKey = GlobalKey<ShakeErrorState>();

  late final TransactionBloc _bloc;
  @override
  void initState() {
    _bloc = TransactionBloc(
      getIt.get<AuthenticationService>(),
      getIt.get<BaseApiRepository>(),
      getIt.get<BaseWalletService>(),
      widget.wallet,
    );
    if (widget.initialData != null) {
      if (widget.initialData?["amount"] != null)
        _bloc.amount = widget.initialData?["amount"];
      if (widget.initialData?["address"] != null)
        _bloc.toAddress = widget.initialData?["address"];
    }
    if (widget.addressStore != null) {
      _bloc.fromAddress = widget.addressStore;
    }

    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  TransactionBloc get bloc => _bloc;

  @override
  WalletStore get wallet => widget.wallet;

  InputDecoration textFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: BlocListener<TransactionBloc, TransactionState>(
            bloc: _bloc,
            listener: (context, state) async {
              if (state is TransactionError) {
                context.showSnackBar(state.message, level: Level.error);
              } else if (state is TransactionSendingCompleted) {
                if (widget.detailsBloc != null)
                  widget.detailsBloc?.add(AddPendingTxs(state.transactions));
                await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => TransactionSuccessDialog(
                          amount: _bloc.amount!.toString(),
                          transaction: state.transactions.first,
                        ));
                Navigator.pop(context);
              } else if (state is WaitForOtherSignatureState) {
                await showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: false,
                    constraints: BoxConstraints(
                        maxHeight: context.height - context.topPadding - 80),
                    backgroundColor: Colors.transparent,
                    context: context,
                    enableDrag: false,
                    builder: (context) => WaitForOtherSignatures(
                          addresses: state.addresses,
                          txId: state.txId,
                          wallet: widget.wallet,
                          bloc: _bloc,
                        ));
                // widget.detailsBloc?.add(AddPendingTxs(state.transactions));
              }
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: ShakeForm(
                    key: _formKey,
                    child: Column(
                      children: [
                        WalletAppBar(
                          label: Text(
                            'sendTransaction'.tr(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        Expanded(
                          child: CustomScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                sliver: SliverList(
                                    delegate: SliverChildListDelegate([
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
                                    initialAddress: widget.addressStore,
                                    label: "fromAddress".tr(),
                                    addresses: widget.wallet.addresses
                                        .where(
                                          (element) => element.balance != 0,
                                        )
                                        .toList(),
                                    onChanged: (address) {
                                      _bloc.add(TransactionValuesChangedEvent(
                                          fromAddress: address));
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  ToAddressField(
                                    key: _ShakeWidgetKey,
                                    enableSuggestion: true,
                                    label: "toAddress".tr(),
                                    onChanged: (value) {
                                      _bloc.add(TransactionValuesChangedEvent(
                                          toAddress: value));
                                    },
                                    validator: addressToValidator,
                                    initialValue:
                                        widget.initialData?["address"],
                                  ),
                                  const SizedBox(height: 8),
                                  AmountTextField(
                                    bloc: _bloc,
                                    validator: amountValidator,
                                    initialValue: _bloc.amount?.toString(),
                                  ),
                                  const SizedBox(height: 16),
                                  AvailableBalanceTile(
                                    bloc: _bloc,
                                  ),
                                  AddedTokensList(
                                    bloc: _bloc,
                                  )
                                  // const SizedBox(height: 8),
                                ])),
                              ),
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child:
                                      BlocBuilder<TransactionBloc,
                                              TransactionState>(
                                          bloc: _bloc,
                                          buildWhen: (previous, current) {
                                            return current
                                                is TransactionStatusState;
                                          },
                                          builder: ((context, state) {
                                            if (state
                                                is TransactionStatusState) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  if (_bloc.transaction != null)
                                                    CheckTransactionResult(
                                                        bloc: bloc)
                                                  else ...[
                                                    Divider(
                                                      height: 1,
                                                    ),
                                                    GasAdvancedOption(
                                                      bloc: _bloc,
                                                      gasAmountValidator:
                                                          gasAmountValidator,
                                                      gasPriceValidator:
                                                          gasPriceValidator,
                                                    ),
                                                  ],
                                                  const Spacer(),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  IntrinsicHeight(
                                                    child: Row(
                                                      children: [
                                                        AddTokenButton(
                                                          bloc: _bloc,
                                                        ),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Hero(
                                                            tag: "button",
                                                            child:
                                                                OutlinedButton(
                                                              child: Text(
                                                                state.transaction !=
                                                                        null
                                                                    ? 'send'
                                                                        .tr()
                                                                        .toUpperCase()
                                                                    : 'check'
                                                                        .tr()
                                                                        .toUpperCase(),
                                                              ),
                                                              onPressed: _bloc
                                                                      .activateButton
                                                                  ? () {
                                                                      var isValid = _formKey
                                                                              .currentState
                                                                              ?.validate(shake: true) ??
                                                                          false;
                                                                      if (!isValid) {
                                                                        return;
                                                                      }
                                                                      if (state
                                                                              .transaction ==
                                                                          null) {
                                                                        _bloc
                                                                            .add(
                                                                          CheckTransactionEvent(
                                                                            _bloc.fromAddress,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        if (wallet.type ==
                                                                            WalletType.normal)
                                                                          _bloc.add(
                                                                              SignAndSendTransaction(
                                                                            privateKey:
                                                                                _bloc.fromAddress!.privateKey!,
                                                                            transactionID:
                                                                                _bloc.transaction!.txId!,
                                                                            unsignedTx:
                                                                                _bloc.transaction!.unsignedTx!,
                                                                          ));
                                                                        else
                                                                          _bloc.add(
                                                                              CheckSignMultisigTransaction(_bloc.fromAddress));
                                                                      }
                                                                    }
                                                                  : null,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 16,
                                                  ),
                                                ],
                                              );
                                            }
                                            return const SizedBox();
                                          })),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                      bloc: _bloc,
                      builder: (context, state) {
                        return Visibility(
                          visible: state is TransactionLoading,
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
            )),
      ),
    );
  }
}
