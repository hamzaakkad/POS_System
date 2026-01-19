import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/theme_provider.dart';
import 'AppColors.dart';

class SubtleHoverDelete extends StatefulWidget {
  final Widget child;
  final VoidCallback onArchive;

  const SubtleHoverDelete({
    super.key,
    required this.child,
    required this.onArchive,
  });

  @override
  State<SubtleHoverDelete> createState() => _SubtleHoverDeleteState();
}

class _SubtleHoverDeleteState extends State<SubtleHoverDelete>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 250ms makes the vibration feel calm rather than frantic
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool hovering) {
    setState(() => _isHovering = hovering);
    if (hovering) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark; //MARK: FINAL

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      cursor: SystemMouseCursors.click,
      child: Stack(
        // IMPORTANT: fit: StackFit.expand prevents your GridView items from collapsing
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          // 1. The Shake & Lift Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Extremely small horizontal movement (1.5 pixels)
              double horizontalShake =
                  math.sin(_controller.value * math.pi * 0) *
                  0; // set 2) * 1.5 for shake

              return Transform.translate(
                // Very slight lift (-2.0) when hovering to show it is active
                offset: Offset(horizontalShake, _isHovering ? -2.0 : 0),
                child: child,
              );
            },
            child: widget.child,
          ),

          // 2. The Delete Button (Top Right)
          Positioned(
            top: 1,
            right: 4,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _isHovering ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !_isHovering,

                child: Tooltip(
                  message: "Archive",
                  waitDuration: const Duration(milliseconds: 200),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return AlertDialog(
                            //   title: const Text('Archive Item?'),
                            //   content: const Text(
                            //     'Are you sure you want to archive this item?\nitem wont be shown in the list but it will stay in the orders list',
                            //   ),
                            //   actions: [
                            //     TextButton(
                            //       onPressed: () => Navigator.of(context).pop(),
                            //       child: const Text('Cancel'),
                            //     ),
                            //     TextButton(
                            //       onPressed: () {
                            //         Navigator.of(context).pop();
                            //         widget.onArchive();
                            //       },
                            //       child: const Text('Archive'),
                            //     ),
                            //   ],
                            // );
                            return Dialog(
                              backgroundColor: isDark
                                  ? AppColors.darkBgElevated
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Archive Item?',
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Are you sure you want to archive this item?\nItem won\'t be shown in the list but it will stay in the orders list.',
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            widget.onArchive();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDark
                                                ? AppColors.darkButtonsPrimary
                                                : AppColors.accentBlue,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Archive',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),

                        decoration: BoxDecoration(
                          color: Colors.transparent,

                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.transparent,
                              blurRadius: 4,

                              offset: Offset(0, 2),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.archive_outlined,
                          color: Color.fromARGB(255, 114, 114, 114),
                          //Colors.black54,//#0277FA
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
