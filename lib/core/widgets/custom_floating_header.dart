import 'package:flutter/material.dart';

class CustomFloatingHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget? titleWidget;
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomWidget;
  final double bottomHeight;

  const CustomFloatingHeader({
    super.key,
    this.titleWidget,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.bottomWidget,
    this.bottomHeight = 0,
  });

  @override
  Size get preferredSize => Size.fromHeight(78 + bottomHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton && canPop;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (leading != null)
                    leading!
                  else if (shouldShowBack)
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  if (leading != null || shouldShowBack)
                    const SizedBox(width: 12),
                  Expanded(
                    child: titleWidget ??
                        Text(
                          title ?? '',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
              if (bottomWidget != null) ...[
                const SizedBox(height: 8),
                bottomWidget!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
