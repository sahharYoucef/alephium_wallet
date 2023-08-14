import 'package:alephium_wallet/bloc/settings/settings_bloc.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircleNavigationBar extends StatelessWidget {
  final List<Widget> navBarIcons;
  final Color navBarUnselectedIconsColor;
  final Color navBarSelectedIconsColor;
  final Color circleIconsColor;
  final BorderRadius? borderRadius;
  final TabController? tabController;

  const CircleNavigationBar({
    Key? key,
    this.tabController,
    required this.navBarIcons,
    this.navBarUnselectedIconsColor = const Color(0xff9d9fa1),
    this.navBarSelectedIconsColor = const Color(0xff000000),
    this.circleIconsColor = const Color(0xff9d9fa1),
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsBloc>();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: WalletTheme.instance.maxWidth,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w),
        child: SizedBox(
          height: 80.h + context.bottomPadding,
          width: double.infinity,
          child: PhysicalModel(
              elevation: 2,
              shadowColor: WalletTheme.instance.gradientOne,
              color: WalletTheme.instance.primary,
              borderRadius: borderRadius,
              child: Padding(
                padding: EdgeInsets.only(bottom: context.bottomPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TabBar(
                        controller: tabController,
                        indicatorColor: Colors.transparent,
                        unselectedLabelColor: navBarUnselectedIconsColor,
                        labelColor: navBarSelectedIconsColor,
                        indicatorSize: TabBarIndicatorSize.tab,
                        splashBorderRadius: borderRadius,
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return WalletTheme.instance.background
                                  .withOpacity(.9);
                            return null;
                          },
                        ),
                        tabs: <Widget>[
                          ...List.generate(4, (index) {
                            return navBarIcons[index];
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final void Function() onTap;
  final Color color;
  final String tooltip;
  const AddButton({
    Key? key,
    required this.tooltip,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "button",
      tooltip: tooltip,
      onPressed: onTap,
      elevation: 2,
      backgroundColor: color,
      shape: CustomBorder(color),
      child: Icon(
        Icons.add,
        size: 50,
      ),
    );
  }
}

class CustomBorder extends ShapeBorder {
  final Color color;

  CustomBorder(this.color);
  @override
  EdgeInsetsGeometry get dimensions => throw UnimplementedError();

  Path _customBorderPath(Rect rect) {
    return Path()
      ..addPolygon([
        Offset(rect.width * 0.5, 0.0),
        Offset(rect.width * 0.0669875, rect.height * 0.25),
        Offset(rect.width * 0.0669875, rect.height * 0.75),
        Offset(rect.width * 0.5, rect.height),
        Offset(rect.width * 0.9330125, rect.height * 0.75),
        Offset(rect.width * 0.9330125, rect.height * 0.25),
      ], true);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _customBorderPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _customBorderPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    Path path = _customBorderPath(rect);

    Paint hexagonPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..drawPath(path, hexagonPaint)
      ..drawPath(
          path,
          hexagonPaint
            ..style = PaintingStyle.fill
            ..color = Colors.transparent);
  }

  @override
  ShapeBorder scale(double t) {
    throw UnimplementedError();
  }
}

class CustomIcon {
  final String tooltip;
  final IconData icon;
  void Function() onPressed;

  CustomIcon(
      {required this.tooltip, required this.icon, required this.onPressed});
}
