import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/routes/send/widgets/to_addresses.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
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
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormFieldState> _gasAmountKey = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> _amountKey = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> _gasPriceKey = GlobalKey<FormFieldState>();
  late final TextEditingController _amountController;
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
        _bloc.amount = widget.initialData?["amount"].toString();
      if (widget.initialData?["address"] != null)
        _bloc.toAddresses.add(widget.initialData?["address"]);
    }
    _amountController = TextEditingController(text: _bloc.amount);
    if (widget.addressStore != null) {
      _bloc.fromAddress = widget.addressStore;
    }

    super.initState();
  }

  @override
  void dispose() {
    _bloc.close();
    _amountController.dispose();
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
            listener: (context, state) {
              if (state is TransactionError) {
                context.showSnackBar(state.message, level: Level.error);
              }
              if (state is TransactionSendingCompleted) {
                if (widget.detailsBloc != null)
                  widget.detailsBloc?.add(AddPendingTxs(state.transactions));
                Navigator.pop(context);
              }
            },
            child: Form(
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
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            slivers: [
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 16),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: ShaderMask(
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
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: AddressFromDropDownMenu(
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
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 8),
                              ),
                              ToAddressesField(
                                bloc: bloc,
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 8),
                              ),
                              SliverToBoxAdapter(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: TextFormField(
                                    controller: _amountController,
                                    key: _amountKey,
                                    inputFormatters: [AmountFormatter()],
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    validator: amountValidator,
                                    onChanged: (value) {
                                      _bloc.add(TransactionValuesChangedEvent(
                                          amount: value));
                                      _amountKey.currentState?.validate();
                                    },
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                        labelText: "amount".tr(),
                                        suffixIcon: Container(
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(right: 8),
                                          width: 10,
                                          child: InkWell(
                                            onTap: () {
                                              if (_bloc.fromAddress != null)
                                                _bloc.add(
                                                    TransactionValuesChangedEvent(
                                                        amount: _bloc
                                                            .fromAddress
                                                            ?.addressBalance
                                                            .toString()));
                                              if (_bloc.fromAddress
                                                      ?.addressBalance !=
                                                  null)
                                                _amountController.text = _bloc
                                                    .fromAddress!.addressBalance
                                                    .toString();
                                              _amountKey.currentState
                                                  ?.validate();
                                            },
                                            child: Text(
                                              "max".tr(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w800),
                                            ),
                                          ),
                                        ))),
                              )),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 16),
                              ),
                              SliverToBoxAdapter(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: BlocBuilder<TransactionBloc,
                                    TransactionState>(
                                  bloc: _bloc,
                                  builder: (context, state) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        "${'availableBalance'.tr()} : ${_bloc.balance} ℵ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    );
                                  },
                                ),
                              )),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 16),
                              ),
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: BlocBuilder<TransactionBloc,
                                          TransactionState>(
                                      bloc: _bloc,
                                      buildWhen: (previous, current) {
                                        return current
                                            is TransactionStatusState;
                                      },
                                      builder: ((context, state) {
                                        if (state is TransactionStatusState) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              if (_bloc.transaction != null)
                                                Container(
                                                  margin: EdgeInsets.all(16),
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[200]!),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${'expectedFees'.tr()} : ${_bloc.expectedFees} ℵ",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      Text(
                                                        "${'amountToSend'.tr()} : ${_bloc.amount} ℵ",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              else ...[
                                                TextFormField(
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                  key: _gasAmountKey,
                                                  inputFormatters: [
                                                    AmountFormatter()
                                                  ],
                                                  validator: gasAmountValidator,
                                                  onChanged: (value) {
                                                    _bloc.add(
                                                        TransactionValuesChangedEvent(
                                                            gas: value));
                                                    _gasAmountKey.currentState
                                                        ?.validate();
                                                  },
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      textFieldDecoration(
                                                    "gasAmount".tr(),
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                TextFormField(
                                                  key: _gasPriceKey,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                  inputFormatters: [
                                                    AmountFormatter()
                                                  ],
                                                  validator: gasPriceValidator,
                                                  onChanged: (value) {
                                                    _bloc.add(
                                                        TransactionValuesChangedEvent(
                                                            gasPrice: value));
                                                    _gasPriceKey.currentState
                                                        ?.validate();
                                                  },
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      textFieldDecoration(
                                                    "gasPrice".tr(),
                                                  ),
                                                ),
                                              ],
                                              const Spacer(),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Hero(
                                                tag: "button",
                                                child: OutlinedButton(
                                                  child: Text(
                                                    state.transaction != null
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
                                                                  ?.validate() ??
                                                              false;
                                                          if (!isValid) return;
                                                          if (state
                                                                  .transaction ==
                                                              null) {
                                                            _bloc.add(
                                                              CheckTransactionEvent(
                                                                _bloc
                                                                    .fromAddress,
                                                              ),
                                                            );
                                                          } else {
                                                            _bloc.add(
                                                                SignAndSendTransaction(
                                                              privateKey: _bloc
                                                                  .fromAddress!
                                                                  .privateKey!,
                                                              transactionID: _bloc
                                                                  .transaction!
                                                                  .txId!,
                                                              unsignedTx: _bloc
                                                                  .transaction!
                                                                  .unsignedTx!,
                                                            ));
                                                          }
                                                        }
                                                      : null,
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
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  @override
  List<String> get toAddresses => [];
}
