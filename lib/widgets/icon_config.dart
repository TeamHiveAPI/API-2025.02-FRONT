import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

class IconConfig extends StatelessWidget {
  final String assetPath;
  final Color color;
  final double width;
  final double? strokeWidth;

  const IconConfig({
    super.key,
    required this.assetPath,
    required this.color,
    required this.width,
    required this.strokeWidth,
  });

  Future<String> _getModifiedSvgString() async {

    final String originalSvg = await rootBundle.loadString(assetPath);
    final RegExp strokeWidthRegex = RegExp('stroke-width=".*?"');
    final String modifiedSvg = originalSvg.replaceFirst(
      strokeWidthRegex,
      'stroke-width="$strokeWidth"',
    );

    return modifiedSvg;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getModifiedSvgString(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(width: width, height: width);
        }
        if (snapshot.hasData) {
          return SvgPicture.string(
            snapshot.data!,
            width: width,
            height: width,
            colorFilter: ColorFilter.mode(
              color,
              BlendMode.srcIn,
            ),
          );
        }
        return SizedBox(width: width, height: width);
      },
    );
  }
}