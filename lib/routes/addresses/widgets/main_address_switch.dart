import 'package:flutter/material.dart';

class MainAddressSwitch extends StatefulWidget {
  const MainAddressSwitch({super.key});

  @override
  State<MainAddressSwitch> createState() => MainAddressSwitchState();
}

class MainAddressSwitchState extends State<MainAddressSwitch> {
  late bool _switch;

  @override
  void initState() {
    _switch = false;
    super.initState();
  }

  bool get value => _switch;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
        value: _switch,
        onChanged: (value) {
          setState(() {
            _switch = !_switch;
          });
        });
  }
}
