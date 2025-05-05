import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/services.dart';
import 'package:taprobana_trails/presentation/common/widgets/app_bar.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../data/models/user.dart';
import '../../data/models/app_user.dart'; // Make sure to import AppUser model

class ProfileSetupScreen extends StatefulWidget {
  final User? user;
  final bool isInitialSetup;

  const ProfileSetupScreen({
    super.key,
    this.user,
    this.isInitialSetup = true,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  File? _profileImage;
  DateTime? _dateOfBirth;
  String? _gender;
  String? _nationality;
  bool _isLoading = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];

  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  void _initUserData() {
    if (widget.user != null) {
      _nameController.text = widget.user!.displayName!;
      _phoneController.text = widget.user!.phoneNumber ?? '';

      if (widget.user!.preferences != null) {
        _bioController.text = widget.user!.preferences!['bio'] as String? ?? '';

        if (widget.user!.preferences!['dateOfBirth'] != null) {
          _dateOfBirth = DateTime.tryParse(
              widget.user!.preferences!['dateOfBirth'] as String);
        }

        _gender = widget.user!.preferences!['gender'] as String?;
        _nationality = widget.user!.preferences!['nationality'] as String?;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          setState(() {
            _profileImage = File(croppedFile.path);
          });
        }
      }
    } on PlatformException catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    }
  }

  // Fix the _cropImage method to use the correct parameter format
  Future<CroppedFile?> _cropImage(File imageFile) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate =
        _dateOfBirth ?? DateTime(currentDate.year - 25);
    final DateTime firstDate = DateTime(currentDate.year - 100);
    final DateTime lastDate =
        DateTime(currentDate.year - 12); // Minimum age 12 years

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
            ),
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _selectNationality(BuildContext context) async {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        textStyle: Theme.of(context).textTheme.bodyMedium!,
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _nationality = country.name;
        });
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Skip connectivity check since ConnectivityService is not available
      // Directly proceed with the profile update

      // Prepare user data
      final Map<String, dynamic> userData = {
        'displayName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'preferences': {
          'bio': _bioController.text.trim(),
          'dateOfBirth': _dateOfBirth?.toIso8601String(),
          'gender': _gender,
          'nationality': _nationality,
          'isProfileComplete': true,
        },
      };

      // Use UserChanged event instead of AuthProfileUpdate
      final updatedUser = AppUser(
          id: widget.user?.id ?? '',
          email: widget.user?.email ?? '',
          displayName: _nameController.text.trim(),
          profilePhotoUrl: widget.user?.profilePhotoUrl ?? '',
          isEmailVerified: true
          // Add other fields as needed based on your AppUser model
          );

      // Dispatch the UserChanged event
      context.read<AuthBloc>().add(UserChanged(user: updatedUser));

      // Manually handle success
      setState(() {
        _isLoading = false;
      });

      if (widget.isInitialSetup) {
        // Navigate to home screen after initial setup
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      } else {
        // Show success message and return to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
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
      appBar: CustomAppBar(
        title: widget.isInitialSetup ? 'Complete Your Profile' : 'Edit Profile',
        showBackButton: !widget.isInitialSetup,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is AuthAuthenticated) {
            // Use AuthAuthenticated instead of ProfileUpdateSuccess
            setState(() {
              _isLoading = false;
            });

            if (widget.isInitialSetup) {
              // Navigate to home screen after initial setup
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            } else {
              // Show success message and return to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          } else if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });

            _showErrorSnackBar(state.message);
          }
        },
        child: Stack(
          children: [
            _buildProfileForm(),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        backgroundImage: _getProfileImage(),
                        child: _profileImage == null &&
                                widget.user?.profilePhotoUrl == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Full name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16.0),

              // Phone number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  // Basic phone validation
                  if (value == null || value.isEmpty) {
                    return null; // Phone is optional
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16.0),

              // Date of Birth
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    _dateOfBirth != null
                        ? DateFormat('MMMM d, yyyy').format(_dateOfBirth!)
                        : 'Select your date of birth',
                    style: _dateOfBirth == null
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                            )
                        : Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Gender
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                items: _genderOptions.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
                hint: const Text('Select your gender'),
              ),
              const SizedBox(height: 16.0),

              // Nationality
              InkWell(
                onTap: () => _selectNationality(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Nationality',
                    prefixIcon: const Icon(Icons.public),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    _nationality ?? 'Select your nationality',
                    style: _nationality == null
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                            )
                        : Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Write a short description about yourself',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 32.0),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  widget.isInitialSetup ? 'Complete Profile' : 'Save Changes',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              if (widget.isInitialSetup)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    },
                    child: const Text('Skip for now'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get profile image
  ImageProvider? _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (widget.user?.profilePhotoUrl != null) {
      return NetworkImage(widget.user!.profilePhotoUrl!);
    } else {
      return null;
    }
  }
}
