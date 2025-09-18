import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_bets/core/utils/app_theme.dart';
import 'package:sales_bets/providers/auth_provider.dart';
import 'package:sales_bets/views/Home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  
  // Separate controllers for login and signup
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  int _currentPageIndex = 0;
  late AnimationController _toggleAnimationController;
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    _toggleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPageIndex) {
      setState(() {
        _currentPageIndex = page;
      });
      if (page == 0) {
        _toggleAnimationController.reverse();
      } else {
        _toggleAnimationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _toggleAnimationController.dispose();
    
    // Dispose all controllers
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (_lastErrorMessage != message) {
      _lastErrorMessage = message;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _switchToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Handle error messages
          if (authProvider.errorMessage != null && 
              authProvider.errorMessage != _lastErrorMessage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorSnackBar(context, authProvider.errorMessage!);
              authProvider.clearError();
            });
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  
                  // App Logo/Title Section
                  _buildHeader(theme),
                  const SizedBox(height: 32),
                  
                  // Auth Toggle
                  _buildAuthToggle(theme),
                  const SizedBox(height: 24),
                  
                  // Forms
                  Expanded(
                    flex: 3,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildLoginForm(theme, authProvider),
                        _buildSignupForm(theme, authProvider),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.trending_up,
            size: 40,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sales Bets',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back! Please sign in to your account',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.mutedText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              'Login',
              _currentPageIndex == 0,
              () => _switchToPage(0),
              theme,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              'Sign Up',
              _currentPageIndex == 1,
              () => _switchToPage(1),
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String text, 
    bool isSelected, 
    VoidCallback onPressed, 
    ThemeData theme
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: isSelected ? 2 : 0,
          backgroundColor: isSelected ? AppTheme.primaryColor : Colors.transparent,
          foregroundColor: isSelected ? Colors.white : AppTheme.mutedText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shadowColor: AppTheme.primaryColor.withOpacity(0.3),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, AuthProvider authProvider) {
    return Form(
      key: _loginFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _loginEmailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _loginPasswordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              text: 'Login',
              isLoading: authProvider.isLoading,
              onPressed: () => _handleLogin(authProvider),
            ),
            const SizedBox(height: 16),
            _buildForgotPasswordButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm(ThemeData theme, AuthProvider authProvider) {
    return Form(
      key: _signupFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: _validateFullName,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signupEmailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _signupPasswordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) => _validateConfirmPassword(value, _signupPasswordController.text),
            ),
            const SizedBox(height: 24),
            _buildActionButton(
              text: 'Sign Up',
              isLoading: authProvider.isLoading,
              onPressed: () => _handleSignup(authProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.darkSurface.withOpacity(0.5),
      ),
      keyboardType: keyboardType,
      obscureText: isPassword,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildActionButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(ThemeData theme) {
    return TextButton(
      onPressed: () {
        // TODO: Implement Forgot Password logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Forgot password feature coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Text(
        'Forgot Password?',
        style: theme.textTheme.labelLarge?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid full name';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Action handlers
  void _handleLogin(AuthProvider authProvider) async {
    if (_loginFormKey.currentState!.validate()) {
      final success = await authProvider.signIn(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      
      if (success && mounted) {
        _navigateToHome();
      }
    }
  }

  void _handleSignup(AuthProvider authProvider) async {
    if (_signupFormKey.currentState!.validate()) {
      final success = await authProvider.signUp(
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text,
        fullName: _fullNameController.text.trim(),
      );
      
      if (success && mounted) {
        _navigateToHome();
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}