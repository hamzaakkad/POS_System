import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../reusable widgets/AppColors.dart';
import '../providers/theme_provider.dart';

class AuthPage extends StatefulWidget {
  final bool isLogin;

  const AuthPage({super.key, this.isLogin = true});

  @override
  State<AuthPage> createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  late bool isLogin;
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstPhoneNumberController = TextEditingController();
  final secondPhoneNumberController = TextEditingController();

  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    firstPhoneNumberController.dispose();
    secondPhoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watchAccountProvider = context.watch<AccountProvider>();
    bool isLogin = watchAccountProvider.isLogin;
    final isDark = context.watch<ThemeProvider>().isDark;
    final readAccountProvider = context.read<AccountProvider>();
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
                            onPressed: () {},
                            icon: Icon(Icons.arrow_back),
                            color: Colors.transparent,
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

                    /// new account card style (Matches Orders Table Styling) with some cool shadows
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
                              key: formKey,
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
                                      controller: nameController,
                                      label: "Full Name",
                                      icon: Icons.person_outline,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  _buildTextField(
                                    controller: emailController,
                                    label: "Email Address",
                                    icon: Icons.email_outlined,
                                    isDark: isDark,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  if (!isLogin) ...[
                                    const SizedBox(height: 20),

                                    _buildPhoneField(
                                      controller: firstPhoneNumberController,
                                      label: "Phone (optional)",
                                      icon: Icons.phone,
                                      isDark: isDark,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 20),

                                    _buildPhoneField(
                                      controller: secondPhoneNumberController,
                                      label: "Second Phone (optional)",
                                      icon: Icons.phone,
                                      isDark: isDark,
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ],

                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: passwordController,
                                    label: "Password",
                                    icon: Icons.lock_outline,
                                    isDark: isDark,
                                    isPassword: true,
                                    //YESS
                                    onSubmitted: (_) =>
                                        watchAccountProvider.submit(
                                          context,
                                          nameController,
                                          emailController,
                                          passwordController,
                                          firstPhoneNumberController,
                                          secondPhoneNumberController,
                                        ),
                                  ),
                                  const SizedBox(height: 40),

                                  /// PRIMARY ACTION BUTTON
                                  Consumer<AccountProvider>(
                                    builder: (context, accountProvider, _) {
                                      return ElevatedButton(
                                        onPressed: accountProvider.loading
                                            ? null
                                            : () async =>
                                                  await accountProvider.submit(
                                                    context,
                                                    nameController,
                                                    emailController,
                                                    passwordController,
                                                    firstPhoneNumberController,
                                                    secondPhoneNumberController,
                                                  ),
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
                                    onPressed:
                                        watchAccountProvider.toggleAuthMode,
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
    onSubmitted,
  }) {
    return TextFormField(
      onFieldSubmitted: onSubmitted,
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
        if (label.contains("Email") && !value.contains("@")) {
          return "Invalid email";
        }

        if (value.contains(' ')) return 'Spaces are not allowed';

        if (isPassword && value.length < 6) return "Min 6 characters";
        return null;
      },
    );
  }
}

Widget _buildPhoneField({
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
      if (value == null || value.isEmpty) {
        return null;
      }

      //Check if it contains ONLY numbers (0-9)
      // The regex ^[0-9]+$ matches from start to end for digits only
      final numberRegex = RegExp(r'^[0-9]+$');

      if (!numberRegex.hasMatch(value)) {
        return 'You can only type numbers here!';
      }

      return null;
    },
  );
}
