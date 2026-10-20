import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  final ValueChanged<String>? onCategorySelected;

  const CategorySelector({
    super.key,
    this.onCategorySelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int _selectedIndex = 0;

  // Ajustado a las categorías visibles en tu pantalla
  final List<String> _categories = [
    'Todos',
    'Espresso',
    'Capuchino',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedIndex == index;

          return Expanded(
            child: Padding(
              // Control de separación entre botones
              padding: EdgeInsets.only(
                right: index == _categories.length - 1 ? 0 : 12,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    if (widget.onCategorySelected != null) {
                      widget.onCategorySelected!(_categories[index]);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFC88D51) : const Color(0xFF26221F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _categories[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}