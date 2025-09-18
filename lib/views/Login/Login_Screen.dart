import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_bets/core/utils/app_theme.dart';
import 'package:sales_bets/providers/auth_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sales_bets/views/SignUp/Signup_onboarding.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(context, authProvider.errorMessage!);
        authProvider.clearError();
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 48),
              _buildLoginForm(theme, authProvider),
              const SizedBox(height: 24),
              _buildOrDivider(theme),
              const SizedBox(height: 24),
              _buildSocialLoginButton(theme),
              const SizedBox(height: 40),
              _buildSignUpPrompt(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.login_rounded, size: 48, color: AppTheme.primaryColor),
        // Lottie.asset(
        //   'assets/lottie/login_animation.json',
        //   height: 150,
        // ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back',
          style: theme.textTheme.displaySmall?.copyWith(
            color: AppTheme.lightText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your journey and conquer the betting world.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme, AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.greyText),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: AppTheme.greyText),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password cannot be empty';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to Forgot Password screen
              },
              child: Text(
                'Forgot Password?',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (authProvider.isLoading)
            const CircularProgressIndicator(color: AppTheme.primaryColor)
          else
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  authProvider.signIn(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56), // Full width button
                elevation: 4,
                shadowColor: AppTheme.primaryColor.withOpacity(0.4),
              ),
              child: const Text('Login'),
            ),
        ],
      ),
    );
  }

  Widget _buildOrDivider(ThemeData theme) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.darkBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'OR',
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.mutedText),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.darkBorder)),
      ],
    );
  }

  Widget _buildSocialLoginButton(ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Implement Google Sign-In or other social auth
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.lightText,
        side: const BorderSide(color: AppTheme.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      icon: const Icon(FontAwesomeIcons.google), // Add a Google logo asset
      label: const Text(
        'Sign in with Google',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSignUpPrompt(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.mutedText,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AuthScreen()),
            );
          },
          child: Text(
            'Sign Up',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}