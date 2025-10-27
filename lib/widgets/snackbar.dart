import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sistema_almox/core/theme/colors.dart';

void showCustomSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  final animationKey = GlobalKey<_CustomSnackbarAnimationState>();
  OverlayEntry? overlayEntry;

  void closeSnackbar() {
    animationKey.currentState?.close();
  }

  overlayEntry = OverlayEntry(
    builder: (context) {
      return _CustomSnackbarAnimation(
        key: animationKey,
        duration: duration,
        onDismissed: () {
          overlayEntry?.remove();
          overlayEntry = null;
        },
        builder: (context, progressAnimation) {
          return SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 10, 3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            right: 8.0,
                            top: 10.0,
                            bottom: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: isError ? deleteRed : successGreen,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                isError
                                    ? 'assets/icons/warning.svg'
                                    : 'assets/icons/success.svg',
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  message,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: closeSnackbar,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedBuilder(
                            animation: progressAnimation,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: progressAnimation.value,
                                backgroundColor: Colors.white.withAlpha(0),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withAlpha(200),
                                ),
                                minHeight: 3,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  Overlay.of(context).insert(overlayEntry!);
}

class _CustomSnackbarAnimation extends StatefulWidget {
  final Widget Function(BuildContext context, Animation<double> progress)
  builder;
  final Duration duration;
  final VoidCallback onDismissed;

  const _CustomSnackbarAnimation({
    super.key,
    required this.builder,
    required this.duration,
    required this.onDismissed,
  });

  @override
  _CustomSnackbarAnimationState createState() =>
      _CustomSnackbarAnimationState();
}

class _CustomSnackbarAnimationState extends State<_CustomSnackbarAnimation>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late Animation<Offset> _offsetAnimation;
  late AnimationController _progressController;

  void close() {
    if (mounted) {
      _progressController.stop();
      _moveController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final curve = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOutCubic,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, -0.01),
    ).animate(curve);

    _moveController.forward();
    _progressController.reverse(from: 1.0);

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        close();
      }
    });

    _moveController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.builder(context, _progressController),
    );
  }
}
