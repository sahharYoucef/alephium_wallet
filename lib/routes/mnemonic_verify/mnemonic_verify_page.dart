import 'dart:math';

import 'package:alephium_wallet/bloc/create_wallet/create_wallet_bloc.dart';
import 'package:alephium_wallet/routes/mnemonic_verify/widgets/draggable_item.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WalletMnemonicVerifyPage extends StatefulWidget {
  final WalletStore wallet;
  final CreateWalletBloc bloc;
  WalletMnemonicVerifyPage({
    Key? key,
    required this.wallet,
    required this.bloc,
  }) : super(key: key);

  @override
  State<WalletMnemonicVerifyPage> createState() =>
      _WalletMnemonicVerifyPageState();
}

class _WalletMnemonicVerifyPageState extends State<WalletMnemonicVerifyPage> {
  late List<String?> values;
  late List<String> mnemonic;
  String message = '';
  late List<int> indexes;
  List _data = <Map<String, dynamic>?>[null, null];
  Color? color;

  @override
  void initState() {
    _fillIndexes();
    mnemonic = widget.wallet.mnemonic!.split(" ").toList();
    values = List.from(mnemonic);
    values.shuffle();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    color = Theme.of(context).primaryColor;
    super.didChangeDependencies();
  }

  _fillIndexes() {
    var random = Random();
    indexes = [];
    indexes.add(random.nextInt(24));
    late int newIndex;
    do {
      newIndex = random.nextInt(24);
    } while (newIndex == indexes[0]);
    indexes.add(newIndex);
    indexes.sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WalletAppBar(
            label: Text(
              'verifyMnemonic'.tr(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 16.h, left: 16.w, right: 16.w, bottom: 4.h),
                      child: Text(
                        "verifyMnemonicDescription".tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                      child: Row(
                        children: [
                          ...List.generate(
                              2,
                              ((index) => Expanded(
                                    child: Padding(
                                      padding: index == 0
                                          ? EdgeInsets.only(right: 4.0)
                                          : EdgeInsets.only(left: 4.0),
                                      child: SizedBox(
                                        height: 70.h,
                                        child: DragTarget<Map<String, dynamic>>(
                                          onAccept: ((data) {
                                            if (_data[index] != null) {
                                              values[_data[0]["index"]] =
                                                  _data[0]["value"];
                                            }
                                            values[data["index"]] = null;
                                            _data[index] = data;
                                            setState(() {});
                                          }),
                                          builder: (context, candidateData,
                                              rejectedData) {
                                            String? data =
                                                _data[index]?["value"];
                                            return data != null
                                                ? Material(
                                                    color: color,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0.w)),
                                                    elevation: 2,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (_data[index] !=
                                                            null) {
                                                          values[_data[index]
                                                                  ["index"]] =
                                                              _data[index]
                                                                  ["value"];
                                                          _data[index] = null;
                                                        }
                                                        if (message
                                                            .isNotEmpty) {
                                                          color = WalletTheme
                                                              .instance.primary;
                                                          message = "";
                                                        }
                                                        setState(() {});
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 16.w,
                                                          vertical: 16.h,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            AutoSizeText(
                                                              "${indexes[index] + 1} - $data",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge,
                                                            ),
                                                            Spacer(),
                                                            Icon(Icons.close)
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Material(
                                                    color: color,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                    elevation: 0,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 16,
                                                          vertical: 16),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "${indexes[index] + 1} -",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge,
                                                          ),
                                                          Spacer(),
                                                          Opacity(
                                                              opacity:
                                                                  data != null
                                                                      ? 1
                                                                      : 0,
                                                              child: Icon(
                                                                  Icons.close))
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                          },
                                        ),
                                      ),
                                    ),
                                  ))),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Material(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.w)),
                        elevation: 0,
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: EdgeInsets.all(8.0.w),
                          child: Column(
                            children: [
                              ...List.generate(
                                  (values.length / 3).ceil(),
                                  (index) => Row(
                                        children: [
                                          ...List.generate(3, (i) {
                                            var itemIndex = (index * 3) + (i);
                                            String? value = values[itemIndex];
                                            return Expanded(
                                              child: value == null
                                                  ? SizedBox()
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: DraggableItem(
                                                        onDragStarted: () {
                                                          if (message
                                                              .isNotEmpty) {
                                                            setState(() {
                                                              color =
                                                                  WalletTheme
                                                                      .instance
                                                                      .primary;
                                                              message = "";
                                                            });
                                                          }
                                                        },
                                                        value: value,
                                                        index: itemIndex,
                                                      ),
                                                    ),
                                            );
                                          })
                                        ],
                                      )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        message,
                        style: TextStyle(
                          color: color!,
                        ),
                      ),
                    ),
                  ],
                )),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const Spacer(),
                      SafeArea(
                        top: false,
                        bottom: true,
                        minimum: EdgeInsets.only(
                            left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
                        child: Hero(
                          tag: "Button",
                          child: OutlinedButton(
                            child: Text("next".tr()),
                            onPressed: () {
                              var isValid = mnemonic[indexes[0]] ==
                                      _data[0]?["value"] &&
                                  mnemonic[indexes[1]] == _data[1]?["value"];
                              if (!isValid) {
                                setState(() {
                                  color = Color.fromARGB(255, 245, 120, 111);
                                  message = "mnemonicIncorrect".tr();
                                });
                                return;
                              }
                              widget.bloc.add(
                                  SaveWalletToDatabase(wallet: widget.wallet));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
