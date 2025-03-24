import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple category chip widget for testing
class SimpleCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(String) onSelected;

  const SimpleCategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('SimpleCategoryChip works correctly', (WidgetTester tester) async {
    String selectedCategory = '';
    bool isSelected = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SimpleCategoryChip(
              label: 'Breakfast',
              isSelected: isSelected,
              onSelected: (category) {
                selectedCategory = category;
                isSelected = true;
              },
            ),
          ),
        ),
      ),
    );
    
    // Verify the chip shows the correct label
    expect(find.text('Breakfast'), findsOneWidget);
    
    // Tap on the chip
    await tester.tap(find.byType(SimpleCategoryChip));
    await tester.pump();
    
    // Verify that the callback was called with correct value
    expect(selectedCategory, 'Breakfast');
  });
}