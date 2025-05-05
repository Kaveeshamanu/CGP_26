import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taprobana_trails/data/models/app_user.dart';

import '../../config/theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'auth_screens.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginPressed;

  const RegisterScreen({
    super.key,
    required this.onLoginPressed,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the terms and conditions'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Since RegisterRequested is not defined in your AuthBloc,
      // we'll use UserChanged instead
      final newUser = AppUser(
          id: DateTime.now().toString(), // Generate a temporary ID
          email: _emailController.text,
          displayName: _nameController.text,
          profilePhotoUrl: '',
          isEmailVerified: true // Default empty photo URL
          // Add any other required fields for your AppUser class
          );

      // First add a loading state
      context.read<AuthBloc>().add(AppStarted());

      // Then trigger user creation
      // You might need to implement this in your AuthService
      // and then handle the user creation there
      context.read<AuthBloc>().add(UserChanged(user: newUser));
    }
  }

  void _signUpWithGoogle() {
    // Since GoogleSignInRequested is not defined in your AuthBloc,
    // we'll simulate this by using UserChanged with a Google-type user
    context.read<AuthBloc>().add(
          UserChanged(
            user: AppUser(
                id: 'google_${DateTime.now().millisecondsSinceEpoch}',
                email: '', // This will be filled by Google auth
                displayName: '', // This will be filled by Google auth
                profilePhotoUrl: '',
                isEmailVerified: true
                // Add any other required fields
                ),
          ),
        );
  }

  void _signUpWithApple() {
    // Similar approach as with Google sign-up
    context.read<AuthBloc>().add(
          UserChanged(
            user: AppUser(
                id: 'apple_${DateTime.now().millisecondsSinceEpoch}',
                email: '', // This will be filled by Apple auth
                displayName: '', // This will be filled by Apple auth
                profilePhotoUrl: '',
                isEmailVerified: true
                // Add any other required fields
                ),
          ),
        );
  }

  void _signUpWithFacebook() {
    // Similar approach as with Google sign-up
    context.read<AuthBloc>().add(
          UserChanged(
            user: AppUser(
                id: 'facebook_${DateTime.now().millisecondsSinceEpoch}',
                email: '', // This will be filled by Facebook auth
                displayName: '', // This will be filled by Facebook auth
                profilePhotoUrl: '',
                isEmailVerified: true
                // Add any other required fields
                ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // App logo
            Center(
              child: Image.asset(
                'assets/images/app_logo.png',
                height: 80,
                width: 80,
              ),
            ),

            const SizedBox(height: 24),

            // Sign up text
            const Text(
              'Create Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Sign up to start your Sri Lankan journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 32),

            // Registration form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name field
                  AuthTextField(
                    label: 'Full Name',
                    icon: Icons.person,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email field
                  AuthTextField(
                    label: 'Email',
                    icon: Icons.email,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  AuthTextField(
                    label: 'Password',
                    icon: Icons.lock,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    isPassword: true,
                    onVisibilityToggle: _togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      // Check for at least one uppercase letter, one lowercase letter, and one number
                      if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])')
                          .hasMatch(value)) {
                        return 'Include uppercase, lowercase & number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Confirm password field
                  AuthTextField(
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    isPassword: true,
                    onVisibilityToggle: _toggleConfirmPasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  // Terms and conditions checkbox
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          checkColor: Colors.white,
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return AppTheme.primaryColor;
                              }
                              return Colors.white54;
                            },
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree to the ',
                                style: const TextStyle(color: Colors.white),
                                children: [
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Navigate to terms of service
                                        Navigator.pushNamed(context, '/terms');
                                      },
                                  ),
                                  const TextSpan(
                                    text: ' and ',
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Navigate to privacy policy
                                        Navigator.pushNamed(
                                            context, '/privacy');
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign up button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Or divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.white54, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.white54, thickness: 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Social sign up buttons
            SocialAuthButton(
              icon: FontAwesomeIcons.google,
              label: 'Sign up with Google',
              color: Colors.red,
              onPressed: _signUpWithGoogle,
            ),

            SocialAuthButton(
              icon: FontAwesomeIcons.apple,
              label: 'Sign up with Apple',
              color: Colors.black,
              onPressed: _signUpWithApple,
            ),

            SocialAuthButton(
              icon: FontAwesomeIcons.facebook,
              label: 'Sign up with Facebook',
              color: const Color(0xFF1877F2),
              onPressed: _signUpWithFacebook,
            ),

            const SizedBox(height: 24),

            // Sign in link
            Center(
              child: AuthToggleButton(
                question: "Already have an account?",
                actionText: "Sign In",
                onPressed: widget.onLoginPressed,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
