import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';

class CircleNavigationBar extends StatelessWidget {
  final double navbarHeight;
  final Color navBarColor;
  final List<CustomIcon> navBarIcons;
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
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: margin),
              child: SizedBox(
                height: navbarHeight,
                width: constraints.maxWidth,
                child: Material(
                    elevation: 2,
                    shadowColor: WalletTheme.instance.gradientOne,
                    color: navBarColor,
                    borderRadius: borderRadius,
                    child: TabBar(
                      controller: tabController,
                      indicatorColor: Colors.transparent,
                      unselectedLabelColor: navBarUnselectedIconsColor,
                      labelColor: navBarSelectedIconsColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: <Widget>[
                        ...List.generate(navBarIcons.length, (index) {
                          return Icon(
                            navBarIcons[index].icon,
                          );
                        })
                      ],
                    )),
              ),
            ),
          ),
          Positioned(
            bottom: navBarHeight - 50,
            child: AddButton(
              onTap: onTap,
              color: circleIconsColor,
            ),
          ),
        ],
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final void Function() onTap;
  final Color color;
  const AddButton({
    Key? key,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "button",
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
    // TODO: implement scale
    throw UnimplementedError();
  }
}

class CustomIcon {
  IconData icon;
  void Function() onPressed;

  CustomIcon({required this.icon, required this.onPressed});
}
