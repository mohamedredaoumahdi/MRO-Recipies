import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/screens/register_screen.dart';
import 'package:moroccan_recipies_app/screens/signIn_screen.dart';
import 'package:moroccan_recipies_app/service/auth_service.dart';
import 'package:moroccan_recipies_app/service/recipe_service.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ProfileScreen({super.key, required this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();
  bool _isEditing = false;
  final _nameController = TextEditingController();

  bool get _isAnonymous => _authService.currentUser?.isAnonymous ?? false;

  @override
  void initState() {
    super.initState();
    _nameController.text = _authService.userDisplayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Profile'),
        actions: [
          if (!_isAnonymous)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _updateProfile();
                }
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            ),
        ],
      ),
      body: _isAnonymous ? _buildGuestView(screenHeight) : _buildUserProfile(),
    );
  }

  Widget _buildGuestView(double screenHeight) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_circle,
              size: screenHeight * 0.12,
              color: AppColors.primary.withOpacity(0.5),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Guest User',
              style: AppTextStyles.heading2,
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Create an account to:',
              style: AppTextStyles.bodyLarge,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildFeatureItem(Icons.add_circle_outline, 'Share your own recipes'),
            _buildFeatureItem(Icons.favorite_border, 'Save favorite recipes'),
            _buildFeatureItem(Icons.bookmark_border, 'Create recipe collections'),
            _buildFeatureItem(Icons.person_outline, 'Personalize your profile'),
            SizedBox(height: screenHeight * 0.03),
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.05,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create Account'),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.05,
              child: OutlinedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            TextButton(
              onPressed: () async {
                try {
                  await _authService.signOut();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/signin',
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_authService.userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final createdAt = userData?['createdAt'] as Timestamp?;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Text(
                  (userData?['fullName'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_isEditing)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                )
              else
                Text(
                  userData?['fullName'] ?? 'User',
                  style: AppTextStyles.heading2,
                ),
              Text(
                _authService.userEmail ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Member since ${_formatDate(createdAt?.toDate())}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildStatsRow(),
              const SizedBox(height: AppSpacing.xl),
              _buildActionButtons(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: _recipeService.getUserStats(_authService.userId ?? ''),
      builder: (context, snapshot) {
        final recipeCount = snapshot.data?.docs.length ?? 0;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('Recipes', recipeCount.toString()),
            _buildStatItem('Likes', '0'),
            _buildStatItem('Bookmarks', '0'),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading2,
        ),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.lock_outline),
          label: const Text('Change Password'),
          onPressed: _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
          onPressed: () async {
            await _authService.signOut();
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/signin',
                (route) => false,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _updateProfile() async {
    try {
      await _authService.updateProfile(
        displayName: _nameController.text,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_authService.userId)
          .update({'fullName': _nameController.text});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentPasswordController,
              decoration: const InputDecoration(labelText: 'Current Password'),
              obscureText: true,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: newPasswordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
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
              try {
                await _authService.changePassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated successfully')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
