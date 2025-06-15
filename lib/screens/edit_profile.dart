import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import '../providers/auth_service.dart';
import '../widgets/theme_switch_widget.dart';
import '../models/profile_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = Get.find<AuthService>();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic> _initialProfile = {};
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();

    // Get initial profile data from arguments
    _initialProfile = Get.arguments ?? {};
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final formData = _formKey.currentState!.value;

        // Create profile model
        final profileModel = UserProfileModel(
          displayName: formData['displayName'],
          userName: formData['userName'],
          email: formData['email'],
          phoneNumber: formData['phoneNumber'],
        );

        final success = await _authService.updateUserProfile(profileModel);

        if (success) {
          _showSuccessSnackBar('Profile updated successfully!');
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          _showErrorSnackBar('Failed to update profile. Please try again.');
        }
      } catch (e) {
        _showErrorSnackBar('Error updating profile: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _onFormChanged() {
    if (_formKey.currentState?.isValid ?? false) {
      final currentValues = _formKey.currentState!.value;
      bool hasChanges = false;

      // Check if any field has changed
      if (currentValues['displayName'] != (_initialProfile['displayName'] ?? _initialProfile['name'])) hasChanges = true;
      if (currentValues['userName'] != _initialProfile['userName']) hasChanges = true;
      if (currentValues['email'] != _initialProfile['email']) hasChanges = true;
      if (currentValues['phoneNumber'] != _initialProfile['phoneNumber']) hasChanges = true;

      if (hasChanges != _hasChanges) {
        setState(() => _hasChanges = hasChanges);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const ThemeSwitchWidget(showLabel: false),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildHeader(),
                ),
              ),

              const SizedBox(height: 32),

              // Edit Form
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildEditForm(),
              ),

              const SizedBox(height: 32),

              // Save Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSaveButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.edit_rounded,
              size: 32,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Update Your Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your profile information up to date',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FormBuilder(
        key: _formKey,
        onChanged: _onFormChanged,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFormField(
              name: 'displayName',
              label: 'Display Name',
              icon: Icons.person_outline_rounded,
              hint: 'Enter your display name',
              initialValue: _initialProfile['displayName'] ?? _initialProfile['name'] ?? '',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Display name is required'),
                FormBuilderValidators.minLength(2, errorText: 'Name must be at least 2 characters'),
                FormBuilderValidators.maxLength(50, errorText: 'Name must be less than 50 characters'),
              ]),
            ),
            const SizedBox(height: 20),
            _buildFormField(
              name: 'userName',
              label: 'Username',
              icon: Icons.alternate_email,
              hint: 'Enter your username',
              initialValue: _initialProfile['userName'] ?? '',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.minLength(3, errorText: 'Username must be at least 3 characters'),
                FormBuilderValidators.maxLength(30, errorText: 'Username must be less than 30 characters'),
                FormBuilderValidators.match(
                  RegExp(r'^[a-zA-Z0-9_]+$'),
                  errorText: 'Username can only contain letters, numbers, and underscores',
                ),
              ]),
            ),
            const SizedBox(height: 20),
            _buildFormField(
              name: 'email',
              label: 'Email Address',
              icon: Icons.email_outlined,
              hint: 'Enter your email address',
              initialValue: _initialProfile['email'] ?? '',
              keyboardType: TextInputType.emailAddress,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Email is required'),
                FormBuilderValidators.email(errorText: 'Please enter a valid email'),
              ]),
            ),
            const SizedBox(height: 20),
            _buildFormField(
              name: 'phoneNumber',
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              hint: '+201234567890',
              initialValue: _initialProfile['phoneNumber'] ?? '',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                }
                final val = value.trim();
                if (val.startsWith('+20')) {
                  if (!RegExp(r'^\+20\d{10}$').hasMatch(val)) {
                    return 'Phone must start with +20 followed by 10 digits';
                  }
                } else if (val.startsWith('0')) {
                  if (!RegExp(r'^0\d{10}$').hasMatch(val)) {
                    return 'Phone must have 11 digits starting with 0';
                  }
                } else {
                  if (!RegExp(r'^\d{10}$').hasMatch(val)) {
                    return 'Phone must have 10 digits if not starting with +20 or 0';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Changes will be saved to your account and synced across all devices.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String name,
    required String label,
    required IconData icon,
    required String hint,
    String? initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FormBuilderTextField(
      name: name,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: _isLoading
              ? Container(
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary,
              ),
            ),
          )
              : ElevatedButton.icon(
            onPressed: _hasChanges ? _updateProfile : null,
            icon: Icon(
              Icons.save_rounded,
              color: _hasChanges ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.5),
            ),
            label: Text(
              'Save Changes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _hasChanges ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasChanges ? colorScheme.primary : colorScheme.surfaceVariant,
              foregroundColor: _hasChanges ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: _hasChanges ? 2 : 0,
            ),
          ),
        ),

        if (!_hasChanges) ...[
          const SizedBox(height: 12),
          Text(
            'Make changes to enable saving',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
