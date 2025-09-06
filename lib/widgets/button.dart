import 'package:flutter/material.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/icon_config.dart';

enum IconPosition { left, right }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final String? svgIconPath;
  final IconPosition iconPosition;
  final double? iconStrokeWidth;
  final bool isFullWidth;
  final double? widthPercent;
  final double borderRadius;
  final bool secondary;
  final bool danger;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.svgIconPath,
    this.iconPosition = IconPosition.right,
    this.iconStrokeWidth = 1.5,
    this.isFullWidth = false,
    this.widthPercent,
    this.borderRadius = 8.0,
    this.secondary = false,
    this.danger = false,
    this.isLoading = false,
  }) : assert(
         widthPercent == null || (widthPercent > 0 && widthPercent <= 1),
         'widthPercent deve estar entre 0.0 e 1.0',
       );

  Color get _backgroundColor {
    if (secondary) {
      if (danger) return deleteRedLight;
      return brandBlueLight;
    }
    if (danger) return deleteRed;
    return brandBlue;
  }

  Color get _contentColor {
    if (secondary) {
      if (danger) return deleteRed;
      return brandBlue;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      elevation: WidgetStateProperty.all(0),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return _backgroundColor.withAlpha(180);
        }
        return _backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.all(_contentColor),
      overlayColor: WidgetStateProperty.all(const Color.fromARGB(40, 0, 0, 0)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide.none,
        ),
      ),
    );

    final buttonWidget = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: isLoading ? _buildLoadingIndicator() : _buildButtonContent(),
    );

    if (widthPercent != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth * widthPercent!,
            child: buttonWidget,
          );
        },
      );
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }

    return buttonWidget;
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        color: _contentColor,
        strokeWidth: 2.5,
      ),
    );
  }

  Widget _buildButtonContent() {
    if (svgIconPath == null) {
      return Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      );
    }

    List<Widget> children = [
      IconConfig(
        assetPath: svgIconPath!,
        color: _contentColor,
        width: 24,
        strokeWidth: iconStrokeWidth,
      ),
      const SizedBox(width: 12),
      Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ];

    if (iconPosition == IconPosition.right) {
      children = children.reversed.toList();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
