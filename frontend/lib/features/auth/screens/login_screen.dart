import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/theme_provider.dart';
import '../../translator/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  void _submitForm(AuthProvider authProvider) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty || (!_isLogin && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    bool success;
    if (_isLogin) {
      success = await authProvider.login(email, password);
    } else {
      success = await authProvider.register(name, email, password);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Logged in successfully!' : 'Account created successfully!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage.isNotEmpty ? authProvider.errorMessage : 'Authentication failed', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(isDark ? 0.2 : 0.15),
              Theme.of(context).scaffoldBackgroundColor,
              AppTheme.secondaryColor.withOpacity(isDark ? 0.1 : 0.08),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                    border: Border.all(color: AppTheme.secondaryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondaryColor.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.public_rounded, size: 64, color: Colors.white),
                ),
                const SizedBox(height: 30),
                Text(
                  'AYLANTRO AI',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4, color: isDark ? Colors.white : AppTheme.primaryColor),
                ),
                const Text(
                  'PREMIUM ACCOUNT & CLOUD SYNC',
                  style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppTheme.secondaryColor, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 50),

                // Form Fields
                if (!_isLogin) ...[
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                      prefixIcon: Icon(Icons.person_outline, color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    prefixIcon: Icon(Icons.email_outlined, color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    prefixIcon: Icon(Icons.lock_outline, color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),

                if (authProvider.isLoading)
                  const CircularProgressIndicator(color: AppTheme.secondaryColor)
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => _submitForm(authProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppTheme.secondaryColor, width: 1.5),
                          ),
                        ),
                        child: Text(_isLogin ? 'SIGN IN' : 'CREATE ACCOUNT', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_isLogin ? "Don't have an account?" : "Already have an account?", style: TextStyle(color: isDark ? Colors.white70 : Colors.black70)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin ? 'Sign Up' : 'Log In', style: TextStyle(color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  },
                  child: Text('Continue as Guest', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
