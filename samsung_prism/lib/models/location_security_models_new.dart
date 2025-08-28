/// Location Security Models
/// 
/// These models handle location-based security features including:
/// - User location tracking
/// - Trusted location management
/// - Login attempt logging
/// - Security alert generation

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's current or historical location
class UserLocation {
  final double latitude;
  final double longitude;
  final String displayName;
  final String? address;
  final DateTime timestamp;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.address,
    required this.timestamp,
  });

  /// Calculate distance to another location in meters
  double distanceTo(UserLocation other) {
    return _calculateDistance(latitude, longitude, other.latitude, other.longitude);
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'displayName': displayName,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory UserLocation.fromMap(Map<String, dynamic> map) {
    return UserLocation(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      displayName: map['displayName'] ?? '',
      address: map['address'],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  @override
  String toString() {
    return 'UserLocation{lat: $latitude, lng: $longitude, name: $displayName}';
  }
}

/// Represents a location marked as trusted by the user
class TrustedLocation {
  final String id;
  final String userId;
  final UserLocation location;
  final String name;
  final String? description;
  final DateTime createdAt;
  final bool isActive;

  TrustedLocation({
    required this.id,
    required this.userId,
    required this.location,
    required this.name,
    this.description,
    required this.createdAt,
    this.isActive = true,
  });

  double distanceFrom(UserLocation other) {
    return location.distanceTo(other);
  }

  /// Check if a location is within a certain radius of this trusted location
  bool isNear(UserLocation userLocation, {double radiusKm = 5.0}) {
    double distance = distanceFrom(userLocation);
    return distance <= (radiusKm * 1000); // Convert km to meters
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'location': location.toMap(),
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory TrustedLocation.fromMap(Map<String, dynamic> map) {
    return TrustedLocation(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      location: UserLocation.fromMap(map['location'] ?? {}),
      name: map['name'] ?? '',
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
    );
  }
}

/// Represents a login attempt with location data
class LoginAttempt {
  final String id;
  final String userId;
  final UserLocation location;
  final DateTime timestamp;
  final bool wasSuccessful;
  final String? deviceInfo;
  final String? ipAddress;

  LoginAttempt({
    required this.id,
    required this.userId,
    required this.location,
    required this.timestamp,
    required this.wasSuccessful,
    this.deviceInfo,
    this.ipAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'location': location.toMap(),
      'timestamp': timestamp.toIso8601String(),
      'wasSuccessful': wasSuccessful,
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
    };
  }

  factory LoginAttempt.fromMap(Map<String, dynamic> map) {
    return LoginAttempt(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      location: UserLocation.fromMap(map['location'] ?? {}),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      wasSuccessful: map['wasSuccessful'] ?? false,
      deviceInfo: map['deviceInfo'],
      ipAddress: map['ipAddress'],
    );
  }
}

/// Types of security alerts
enum SecurityAlertType {
  suspicious_location,
  high_amount_transaction,
  new_device_login,
  multiple_failed_attempts,
  location_change,
}

/// Represents a security alert generated by the system
class SecurityAlert {
  final String id;
  final String userId;
  final SecurityAlertType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final UserLocation? location;
  final double? transactionAmount;
  final bool isRead;

  SecurityAlert({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.location,
    this.transactionAmount,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'location': location?.toMap(),
      'transactionAmount': transactionAmount,
      'isRead': isRead,
    };
  }

  factory SecurityAlert.fromMap(Map<String, dynamic> map) {
    return SecurityAlert(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: SecurityAlertType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => SecurityAlertType.suspicious_location,
      ),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      location: map['location'] != null ? UserLocation.fromMap(map['location']) : null,
      transactionAmount: map['transactionAmount']?.toDouble(),
      isRead: map['isRead'] ?? false,
    );
  }

  SecurityAlert copyWith({
    String? id,
    String? userId,
    SecurityAlertType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    UserLocation? location,
    double? transactionAmount,
    bool? isRead,
  }) {
    return SecurityAlert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      transactionAmount: transactionAmount ?? this.transactionAmount,
      isRead: isRead ?? this.isRead,
    );
  }
}
