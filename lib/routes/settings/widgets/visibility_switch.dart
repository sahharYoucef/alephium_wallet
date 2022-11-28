import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class VisibilitySwitch extends StatefulWidget {
  @override
  State<VisibilitySwitch> createState() => _VisibilitySwitchState();
}

class _VisibilitySwitchState extends State<VisibilitySwitch> {
  late bool isObscure;
  @override
  void initState() {
    isObscure = AppStorage.instance.visibility;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "discreetMode".tr(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Spacer(),
        IconButton(
          icon: isObscure
              ? GradientIcon(icon: Icons.visibility)
              : GradientIcon(icon: Icons.visibility_off),
          onPressed: () {
            isObscure = !isObscure;
            AppStorage.instance.visibility = isObscure;
            setState(() {});
          },
        )
      ],
    );
  }
}
