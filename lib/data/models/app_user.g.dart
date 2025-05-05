// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool,
      authProvider: $enumDecode(_$AuthProviderEnumMap, json['authProvider']),
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ??
          UserRole.traveler,
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'isEmailVerified': instance.isEmailVerified,
      'authProvider': _$AuthProviderEnumMap[instance.authProvider]!,
      'role': _$UserRoleEnumMap[instance.role]!,
    };

const _$AuthProviderEnumMap = {
  AuthProvider.email: 'email',
  AuthProvider.google: 'google',
  AuthProvider.apple: 'apple',
  AuthProvider.facebook: 'facebook',
  AuthProvider.phone: 'phone',
};

const _$UserRoleEnumMap = {
  UserRole.traveler: 'traveler',
  UserRole.localGuide: 'localGuide',
  UserRole.businessOwner: 'businessOwner',
  UserRole.admin: 'admin',
};
