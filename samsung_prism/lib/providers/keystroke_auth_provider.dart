import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/keystroke_models.dart';
import '../services/keystroke_auth_service.dart';

/// Provider class for managing keystroke dynamics authentication state
/// 
/// This provider handles the complete flow of keystroke authentication:
/// - Recording keystroke patterns
/// - Training user models
/// - Authenticating users
/// - Managing authentication state
class KeystrokeAuthProvider extends ChangeNotifier {
  final KeystrokeAuthService _service;
  KeystrokeAuthState _state = const KeystrokeAuthState();
  
  // Configuration
  String? _serverIp;
  bool _isConfigured = false;

  KeystrokeAuthProvider({KeystrokeAuthService? service})
      : _service = service ?? KeystrokeAuthService();

  KeystrokeAuthState get state => _state;
  bool get isConfigured => _isConfigured;
  String? get serverIp => _serverIp;

  /// Configure the service with server details
  Future<void> configure({
    required String serverIp,
    int port = 5000,
    bool useHttps = false,
  }) async {
    try {
      _serverIp = serverIp;
      
      // Create new service with configuration
      final newService = KeystrokeAuthService.configure(
        serverIp: serverIp,
        port: port,
        useHttps: useHttps,
      );

      // Test connection
      final isConnected = await newService.testConnection();
      _isConfigured = isConnected;

      if (_isConfigured) {
        // Save configuration
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('keystroke_server_ip', serverIp);
        await prefs.setInt('keystroke_server_port', port);
        await prefs.setBool('keystroke_use_https', useHttps);

        _updateState(
          status: KeystrokeAuthStatus.idle,
          message: 'Connected to server successfully',
        );
      } else {
        _updateState(
          status: KeystrokeAuthStatus.error,
          message: 'Failed to connect to server',
        );
      }
    } catch (e) {
      _isConfigured = false;
      _updateState(
        status: KeystrokeAuthStatus.error,
        message: 'Configuration error: $e',
      );
    }
    notifyListeners();
  }

  /// Load saved configuration
  Future<void> loadConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serverIp = prefs.getString('keystroke_server_ip');
      final port = prefs.getInt('keystroke_server_port') ?? 5000;
      final useHttps = prefs.getBool('keystroke_use_https') ?? false;

