import 'package:flutter/material.dart';

class ExploreSearchBar extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const ExploreSearchBar({
    Key? key,
    required this.isExpanded,
    required this.onTap,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 16),
                Expanded(
                  child: isExpanded
                    ? TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search places...',
                          border: InputBorder.none,
                        ),
                        autofocus: true,
                      )
                    : const Text(
                        'Search places...',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                ),
                if (isExpanded)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
