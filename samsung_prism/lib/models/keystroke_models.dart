/// Model classes for keystroke dynamics authentication
/// 
/// These models handle the data structures for keystroke events
/// and API communication with the Flask backend.

class KeystrokeEvent {
  final String key;
  final String event; // 'down' or 'up'
  final int timestamp;

  KeystrokeEvent({
    required this.key,
    required this.event,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'event': event,
      'timestamp': timestamp,
    };
  }

  factory KeystrokeEvent.fromJson(Map<String, dynamic> json) {
    return KeystrokeEvent(
      key: json['key'],
      event: json['event'],
      timestamp: json['timestamp'],
    );
  }

  @override
  String toString() {
    return 'KeystrokeEvent(key: $key, event: $event, timestamp: $timestamp)';
  }
}

class KeystrokeSession {
  final String userId;
  final List<KeystrokeEvent> events;
  final DateTime startTime;
  final DateTime? endTime;

  KeystrokeSession({
    required this.userId,
    required this.events,
    required this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'keystroke_data': events.map((e) => e.toJson()).toList(),
    };
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  int get eventCount => events.length;

  KeystrokeSession copyWith({
    String? userId,
    List<KeystrokeEvent>? events,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return KeystrokeSession(
      userId: userId ?? this.userId,
      events: events ?? this.events,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class TrainingResponse {
  final String status;
  final int samplesCount;
  final bool modelTrained;
  final String? message;

  TrainingResponse({
    required this.status,
    required this.samplesCount,
    required this.modelTrained,
    this.message,
  });

  factory TrainingResponse.fromJson(Map<String, dynamic> json) {
    return TrainingResponse(
      status: json['status'],
      samplesCount: json['samples_count'],
      modelTrained: json['model_trained'] ?? false,
      message: json['message'],
    );
  }

  bool get isSuccessful => status == 'Training data received';
}

class AuthenticationResponse {
  final bool authenticated;
  final String? reason;
  final double? confidenceScore;
  final String? userId;
  final String? error;

  AuthenticationResponse({
    required this.authenticated,
    this.reason,
    this.confidenceScore,
    this.userId,
    this.error,
  });

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponse(
      authenticated: json['authenticated'] ?? false,
      reason: json['reason'],
      confidenceScore: json['confidence_score']?.toDouble(),
      userId: json['user_id'],
      error: json['error'],
    );
  }

  bool get hasError => error != null;
  bool get isGenuineUser => authenticated && !hasError;
}

class UserTrainingInfo {
  final String userId;
  final int trainingSamples;
  final bool hasTrainedModel;
  final int minSamplesRequired;
  final int? maxFeatureLength;

  UserTrainingInfo({
    required this.userId,
    required this.trainingSamples,
    required this.hasTrainedModel,
    required this.minSamplesRequired,
    this.maxFeatureLength,
  });

  factory UserTrainingInfo.fromJson(Map<String, dynamic> json) {
    return UserTrainingInfo(
      userId: json['user_id'],
      trainingSamples: json['training_samples'],
      hasTrainedModel: json['has_trained_model'],
      minSamplesRequired: json['min_samples_required'],
      maxFeatureLength: json['max_feature_length'],
    );
  }

  bool get needsMoreTraining => !hasTrainedModel;
  int get remainingSamples => 
      !hasTrainedModel ? (minSamplesRequired - trainingSamples).clamp(0, minSamplesRequired) : 0;
  
  double get trainingProgress => 
      (trainingSamples / minSamplesRequired).clamp(0.0, 1.0);
}

enum KeystrokeAuthStatus {
  idle,
  recording,
  training,
  authenticating,
  success,
  failure,
  error,
}

class KeystrokeAuthState {
  final KeystrokeAuthStatus status;
  final String? message;
  final KeystrokeSession? currentSession;
  final UserTrainingInfo? userInfo;
  final AuthenticationResponse? lastAuthResult;

  const KeystrokeAuthState({
    this.status = KeystrokeAuthStatus.idle,
    this.message,
    this.currentSession,
    this.userInfo,
    this.lastAuthResult,
  });

  KeystrokeAuthState copyWith({
    KeystrokeAuthStatus? status,
    String? message,
    KeystrokeSession? currentSession,
    UserTrainingInfo? userInfo,
    AuthenticationResponse? lastAuthResult,
  }) {
    return KeystrokeAuthState(
      status: status ?? this.status,
      message: message ?? this.message,
      currentSession: currentSession ?? this.currentSession,
      userInfo: userInfo ?? this.userInfo,
      lastAuthResult: lastAuthResult ?? this.lastAuthResult,
    );
  }

  bool get isRecording => status == KeystrokeAuthStatus.recording;
  bool get isTraining => status == KeystrokeAuthStatus.training;
  bool get isAuthenticating => status == KeystrokeAuthStatus.authenticating;
  bool get isProcessing => isTraining || isAuthenticating;
  bool get hasSession => currentSession != null;
}
