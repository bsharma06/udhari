import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({super.key});

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool _isExpanded = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: 44,
      width: _isExpanded ? screenWidth * 0.55 : 44,
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(80),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // Search icon button (toggler)
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
              if (_isExpanded) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  FocusScope.of(context).requestFocus(_focusNode);
                });
              } else {
                _focusNode.unfocus();
                _controller.clear();
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(Icons.search, size: 22),
            ),
          ),

          // Animated text field (fades and expands)
          if (_isExpanded)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),

          // Close icon (only when expanded and has text)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: (_isExpanded && _controller.text.isNotEmpty)
                ? IconButton(
                    key: const ValueKey("close"),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                    },
                  )
                : const SizedBox(width: 0, height: 0),
          ),
        ],
      ),
    );
  }
}
