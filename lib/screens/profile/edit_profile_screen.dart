import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/dashboard_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  String? _usernameError;
  String? _emailError;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<DashboardViewModel>();
    _usernameController = TextEditingController(text: vm.username);
    _emailController = TextEditingController(text: vm.email);

    // Track changes
    _usernameController.addListener(_onChanged);
    _emailController.addListener(_onChanged);
  }

  void _onChanged() {
    final vm = context.read<DashboardViewModel>();
    _validateLive();
    setState(() {
      _hasChanges =
          _usernameController.text != vm.username ||
          _emailController.text != vm.email;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    // Pop back after successful update
    if (vm.updateSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.resetUpdateSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: AppColors.tagGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textMain,
        elevation: 0,
        actions: [
          // Save button — only active when changes made
          TextButton(
            onPressed: _hasChanges && !vm.isLoading
                ? () => _save(context)
                : null,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _hasChanges ? AppColors.accent : AppColors.textSub,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar section ───────────────
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(45),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: AppColors.accent,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Change Photo',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Username field
              _formField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.person_outline_rounded,
                liveError: _usernameError,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Username cannot be empty';
                  }
                  if (val.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  if (val.trim().length > 20) {
                    return 'Username cannot exceed 20 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_ ]+$').hasMatch(val.trim())) {
                    return 'Only letters, numbers and underscores allowed';
                  }
                  if (RegExp(r'^[0-9]').hasMatch(val.trim())) {
                    return 'Username cannot start with a number';
                  }
                  if (RegExp(r'^_').hasMatch(val.trim())) {
                    return 'Username cannot start with underscore';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Email field
              _formField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                liveError: _emailError,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Email cannot be empty';
                  }
                  if (val.trim().length > 254) {
                    return 'Email address is too long';
                  }
                  if (!RegExp(
                    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                  ).hasMatch(val.trim())) {
                    return 'Enter a valid email address';
                  }
                  if (val.contains('..')) {
                    return 'Email cannot contain consecutive dots';
                  }
                  if (val.trim().startsWith('.') ||
                      val.split('@').first.endsWith('.')) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),

              // Read-only fields
              _readOnlyField('Student ID', 'TP076562', Icons.badge_outlined),
              const SizedBox(height: 14),

              _readOnlyField('Role', 'Student', Icons.school_outlined),
              const SizedBox(height: 32),

              // ── Error message ─────────────────
              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    vm.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.badge,
                      fontSize: 13,
                    ),
                  ),
                ),

              // ── Save button ──────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _hasChanges && !vm.isLoading
                      ? () => _save(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.divider,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    // Block if live errors exist
    if (_usernameError != null || _emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Please fix the errors before saving'),
            ],
          ),
          backgroundColor: AppColors.badge,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    context.read<DashboardViewModel>().updateProfile(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSub,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? liveError,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    // Determine current state for border color
    final hasError = liveError != null;
    final isValid = controller.text.isNotEmpty && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColors.textMain),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSub),
            prefixIcon: Icon(icon, size: 20, color: AppColors.textSub),
            // Green tick when valid
            suffixIcon: controller.text.isNotEmpty
                ? Icon(
                    hasError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_rounded,
                    size: 18,
                    color: hasError ? AppColors.badge : AppColors.tagGreen,
                  )
                : null,
            filled: true,
            fillColor: hasError
                ? AppColors.badge.withValues(alpha: 0.04)
                : isValid
                ? AppColors.tagGreen.withValues(alpha: 0.04)
                : AppColors.cardBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.badge.withValues(alpha: 0.5)
                    : isValid
                    ? AppColors.tagGreen.withValues(alpha: 0.5)
                    : AppColors.divider,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.badge
                    : isValid
                    ? AppColors.tagGreen
                    : AppColors.accent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.badge, width: 1.5),
            ),
          ),
        ),

        // ── Live error message ─────────────────
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 12,
                  color: AppColors.badge,
                ),
                const SizedBox(width: 4),
                Text(
                  liveError,
                  style: const TextStyle(fontSize: 11, color: AppColors.badge),
                ),
              ],
            ),
          ),

        // ── Valid message ──────────────────────
        if (isValid && !hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: AppColors.tagGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  label == 'Username'
                      ? 'Username looks good'
                      : 'Valid email address',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.tagGreen,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _readOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.navInactive),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSub),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.navInactive,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.lock_outline_rounded,
            size: 14,
            color: AppColors.navInactive,
          ),
        ],
      ),
    );
  }

  void _validateLive() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    setState(() {
      // ── Username live checks ────────────────
      if (username.isEmpty) {
        _usernameError = null; // don't show error on empty while typing
      } else if (username.length < 3) {
        _usernameError = 'Too short — minimum 3 characters';
      } else if (username.length > 20) {
        _usernameError = 'Too long — maximum 20 characters';
      } else if (!RegExp(r'^[a-zA-Z0-9_ ]+$').hasMatch(username)) {
        _usernameError = 'Only letters, numbers and underscores';
      } else if (RegExp(r'^[0-9]').hasMatch(username)) {
        _usernameError = 'Cannot start with a number';
      } else if (RegExp(r'^_').hasMatch(username)) {
        _usernameError = 'Cannot start with underscore';
      } else {
        _usernameError = null; // valid
      }

      // ── Email live checks ───────────────────
      if (email.isEmpty) {
        _emailError = null;
      } else if (!email.contains('@')) {
        _emailError = 'Missing @ symbol';
      } else if (email.split('@').length != 2) {
        _emailError = 'Invalid email format';
      } else if (email.split('@').last.isEmpty) {
        _emailError = 'Missing domain after @';
      } else if (!email.split('@').last.contains('.')) {
        _emailError = 'Missing domain extension (e.g. .com)';
      } else if (email.contains('..')) {
        _emailError = 'Cannot contain consecutive dots';
      } else if (email.length > 254) {
        _emailError = 'Email is too long';
      } else if (!RegExp(
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(email)) {
        _emailError = 'Enter a valid email address';
      } else {
        _emailError = null; // valid
      }
    });
  }
}