      if (serverIp != null) {
        await configure(
          serverIp: serverIp,
          port: port,
          useHttps: useHttps,
        );
      }
    } catch (e) {
      print('Failed to load configuration: $e');
    }
  }

  /// Start recording a keystroke session
  void startRecording(String userId) {
    final session = KeystrokeSession(
      userId: userId,
      events: [],
      startTime: DateTime.now(),
    );

    _updateState(
      status: KeystrokeAuthStatus.recording,
      currentSession: session,
      message: 'Recording keystroke pattern...',
    );
  }

  /// Add a keystroke event to the current session
  void addKeystrokeEvent(KeystrokeEvent event) {
    if (_state.currentSession == null) return;

    final updatedEvents = [..._state.currentSession!.events, event];
    final updatedSession = _state.currentSession!.copyWith(
      events: updatedEvents,
    );

    _updateState(currentSession: updatedSession);
  }

  /// Complete the current recording session
  void completeSession(KeystrokeSession session) {
    final completedSession = session.copyWith(
      endTime: DateTime.now(),
    );

    _updateState(
      status: KeystrokeAuthStatus.idle,
      currentSession: completedSession,
      message: 'Keystroke pattern recorded successfully',
    );
  }

  /// Train the user model with the current session
  Future<void> trainUser(String userId, {KeystrokeSession? session}) async {
    if (!_isConfigured) {
      _updateState(
        status: KeystrokeAuthStatus.error,
        message: 'Service not configured. Please connect to server first.',
      );
      return;
    }

    final trainingSession = session ?? _state.currentSession;
    if (trainingSession == null || trainingSession.events.isEmpty) {
      _updateState(
        status: KeystrokeAuthStatus.error,
        message: 'No keystroke data available for training',
      );
      return;
    }

    try {
      _updateState(
        status: KeystrokeAuthStatus.training,
        message: 'Training model...',
      );

      final response = await _service.trainUser(
        userId: userId,
        keystrokeData: trainingSession.events,
      );

      if (response.isSuccessful) {
        // Get updated user info
        final userInfo = await _service.getUserInfo(userId);
        
        _updateState(
          status: KeystrokeAuthStatus.success,
          message: response.modelTrained
              ? 'Model trained successfully!'
              : 'Training data added. ${userInfo.remainingSamples} more samples needed.',
          userInfo: userInfo,
          currentSession: null, // Clear session after successful training
        );
      } else {
        _updateState(
          status: KeystrokeAuthStatus.error,
          message: response.message ?? 'Training failed',
        );
      }
    } catch (e) {
      _updateState(
        status: KeystrokeAuthStatus.error,
        message: 'Training error: $e',
      );
    }
  }

  /// Authenticate user with the current session
  Future<bool> authenticateUser(String userId, {KeystrokeSession? session}) async {
    if (!_isConfigured) {
      _updateState(
        status: KeystrokeAuthStatus.error,
        message: 'Service not configured. Please connect to server first.',
      );
      return false;
    }

    final authSession = session ?? _state.currentSession;
    if (authSession == null || authSession.events.isEmpty) {
      _updateState(
        status: KeystrokeAuthStatus.error,
        message: 'No keystroke data available for authentication',
      );
      return false;
    }

    try {
      _updateState(
        status: KeystrokeAuthStatus.authenticating,
        message: 'Authenticating...',
      );

      final response = await _service.authenticateUser(
        userId: userId,
        keystrokeData: authSession.events,
      );

      _updateState(
        status: response.isGenuineUser 
            ? KeystrokeAuthStatus.success 
            : KeystrokeAuthStatus.failure,
        message: response.isGenuineUser
            ? 'Authentication successful!'
            : response.reason ?? 'Authentication failed',
        lastAuthResult: response,
        currentSession: null, // Clear session after authentication attempt
      );

      return response.isGenuineUser;
    } catch (e) {
      _updateState(
        status: KeystrokeAuthStatus.error,
        message: 'Authentication error: $e',
        lastAuthResult: AuthenticationResponse(
          authenticated: false,
          error: e.toString(),
        ),
      );
      return false;
    }
  }

  /// Get user training information
  Future<void> loadUserInfo(String userId) async {
    if (!_isConfigured) return;

    try {
      final userInfo = await _service.getUserInfo(userId);
      _updateState(userInfo: userInfo);
    } catch (e) {
      print('Failed to load user info: $e');
    }
  }

  /// Check if user needs more training data
  bool needsTraining(String userId) {
    return _state.userInfo?.needsMoreTraining ?? true;
  }

  /// Get training progress (0.0 to 1.0)
  double getTrainingProgress() {
    return _state.userInfo?.trainingProgress ?? 0.0;
  }

  /// Reset the current state
  void reset() {
    _updateState(
      status: KeystrokeAuthStatus.idle,
      message: null,
      currentSession: null,
      lastAuthResult: null,
    );
  }

  /// Clear all data for a user (for testing purposes)
  void clearUserData() {
    _updateState(
      userInfo: null,
      currentSession: null,
      lastAuthResult: null,
    );
  }

  /// Test connection to the server
  Future<bool> testConnection() async {
    try {
      return await _service.healthCheck();
    } catch (e) {
      return false;
    }
  }

  void _updateState({
    KeystrokeAuthStatus? status,
    String? message,
    KeystrokeSession? currentSession,
    UserTrainingInfo? userInfo,
    AuthenticationResponse? lastAuthResult,
  }) {
    _state = _state.copyWith(
      status: status,
      message: message,
      currentSession: currentSession,
      userInfo: userInfo,
      lastAuthResult: lastAuthResult,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

/// Extension methods for convenient access to common operations
extension KeystrokeAuthProviderExtensions on KeystrokeAuthProvider {
  /// Check if the user can proceed with authentication
  bool canAuthenticate(String userId) {
    return _isConfigured && 
           (_state.userInfo?.hasTrainedModel ?? false) &&
           !_state.isProcessing;
  }

  /// Check if the user can add more training data
  bool canTrain() {
    return _isConfigured && !_state.isProcessing;
  }

  /// Get a user-friendly status message
  String getStatusMessage() {
    switch (_state.status) {
      case KeystrokeAuthStatus.idle:
        return 'Ready';
      case KeystrokeAuthStatus.recording:
        return 'Recording typing pattern...';
      case KeystrokeAuthStatus.training:
        return 'Training model...';
      case KeystrokeAuthStatus.authenticating:
        return 'Verifying identity...';
      case KeystrokeAuthStatus.success:
        return _state.message ?? 'Success';
      case KeystrokeAuthStatus.failure:
        return _state.message ?? 'Authentication failed';
      case KeystrokeAuthStatus.error:
        return _state.message ?? 'An error occurred';
    }
  }

  /// Get appropriate color for current status
  Color getStatusColor() {
    switch (_state.status) {
      case KeystrokeAuthStatus.idle:
        return const Color(0xFF2196F3); // Blue
      case KeystrokeAuthStatus.recording:
        return const Color(0xFFFF9800); // Orange
      case KeystrokeAuthStatus.training:
      case KeystrokeAuthStatus.authenticating:
        return const Color(0xFF2196F3); // Blue
      case KeystrokeAuthStatus.success:
        return const Color(0xFF4CAF50); // Green
      case KeystrokeAuthStatus.failure:
      case KeystrokeAuthStatus.error:
        return const Color(0xFFF44336); // Red
    }
  }
}
