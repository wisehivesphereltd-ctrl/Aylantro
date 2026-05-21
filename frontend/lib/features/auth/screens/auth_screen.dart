import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  final bool isLoginInitial;
  const AuthScreen({super.key, this.isLoginInitial = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLoginInitial;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = _isLogin
        ? await authProvider.login(
            _emailController.text.trim(),
            _passwordController.text,
          )
        : await authProvider.register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? 'Welcome back! Logged in successfully.'
                : 'Account created successfully! Welcome to Aylantro.',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context);
    } else if (mounted && authProvider.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Premium Glow Background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryColor.withOpacity(0.5), blurRadius: 100),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryColor.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(color: AppTheme.secondaryColor.withOpacity(0.4), blurRadius: 100),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.primaryColor.withOpacity(0.15) : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(isDark ? 0.4 : 0.6), width: 1.5),
                        boxShadow: isDark ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ] : [
                          const BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8)),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // App Header / Logo
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.secondaryColor, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.secondaryColor.withOpacity(0.4),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.public_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _isLogin ? 'Welcome Back' : 'Create Premium Account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isLogin
                                  ? 'Log in to sync your cloud history & preferences'
                                  : 'Sign up to unlock real-time cloud sync & alerts',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            if (!_isLogin) ...[
                              _buildTextField(
                                controller: _nameController,
                                icon: Icons.person_outline_rounded,
                                label: 'Full Name',
                                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildTextField(
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              label: 'Email Address',
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => val == null || !val.contains('@') ? 'Please enter a valid email' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              icon: Icons.lock_outline_rounded,
                              label: 'Password',
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
                            ),
                            const SizedBox(height: 32),
                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    side: const BorderSide(color: AppTheme.secondaryColor, width: 1.5),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        _isLogin ? 'LOG IN' : 'REGISTER NOW',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Toggle Mode
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _formKey.currentState?.reset();
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? "Don't have an account? Sign Up"
                                    : 'Already have an account? Log In',
                                style: TextStyle(
                                  color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        prefixIcon: Icon(icon, color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
