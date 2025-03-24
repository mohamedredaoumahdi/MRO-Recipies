// test/recipe_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SimpleRecipeForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  
  const SimpleRecipeForm({Key? key, required this.onSubmit}) : super(key: key);
  
  @override
  _SimpleRecipeFormState createState() => _SimpleRecipeFormState();
}

class _SimpleRecipeFormState extends State<SimpleRecipeForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _prepTimeController,
            decoration: InputDecoration(labelText: 'Prep Time (minutes)'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter prep time';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'prepTime': int.parse(_prepTimeController.text),
                });
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Recipe form validation test', (WidgetTester tester) async {
    Map<String, dynamic>? submittedData;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SimpleRecipeForm(
            onSubmit: (data) {
              submittedData = data;
            },
          ),
        ),
      ),
    );
    
    // Try submitting empty form
    await tester.tap(find.text('Submit'));
    await tester.pump();
    
    // Verify validation errors
    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.text('Please enter a description'), findsOneWidget);
    expect(find.text('Please enter prep time'), findsOneWidget);
    
    // Fill in invalid prep time
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Recipe');
    await tester.enterText(find.byType(TextFormField).at(1), 'A test recipe');
    await tester.enterText(find.byType(TextFormField).at(2), 'not-a-number');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    
    // Verify number validation error
    expect(find.text('Please enter a valid number'), findsOneWidget);
    
    // Fill form correctly
    await tester.enterText(find.byType(TextFormField).at(2), '30');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    
    // Verify form submitted with correct data
    expect(submittedData, isNotNull);
    expect(submittedData!['title'], 'Test Recipe');
    expect(submittedData!['description'], 'A test recipe');
    expect(submittedData!['prepTime'], 30);
  });
}