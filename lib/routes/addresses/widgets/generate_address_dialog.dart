import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum GenerationType { single, group }

class GenerateWalletDialog extends StatefulWidget {
  final WalletDetailsBloc bloc;
  final GenerationType type;
  GenerateWalletDialog({
    Key? key,
    required this.bloc,
    required this.type,
  }) : super(key: key);

  @override
  State<GenerateWalletDialog> createState() => _GenerateWalletDialogState();
}

class _GenerateWalletDialogState extends State<GenerateWalletDialog> {
  late int _group;
  late bool _switch;
  late TextEditingController _controller;

  @override
  void initState() {
    _group = 1;
    _switch = false;
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: MediaQuery.of(context).viewInsets,
        width: MediaQuery.of(context).size.width * .70,
        child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(16.0),
            color: Color.fromARGB(255, 240, 240, 240),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.type == GenerationType.single
                              ? "Main address"
                              : "Generate one address per group",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      if (widget.type == GenerationType.single)
                        Switch.adaptive(
                            value: _switch,
                            onChanged: (value) {
                              setState(() {
                                _switch = !_switch;
                              });
                            })
                    ],
                  ),
                  if (widget.type == GenerationType.single) ...[
                    Text(
                      "Default address for sending transactions. Note that if activated, \"${widget.bloc.wallet.mainAddress.substring(0, 10)}...\" will not be the main address anymore.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      label: Text("Title"),
                      labelStyle: Theme.of(context).textTheme.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (widget.type == GenerationType.single) ...[
                    ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButtonFormField<int>(
                        alignment: AlignmentDirectional.bottomEnd,
                        elevation: 3,
                        borderRadius: BorderRadius.circular(16),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _group = value!;
                          });
                        },
                        value: _group,
                        items: [
                          ...List.generate(4, (index) => index)
                              .map(
                                (index) => DropdownMenuItem<int>(
                                  value: index,
                                  child: SizedBox(
                                    width: 100,
                                    child: Text(
                                      "Group $index",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ),
                              )
                              .toList()
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                  OutlinedButton(
                    onPressed: () {
                      if (widget.type == GenerationType.single)
                        widget.bloc.add(GenerateNewAddress(
                          isMain: _switch,
                          title: _controller.text,
                          color: "",
                          group: _group,
                        ));
                      else
                        widget.bloc.add(GenerateOneAddressPerGroup(
                          title: _controller.text,
                          color: "",
                        ));
                      Navigator.pop(context);
                    },
                    child: Text(
                      widget.type == GenerationType.single
                          ? "Generate Address"
                          : "Generate",
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
