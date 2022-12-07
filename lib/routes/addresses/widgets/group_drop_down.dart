import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class GroupDropDown extends StatefulWidget {
  const GroupDropDown({
    super.key,
  });

  @override
  State<GroupDropDown> createState() => GroupDropDownState();
}

class GroupDropDownState extends State<GroupDropDown> {
  late int _group;
  @override
  void initState() {
    _group = 1;
    super.initState();
  }

  int get value => _group;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<int>(
        alignment: AlignmentDirectional.bottomEnd,
        elevation: 3,
        dropdownColor: WalletTheme.instance.dropDownBackground,
        borderRadius: BorderRadius.circular(16),
        decoration: InputDecoration(
          labelStyle: Theme.of(context).textTheme.bodyMedium!,
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
                      "${'group'.tr()} $index",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              )
              .toList()
        ],
      ),
    );
  }
}
