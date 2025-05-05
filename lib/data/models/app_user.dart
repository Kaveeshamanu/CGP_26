import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

// Import these from your user.dart file where these enums are defined
import 'user.dart' show AuthProvider, UserRole;

part 'app_user.g.dart';

/// A simplified user model for authentication purposes
@JsonSerializable()
class AppUser extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? profilePhotoUrl;
  final bool isEmailVerified;
  final AuthProvider? authProvider;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.profilePhotoUrl,
    required this.isEmailVerified,
    this.authProvider,
    this.role = UserRole.traveler,
  });

  /// Creates an AppUser from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  /// Converts this AppUser to JSON
  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        profilePhotoUrl,
        isEmailVerified,
        authProvider,
        role,
      ];
}
