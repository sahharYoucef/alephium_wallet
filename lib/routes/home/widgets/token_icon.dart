import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TokenIcon extends StatelessWidget {
  final TokenStore tokenStore;
  final double size;
  final TextStyle? textStyle;
  const TokenIcon({
    Key? key,
    required this.tokenStore,
    this.size = 30,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final symbol = tokenStore.symbol!.substring(0, 2);
    final errorHolder = Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HexColor.fromHex(getColor(tokenStore.metaData?.name)),
      ),
      alignment: Alignment.center,
      child: Text(
        symbol,
        style: textStyle ??
            Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: size / 2),
      ),
    );
    if (tokenStore.logo != null) {
      return CachedNetworkImage(
        height: size,
        width: size,
        imageUrl: tokenStore.logo!,
        errorWidget: (context, url, error) => errorHolder,
      );
    } else if (tokenStore.symbol != null) {
      return errorHolder;
    } else {
      return SizedBox.shrink();
    }
  }
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
