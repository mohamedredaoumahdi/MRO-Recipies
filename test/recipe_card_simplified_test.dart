// test/recipe_card_simplified_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SimpleRecipeCard extends StatelessWidget {
  final String title;
  final String category;
  final String difficulty;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const SimpleRecipeCard({
    Key? key,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.favorite : Icons.favorite_border,
                    color: isBookmarked ? Colors.red : null,
                  ),
                  onPressed: onBookmarkTap,
                ),
              ],
            ),
            Text('Category: $category'),
            Text('Difficulty: $difficulty'),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('SimpleRecipeCard displays content correctly', (WidgetTester tester) async {
    bool tapped = false;
    bool bookmarkTapped = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SimpleRecipeCard(
            title: 'Moroccan Tagine',
            category: 'Dinner',
            difficulty: 'Medium',
            isBookmarked: false,
            onTap: () {
              tapped = true;
            },
            onBookmarkTap: () {
              bookmarkTapped = true;
            },
          ),
        ),
      ),
    );
    
    // Verify content is displayed
    expect(find.text('Moroccan Tagine'), findsOneWidget);
    expect(find.text('Category: Dinner'), findsOneWidget);
    expect(find.text('Difficulty: Medium'), findsOneWidget);
    
    // Verify bookmark icon is displayed
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    
    // Tap the card
    await tester.tap(find.ancestor(
      of: find.text('Moroccan Tagine'),
      matching: find.byType(GestureDetector),
    ));
    expect(tapped, true);
    
    // Tap the bookmark icon
    await tester.tap(find.byType(IconButton));
    expect(bookmarkTapped, true);
  });
  
  testWidgets('SimpleRecipeCard shows bookmarked state correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SimpleRecipeCard(
            title: 'Moroccan Couscous',
            category: 'Lunch',
            difficulty: 'Easy',
            isBookmarked: true,
            onTap: () {},
            onBookmarkTap: () {},
          ),
        ),
      ),
    );
    
    // Verify bookmarked icon is displayed
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}