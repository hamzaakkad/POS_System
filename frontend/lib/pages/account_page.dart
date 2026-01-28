import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/account_service.dart';
import '../models/account_model.dart';
import '../providers/account_provider.dart';
import '../reusable widgets/AppColors.dart';
import '../providers/theme_provider.dart';
import '../pages/pos_dashboard.dart';

class AuthPage extends StatefulWidget {
  final bool isLogin;
  const AuthPage({super.key, this.isLogin = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool isLogin;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final accountProvider = context.read<AccountProvider>();

    try {
      if (isLogin) {
        final success = await accountProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (success && mounted) {
          _navigateToDashboard();
        } else if (mounted && accountProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(accountProvider.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final success = await accountProvider.signup(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created! Please login.")),
          );
          setState(() => isLogin = true);
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
        } else if (mounted && accountProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(accountProvider.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const PosDashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(screenWidth > 800 ? 32 : 16),
                child: Column(
                  children: [
                    /// ,atching header style to my other designs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextPrimary,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Text(
                          isLogin ? 'LOGIN' : 'SIGN UP',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            fontSize: screenWidth > 800 ? 28 : 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 40),

                    /// new account card style (Matches Orders Table Styling)
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            width: 500, // Fixed width for desktop feel
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBgElevated
                                  : AppColors.lightBgElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderSubtle
                                    : Colors.grey.shade300,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? AppColors.darkButtonsPrimary
                                            .withOpacity(0.4)
                                      : AppColors.accentBlue.withOpacity(0.4),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Icon(
                                    Icons.store_rounded,
                                    size: 64,
                                    color: isDark
                                        ? AppColors.darkButtonsPrimary
                                        : AppColors.accentBlue,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    isLogin ? "Welcome Back" : "New Account",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  if (!isLogin) ...[
                                    _buildTextField(
                                      controller: _nameController,
                                      label: "Full Name",
                                      icon: Icons.person_outline,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  _buildTextField(
                                    controller: _emailController,
                                    label: "Email Address",
                                    icon: Icons.email_outlined,
                                    isDark: isDark,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _passwordController,
                                    label: "Password",
                                    icon: Icons.lock_outline,
                                    isDark: isDark,
                                    isPassword: true,
                                  ),
                                  const SizedBox(height: 40),

                                  /// PRIMARY ACTION BUTTON
                                  Consumer<AccountProvider>(
                                    builder: (context, accountProvider, _) {
                                      return ElevatedButton(
                                        onPressed: accountProvider.loading
                                            ? null
                                            : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDark
                                              ? AppColors.darkButtonsPrimary
                                              : AppColors.accentBlue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 22,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: accountProvider.loading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                isLogin
                                                    ? "LOGIN"
                                                    : "CREATE ACCOUNT",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.1,
                                                ),
                                              ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  TextButton(
                                    onPressed: _toggleAuthMode,
                                    child: Text(
                                      isLogin
                                          ? "Don't have an account? Sign Up"
                                          : "Already have an account? Login",
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextMuted,
                                        fontWeight: FontWeight.w500,
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
                    //   SizedBox(width: 48),
                    //this was useless imma findout another way
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
        ),
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextMuted : Colors.grey.shade600,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkBgSurface : Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderSubtle : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkButtonsPrimary : AppColors.accentBlue,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Field required";
        if (label.contains("Email") && !value.contains("@"))
          return "Invalid email";
        if (isPassword && value.length < 6) return "Min 6 characters";
        return null;
      },
    );
  }
}
