import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sistema_almox/core/constants/system_constants.dart';
import 'package:sistema_almox/core/theme/colors.dart';
import 'package:sistema_almox/widgets/shimmer_placeholder.dart';

class DetailItemCard extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? valueColor;
  final Widget? icon;
  final bool copyButton;

  const DetailItemCard({
    super.key,
    required this.label,
    required this.value,
    this.onPressed,
    this.isLoading = false,
    this.valueColor,
    this.icon,
    this.copyButton = false,
  });

  @override
  State<DetailItemCard> createState() => _DetailItemCardState();
}

class _DetailItemCardState extends State<DetailItemCard> {
  bool _isCopied = false;

  void _handleCopyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.value));

    setState(() {
      _isCopied = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return ShimmerPlaceholder(
        height: SystemConstants.alturaCardModal.toDouble(),
      );
    }

    final bool isSimpleClickable = widget.onPressed != null && !widget.copyButton;

    final mainContent = _buildRealContent(isSimpleClickable);

    if (widget.copyButton) {
      return Stack(
        alignment: Alignment.center,
        children: [
          InkWell(
            onTap: _handleCopyToClipboard,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 40, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: mainContent,
            ),
          ),
          Positioned(
            right: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: _isCopied
                  ? const Icon(
                      key: ValueKey('check_icon'),
                      Icons.check,
                      color: successGreen,
                      size: 20,
                    )
                  : const Icon(
                      key: ValueKey('copy_icon'),
                      Icons.copy_rounded,
                      color: text60,
                      size: 18,
                    ),
            ),
          ),
        ],
      );
    }

    if (isSimpleClickable) {
      return InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFBFB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: mainContent,
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: mainContent,
    );
  }

  Widget _buildRealContent(bool isClickable) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: text80,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.value,
                    style: TextStyle(
                      color: widget.valueColor ?? text40,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.icon != null) ...[
                    const SizedBox(width: 2),
                    widget.icon!,
                  ]
                ],
              ),
            ],
          ),
        ),
        if (isClickable)
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: text40,
            ),
          ),
      ],
    );
  }
}