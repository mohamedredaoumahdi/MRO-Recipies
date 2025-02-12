import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:moroccan_recipies_app/models/recipe.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import '../service/recipe_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final RecipeService _recipeService = RecipeService();
  File? _imageFile;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Breakfast';
  final List<String> _ingredients = [];
  final List<String> _steps = [];
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  String _selectedDifficulty = 'Easy';
  final _caloriesController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      // Show info dialog first
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Image Guidelines', style: AppTextStyles.heading2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please note:',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '• Image size must be under 1MB\n'
                '• Prefer simple, clear photos\n'
                '• Landscape orientation works best\n'
                '• The image will be automatically compressed',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                  maxWidth: 1200,
                  maxHeight: 1200,
                );
                
                if (image != null) {
                  // Check file size
                  final File file = File(image.path);
                  final int fileSize = await file.length();
                  final double fileSizeInMB = fileSize / (1024 * 1024); // Convert to MB

                  if (fileSizeInMB > 1.0) {
                    // Show error if file is too large
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Image size (${fileSizeInMB.toStringAsFixed(1)}MB) exceeds 1MB limit. Please choose a smaller image.',
                        ),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  } else {
                    // File size is acceptable
                    setState(() {
                      _imageFile = file;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Image size: ${fileSizeInMB.toStringAsFixed(1)}MB',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
              ),
              child: const Text('Choose Image'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking image. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
        backgroundColor: AppColors.primary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 40, color: AppColors.primary),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Add Photo (Max 1MB)',
                              style: AppTextStyles.bodyMedium),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Recipe Title',
                hintText: 'Enter recipe name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of your recipe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
              items: ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedCategory = newValue);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Time and Servings
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Prep Time',
                      hintText: 'Minutes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _cookTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cook Time',
                      hintText: 'Minutes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Servings',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Calories
            TextFormField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories',
                hintText: 'Kcal per serving',
                suffixText: 'Kcal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter calories';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Difficulty
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
              ),
              items: ['Easy', 'Medium', 'Hard'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedDifficulty = newValue);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Ingredients
            Text('Ingredients', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.sm),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ingredients.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_ingredients[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => setState(() => _ingredients.removeAt(index)),
                  ),
                );
              },
            ),
            TextButton.icon(
              onPressed: _showAddIngredientDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Ingredient'),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Steps
            Text('Steps', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.sm),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text('${index + 1}',
                        style: TextStyle(color: AppColors.textLight)),
                  ),
                  title: Text(_steps[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => setState(() => _steps.removeAt(index)),
                  ),
                );
              },
            ),
            TextButton.icon(
              onPressed: _showAddStepDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Step'),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit Button
            ElevatedButton(
              onPressed: _submitRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              child: const Text('Create Recipe'),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showAddIngredientDialog() {
    final TextEditingController ingredientController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Ingredient', style: AppTextStyles.heading2),
        content: TextField(
          controller: ingredientController,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter ingredient',
            hintStyle: AppTextStyles.bodyMedium,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              if (ingredientController.text.isNotEmpty) {
                setState(() {
                  _ingredients.add(ingredientController.text);
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddStepDialog() {
    final TextEditingController stepController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Step'),
        content: TextField(
          controller: stepController,
          decoration: const InputDecoration(hintText: 'Enter step instructions'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (stepController.text.isNotEmpty) {
                setState(() {
                  _steps.add(stepController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRecipe() async {
    print('Submit recipe started');
    if (_formKey.currentState!.validate()) {
      print('Form validation passed');
      try {
        // Validate number fields first
        print('Validating number fields');
        print('Prep time: ${_prepTimeController.text}');
        print('Cook time: ${_cookTimeController.text}');
        print('Servings: ${_servingsController.text}');

        if (_prepTimeController.text.isEmpty || 
            _cookTimeController.text.isEmpty || 
            _servingsController.text.isEmpty) {
          throw 'Please fill in all time and serving fields';
        }

        final prepTime = int.tryParse(_prepTimeController.text);
        final cookTime = int.tryParse(_cookTimeController.text);
        final servings = int.tryParse(_servingsController.text);

        if (prepTime == null || cookTime == null || servings == null) {
          throw 'Please enter valid numbers for time and servings';
        }

        print('Number validation passed');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
        print('User ID: $userId');
        
        final calories = int.tryParse(_caloriesController.text);
        if (calories == null) {
          throw 'Please enter valid calories';
        }

        final recipe = Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdBy: userId,
          createdAt: DateTime.now(),
          imageUrl: '',
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          ingredients: _ingredients,
          steps: _steps,
          prepTime: prepTime,  // Use parsed value
          cookTime: cookTime,  // Use parsed value
          servings: servings,  // Use parsed value
          difficulty: _selectedDifficulty,
          videoUrl: '',
          tags: [],
          calories: calories,
          likesCount: 0,
          commentsCount: 0,
        );
        print('Recipe object created with title: ${recipe.title}');
        print('Selected image path: ${_imageFile?.path}');

        print('Calling createRecipeWithImage');
        await _recipeService.createRecipeWithImage(recipe, _imageFile!);
        print('Recipe created successfully');

        Navigator.pop(context); // Remove loading
        print('Loading indicator removed');
        
        Navigator.pop(context); // Return to previous screen
        print('Navigated back');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe created successfully!')),
        );
        print('Success message shown');
      } catch (e) {
        print('Error occurred: $e');
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      print('Form validation failed');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}