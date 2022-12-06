import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageDropDown extends StatelessWidget {
  const LanguageDropDown({super.key});

  @override
  Widget build(BuildContext context) {
    final _languages = {
      "system": "",
      "en": "English",
      "fr": "Français",
      "es": "Español",
      "it": "Italiano"
    };
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<String>(
        menuMaxHeight: context.height / 2,
        dropdownColor: WalletTheme.instance.dropDownBackground,
        alignment: AlignmentDirectional.bottomEnd,
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        isExpanded: true,
        onChanged: (value) async {
          if (value == "system") {
            EasyLocalization.of(context)!
                .setLocale(Locale(context.deviceLocale.languageCode));
          } else {
            EasyLocalization.of(context)!.setLocale(Locale(value!));
          }
          AppStorage.instance.language = value;
        },
        decoration: InputDecoration(
          label: Text(
            "language".tr(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        value: AppStorage.instance.language,
        items: [
          ..._languages
              .map(
                (key, value) => MapEntry(
                    key,
                    DropdownMenuItem<String>(
                      value: key,
                      child: Row(
                        children: [
                          Text(
                            "${key.tr()}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Spacer(),
                          Text(
                            "${(key == context.locale.languageCode || key == "system") ? '' : '($value)'}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color!
                                        .withOpacity(.5)),
                          )
                        ],
                      ),
                    )),
              )
              .values
              .toList()
        ],
      ),
    );
  }
}
