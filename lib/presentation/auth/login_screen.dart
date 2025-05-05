import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:taprobana_trails/data/models/app_user.dart';

import '../../config/theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'auth_screens.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onRegisterPressed;
  final VoidCallback? onForgotPasswordPressed;

  const LoginScreen({
    super.key,
    this.onRegisterPressed,
    this.onForgotPasswordPressed,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      // Use LoggedIn event instead of LoginRequested since that's what's in your AuthBloc
      context.read<AuthBloc>().add(
            LoggedIn(
              user: AppUser(
                id: _emailController.text,
                email: _emailController.text,
                displayName: '',
                profilePhotoUrl: '',
                isEmailVerified: true,
                // Add any other required fields
              ),
            ),
          );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(
          UserChanged(
            user: AppUser(
                id: 'google_user_id',
                email: 'google_user@example.com',
                displayName: 'Google User',
                profilePhotoUrl: '',
                isEmailVerified: true
                // Add any other required fields
                ),
          ),
        );
  }

  void _signInWithApple() {
    // Similar approach as with Google sign-in
    context.read<AuthBloc>().add(
          UserChanged(
            user: AppUser(
                id: 'apple_user_id',
                email: 'apple_user@example.com',
                displayName: 'Apple User',
                profilePhotoUrl: '',
                isEmailVerified: true
                // Add any other required fields
                ),
          ),
        );
  }

  void _signInWithFacebook() {
    // Similar approach as with Google sign-in
    context.read<AuthBloc>().add(
          UserChanged(
            user: AppUser(
                id: 'facebook_user_id',
                email: 'facebook_user@example.com',
                displayName: 'Facebook User',
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
                height: 100,
                width: 100,
              ),
            ),

            const SizedBox(height: 24),

            // Welcome text
            const Text(
              'Welcome to Taprobana Trails',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Sign in to continue your Sri Lankan adventure',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 32),

            // Login form
            Form(
              key: _formKey,
              child: Column(
                children: [
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
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  // Remember me and forgot password row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        // Remember me checkbox
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
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
                        const Text(
                          'Remember me',
                          style: TextStyle(color: Colors.white),
                        ),

                        const Spacer(),

                        // Forgot password link
                        TextButton(
                          onPressed: widget.onForgotPasswordPressed,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign in button
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
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
                        'Sign In',
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

            // Social sign in buttons
            SocialAuthButton(
              icon: FontAwesomeIcons.google,
              label: 'Continue with Google',
              color: Colors.red,
              onPressed: _signInWithGoogle,
            ),

            SocialAuthButton(
              icon: FontAwesomeIcons.apple,
              label: 'Continue with Apple',
              color: Colors.black,
              onPressed: _signInWithApple,
            ),

            SocialAuthButton(
              icon: FontAwesomeIcons.facebook,
              label: 'Continue with Facebook',
              color: const Color(0xFF1877F2),
              onPressed: _signInWithFacebook,
            ),

            const SizedBox(height: 24),

            // Sign up link
            Center(
              child: AuthToggleButton(
                question: "Don't have an account?",
                actionText: "Sign Up",
                onPressed: widget.onRegisterPressed!,
              ),
            ),

            const SizedBox(height: 16),

            // Continue as guest
            Center(
              child: TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        UserChanged(
                          user: AppUser(
                              id: 'guest_user',
                              email: 'guest@example.com',
                              displayName: 'Guest User',
                              profilePhotoUrl: '',
                              isEmailVerified: true
                              // Add any other required fields
                              ),
                        ),
                      );
                },
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
