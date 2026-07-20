import 'package:cloud_firestore/cloud_firestore.dart';

enum PrivacyProfileVisibility { public, friendsOnly, private }

enum DataSharingLevel { all, essential, none }

class PrivacySettingModel {
  final String userId;
  final PrivacyProfileVisibility profileVisibility;
  final DataSharingLevel dataSharing;
  final bool analyticsEnabled;
  final bool marketingEmails;
  final bool locationSharing;
  final bool showContactInfo;
  final bool searchableByPhone;
  final DateTime? updatedAt;

  const PrivacySettingModel({
    required this.userId,
    this.profileVisibility = PrivacyProfileVisibility.private,
    this.dataSharing = DataSharingLevel.essential,
    this.analyticsEnabled = true,
    this.marketingEmails = false,
    this.locationSharing = false,
    this.showContactInfo = false,
    this.searchableByPhone = false,
    this.updatedAt,
  });

  factory PrivacySettingModel.fromMap(Map<String, dynamic> map) {
    return PrivacySettingModel(
      userId: map['userId']?.toString() ?? '',
      profileVisibility: PrivacyProfileVisibility.values.firstWhere(
        (e) => e.name == (map['profileVisibility'] ?? 'private'),
        orElse: () => PrivacyProfileVisibility.private,
      ),
      dataSharing: DataSharingLevel.values.firstWhere(
        (e) => e.name == (map['dataSharing'] ?? 'essential'),
        orElse: () => DataSharingLevel.essential,
      ),
      analyticsEnabled: map['analyticsEnabled'] == true || map['analyticsEnabled'] == 'true',
      marketingEmails: map['marketingEmails'] == true || map['marketingEmails'] == 'true',
      locationSharing: map['locationSharing'] == true || map['locationSharing'] == 'true',
      showContactInfo: map['showContactInfo'] == true || map['showContactInfo'] == 'true',
      searchableByPhone: map['searchableByPhone'] == true || map['searchableByPhone'] == 'true',
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'profileVisibility': profileVisibility.name,
      'dataSharing': dataSharing.name,
      'analyticsEnabled': analyticsEnabled,
      'marketingEmails': marketingEmails,
      'locationSharing': locationSharing,
      'showContactInfo': showContactInfo,
      'searchableByPhone': searchableByPhone,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  PrivacySettingModel copyWith({
    String? userId,
    PrivacyProfileVisibility? profileVisibility,
    DataSharingLevel? dataSharing,
    bool? analyticsEnabled,
    bool? marketingEmails,
    bool? locationSharing,
    bool? showContactInfo,
    bool? searchableByPhone,
    DateTime? updatedAt,
  }) {
    return PrivacySettingModel(
      userId: userId ?? this.userId,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      dataSharing: dataSharing ?? this.dataSharing,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      locationSharing: locationSharing ?? this.locationSharing,
      showContactInfo: showContactInfo ?? this.showContactInfo,
      searchableByPhone: searchableByPhone ?? this.searchableByPhone,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
