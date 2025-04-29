// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../bloc/auth/auth_bloc.dart';
part of '../../bloc/auth/auth_event.dart';
part of '../../bloc/auth/auth_state.dart';
import '../../core/utils/connectivity.dart';
import '../../core/utils/validation.dart';
import '../common/widgets/app_bar.dart';
import '../common/widgets/buttons.dart';
import '../common/widgets/loaders.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  
  get ConnectivityHelper => null;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check connectivity first
      final isConnected = await ConnectivityHelper.isConnected();
      if (!isConnected) {
        throw Exception('No internet connection. Please check your connection and try again.');
      }

      // Dispatch password reset event
      // ignore: use_build_context_synchronously
      context.read<AuthBloc>().add(
        AuthPasswordReset(
          email: _emailController.text.trim(),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Forgot Password',
        showBackButton: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is AuthPasswordResetSuccess) {
            setState(() {
              _isLoading = false;
              _emailSent = true;
            });
            
            Fluttertoast.showToast(
              msg: 'Password reset email sent successfully!',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          } else if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });
            
            _showErrorSnackBar(state.message);
          }
        },
        child: _emailSent ? _buildSuccessView() : _buildResetForm(),
      ),
    );
  }

  Widget _buildResetForm(dynamic Validators) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Reset Your Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              
              // Description
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),
              
              // Illustration
              Center(
                child: Lottie.asset(
                  'assets/animations/forgot_password.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40.0),
              
              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your registered email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: Validators.validateEmail,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24.0),
              
              // Reset button
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text(
                        'Reset Password',
                        style: TextStyle(fontSize: 16.0),
                      ),
              ),
              const SizedBox(height: 16.0),
              
              // Back to login button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success animation
            Center(
              child: Lottie.asset(
                'assets/animations/email_sent.json',
                width: 250,
                height: 250,
                repeat: false,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32.0),
            
            // Success title
            Text(
              'Email Sent!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            
            // Success message
            Text(
              'We\'ve sent a password reset link to:\n${_emailController.text}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            
            // Instructions
            Text(
              'Please check your email and follow the instructions to reset your password.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48.0),
            
            // Didn't receive email?
            Text(
              'Didn\'t receive the email?',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            
            // Check spam folder instructions
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8.0),
                      Text(
                        'Tips:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '• Check your spam or junk folder',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '• Make sure you entered the correct email',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '• Wait a few minutes for the email to arrive',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            
            // Try again button
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _emailSent = false;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Try Again'),
            ),
            const SizedBox(height: 16.0),
            
            // Back to login button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
  
  
}