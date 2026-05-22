import 'package:flutter/material.dart';

class ReusableDropdownMenu extends StatefulWidget {
  final List<DropdownMenuItemData> items;
  final String title;

  const ReusableDropdownMenu({
    super.key,
    required this.items,
    required this.title,
  });

  @override
  State<ReusableDropdownMenu> createState() => _ReusableDropdownMenuState();
}

class _ReusableDropdownMenuState extends State<ReusableDropdownMenu> {
  bool _expanded = false;

  void toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100], // Slightly different white shade
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          InkWell(
            onTap: toggleExpanded,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          if (_expanded)
            Column(
              children:
                  widget.items
                      .map(
                        (item) => ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 2,
                          ),
                          onTap: item.onTap,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.label,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
        ],
      ),
    );
  }
}

class DropdownMenuItemData {
  final String label;
  final VoidCallback onTap;

  DropdownMenuItemData({required this.label, required this.onTap});
}
