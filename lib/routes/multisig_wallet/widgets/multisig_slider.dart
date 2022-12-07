import 'package:alephium_wallet/routes/send/widgets/shake_form_field.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class MultisigSlider extends StatefulWidget {
  final void Function(int, int) onChanged;

  const MultisigSlider({
    super.key,
    required this.onChanged,
  });

  @override
  State<MultisigSlider> createState() => _MultisigSliderState();
}

class _MultisigSliderState extends State<MultisigSlider> {
  int wallets = 0;
  int required = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalletTheme.instance.background,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "selectNofSigners".tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 10,
          ),
          Material(
            color: WalletTheme.instance.buttonsBackground,
            borderRadius: BorderRadius.circular(12),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: CustomSliderThumbCircle(
                  thumbRadius: 15,
                  min: 0,
                  max: 5,
                ),
                trackHeight: 10.0,
                activeTrackColor:
                    WalletTheme.instance.disabledButtonsBackground,
                inactiveTrackColor: WalletTheme
                    .instance.disabledButtonsBackground
                    .withOpacity(.5),
                overlayColor:
                    WalletTheme.instance.buttonsForeground.withOpacity(.4),
                activeTickMarkColor:
                    WalletTheme.instance.disabledButtonsBackground,
                inactiveTickMarkColor: WalletTheme
                    .instance.disabledButtonsBackground
                    .withOpacity(.5),
              ),
              child: Slider(
                label: wallets.toString(),
                min: 0,
                max: 5,
                value: wallets.toDouble(),
                onChanged: (value) {
                  wallets = value.toInt();
                  if (wallets < required) {
                    required = wallets;
                  }
                  setState(() {});
                  widget.onChanged(wallets, required);
                },
                divisions: 5,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "selectNofRequiredSigners".tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 10,
          ),
          Material(
            color: WalletTheme.instance.buttonsBackground,
            borderRadius: BorderRadius.circular(12),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: CustomSliderThumbCircle(
                  thumbRadius: 15,
                  min: 0,
                  max: wallets.toDouble().clamp(1, 5).toInt(),
                ),
                trackHeight: 10.0,
                activeTrackColor:
                    WalletTheme.instance.disabledButtonsBackground,
                inactiveTrackColor: WalletTheme
                    .instance.disabledButtonsBackground
                    .withOpacity(.5),
                overlayColor:
                    WalletTheme.instance.buttonsForeground.withOpacity(.4),
                activeTickMarkColor:
                    WalletTheme.instance.disabledButtonsBackground,
                inactiveTickMarkColor: WalletTheme
                    .instance.disabledButtonsBackground
                    .withOpacity(.5),
              ),
              child: Slider(
                label: required.toString(),
                min: 0,
                max: wallets.toDouble().clamp(1, 5),
                value: required.toDouble(),
                onChanged: wallets == 0
                    ? null
                    : (value) {
                        required = value.toInt();
                        setState(() {});
                        widget.onChanged(wallets, required);
                      },
                divisions: wallets.clamp(1, 5),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

class MultisigSlidersFormField extends ShakeFormField<Tuple2<int, int>> {
  MultisigSlidersFormField({
    super.key,
    super.autovalidateMode,
    super.enabled,
    super.errorStyle,
    super.onSaved,
    void Function(Tuple2<int, int>)? onChanged,
    FormFieldValidator<Tuple2<int, int>>? validator,
  }) : super(
          validator: validator,
          builder: (ShakeFormFieldState<Tuple2<int, int>> state) {
            return MultisigSlider(
              onChanged: (p0, p1) {
                if (onChanged != null) onChanged(Tuple2<int, int>(p0, p1));
                state.didChange(Tuple2<int, int>(p0, p1));
              },
            );
          },
        );
}

class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final int min;
  final int max;

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 0,
    this.max = 10,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    required double value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = Colors.white //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span = new TextSpan(
      style: new TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: sliderTheme?.thumbColor, //Text Color of Value on Thumb
      ),
      text: getValue(value),
    );

    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min + (max - min) * value).round().toString();
  }
}
