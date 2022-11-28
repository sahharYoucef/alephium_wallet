import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;

class CircleNavigationBar extends StatelessWidget {
  final double navbarHeight;
  final Color navBarColor;
  final List<Widget> navBarIcons;
  final Color navBarUnselectedIconsColor;
  final Color navBarSelectedIconsColor;
  final Color circleIconsColor;
  final double margin;
  final BorderRadius? borderRadius;
  final TabController? tabController;
  final void Function() onTap;

  const CircleNavigationBar(
      {Key? key,
      this.navbarHeight = 80,
      this.tabController,
      required this.navBarIcons,
      required this.onTap,
      this.navBarUnselectedIconsColor = const Color(0xff9d9fa1),
      this.navBarSelectedIconsColor = const Color(0xff000000),
      this.circleIconsColor = const Color(0xff9d9fa1),
      this.margin = 16.0,
      this.borderRadius,
      this.navBarColor = Colors.white})
      : super(key: key);
  final double height = 185;
  final double navBarHeight = 80;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: WalletTheme.instance.maxWidth,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: margin),
        child: SizedBox(
          height: navbarHeight,
          width: double.infinity,
          child: Material(
              elevation: 2,
              shadowColor: WalletTheme.instance.gradientOne,
              color: navBarColor,
              borderRadius: borderRadius,
              child: Row(
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
                        ...List.generate(3, (index) {
                          return navBarIcons[index];
                        }),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: navBarIcons[3],
                  ),
                ],
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
