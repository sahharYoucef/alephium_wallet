import 'dart:math';

import 'package:alephium_wallet/bloc/create_wallet/create_wallet_bloc.dart';
import 'package:alephium_wallet/routes/mnemonic_verify/widgets/draggable_item.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    mnemonic = widget.wallet.mnemonic.split(" ").toList();
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
    indexes.add(1);
    indexes.add(5);
    // indexes.add(random.nextInt(24));
    // late int newIndex;
    // do {
    //   newIndex = random.nextInt(24);
    // } while (newIndex == indexes[0]);
    // indexes.add(newIndex);
    indexes.sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WalletAppBar(
            label: Text(
              'Verify Mnemonic',
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
                      padding: const EdgeInsets.only(
                          top: 16, left: 16, right: 16, bottom: 4),
                      child: Text(
                        "Please put the correspondent word to the index.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    ...List.generate(
                        2,
                        ((index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
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
                                builder:
                                    (context, candidateData, rejectedData) {
                                  String? data = _data[index]?["value"];
                                  return data != null
                                      ? Material(
                                          color: color,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          elevation: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (_data[index] != null) {
                                                values[_data[index]["index"]] =
                                                    _data[index]["value"];
                                                _data[index] = null;
                                              }
                                              if (message.isNotEmpty) {
                                                color = WalletTheme
                                                    .instance.primary;
                                                message = "";
                                              }
                                              setState(() {});
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 16),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "${indexes[index] + 1} - $data",
                                                    style: Theme.of(context)
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
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          elevation: 0,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 16),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "${indexes[index] + 1} -",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                ),
                                                Spacer(),
                                                Opacity(
                                                    opacity:
                                                        data != null ? 1 : 0,
                                                    child: Icon(Icons.close))
                                              ],
                                            ),
                                          ),
                                        );
                                },
                              ),
                            ))),
                    const SizedBox(
                      height: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Material(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        color: Theme.of(context).primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Reorder the words to verify the mnemonic",
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Hero(
                          tag: "Button",
                          child: OutlinedButton(
                            child: Text("Next"),
                            onPressed: () {
                              var isValid = mnemonic[indexes[0]] ==
                                      _data[0]?["value"] &&
                                  mnemonic[indexes[1]] == _data[1]?["value"];
                              if (!isValid) {
                                setState(() {
                                  color = Color.fromARGB(255, 245, 120, 111);
                                  message = "The mnemonic is not correct";
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
