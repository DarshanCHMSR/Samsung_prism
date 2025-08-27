import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/keystroke_auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/keystroke_recorder.dart';
import '../../models/keystroke_models.dart';
import 'signup_screen.dart';

class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _useKeystrokeDynamics = false;
  KeystrokeSession? _passwordKeystrokeSession;

  @override
  void initState() {
    super.initState();
    _initializeKeystrokeAuth();
  }

  void _initializeKeystrokeAuth() async {
    final keystrokeProvider = Provider.of<KeystrokeAuthProvider>(context, listen: false);
    await keystrokeProvider.loadConfiguration();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final keystrokeProvider = Provider.of<KeystrokeAuthProvider>(context, listen: false);
      
      // Step 1: Traditional email/password authentication
      final traditionalAuthSuccess = await authProvider.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!traditionalAuthSuccess) {
        if (mounted) {
          _showError(authProvider.errorMessage ?? 'Login failed');
        }
        return;
      }

      // Step 2: Keystroke dynamics authentication (if enabled)
      if (_useKeystrokeDynamics) {
        final userId = authProvider.user?.uid ?? _emailController.text.trim();
        
        // Check if keystroke service is configured
        if (!keystrokeProvider.isConfigured) {
          // First time setup - redirect to keystroke setup
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/keystroke-setup');
          }
          return;
        }
        
        // Check if we have keystroke data
        if (_passwordKeystrokeSession == null) {
          _showError('Please type your password to record keystroke pattern.');
          await authProvider.signOut(); // Sign out from traditional auth
          return;
        }
        
        try {
          // Check if user needs training first
          await keystrokeProvider.loadUserInfo(userId);
          
          if (keystrokeProvider.needsTraining(userId)) {
            // User needs training, redirect to setup
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/keystroke-setup');
            }
            return;
          }

          // Authenticate with keystroke dynamics
          final keystrokeAuthSuccess = await keystrokeProvider.authenticateUser(
            userId,
            session: _passwordKeystrokeSession,
          );

          if (!keystrokeAuthSuccess) {
            // Keystroke authentication failed
            await authProvider.signOut(); // Sign out from traditional auth
            if (mounted) {
              _showError('Keystroke pattern verification failed. Please try again.');
            }
            return;
          }
        } catch (e) {
          // Keystroke authentication error, but allow traditional login for now
          print('Keystroke authentication error: $e');
          _showError('Keystroke authentication error: ${e.toString()}. Proceeding with traditional login.');
        }
      }

      // Success - navigate to home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _onKeystrokeSessionComplete(KeystrokeSession session) {
    setState(() {
      _passwordKeystrokeSession = session.copyWith(
        userId: _emailController.text.trim(),
      );
    });
  }

  Widget _buildKeystrokeStatus() {
    return Consumer<KeystrokeAuthProvider>(
      builder: (context, keystrokeProvider, child) {
        String status;
        Color color;
        IconData icon;
        
        if (!keystrokeProvider.isConfigured) {
          status = 'Keystroke recording enabled - Setup required';
          color = AppColors.warning;
          icon = Icons.warning_amber;
        } else {
          status = keystrokeProvider.getStatusMessage();
          color = keystrokeProvider.getStatusColor();
          icon = _getStatusIcon(keystrokeProvider.state.status);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(KeystrokeAuthStatus status) {
    switch (status) {
      case KeystrokeAuthStatus.idle:
        return Icons.security;
      case KeystrokeAuthStatus.recording:
        return Icons.fiber_manual_record;
      case KeystrokeAuthStatus.training:
      case KeystrokeAuthStatus.authenticating:
        return Icons.hourglass_empty;
      case KeystrokeAuthStatus.success:
        return Icons.check_circle;
      case KeystrokeAuthStatus.failure:
      case KeystrokeAuthStatus.error:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlue.withOpacity(0.8),
              AppColors.secondaryBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Samsung Prism',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Secure Financial Management',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field with Keystroke Recording
                          Consumer<KeystrokeAuthProvider>(
                            builder: (context, keystrokeProvider, child) {
                              if (_useKeystrokeDynamics) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Password (with keystroke verification)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    PasswordKeystrokeRecorder(
                                      onSessionComplete: _onKeystrokeSessionComplete,
                                      hintText: 'Enter your password',
                                      enabled: !keystrokeProvider.state.isProcessing,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildKeystrokeStatus(),
                                  ],
                                );
                              } else {
                                return TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Keystroke Dynamics Toggle
                          Consumer<KeystrokeAuthProvider>(
                            builder: (context, keystrokeProvider, child) {
                              if (keystrokeProvider.isConfigured) {
                                return CheckboxListTile(
                                  value: _useKeystrokeDynamics,
                                  onChanged: (value) {
                                    setState(() {
                                      _useKeystrokeDynamics = value ?? false;
                                    });
                                  },
                                  title: const Text(
                                    'Enable Keystroke Verification',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  subtitle: const Text(
                                    'Additional security through typing pattern analysis',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                );
                              } else {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Keystroke Verification Unavailable',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.amber[700],
                                              ),
                                            ),
                                            Text(
                                              'Server not configured. Go to Settings to connect.',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.amber[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/keystroke-setup');
                                        },
                                        child: const Text('Setup', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          Consumer2<AuthProvider, KeystrokeAuthProvider>(
                            builder: (context, authProvider, keystrokeProvider, child) {
                              final isLoading = authProvider.isLoading || keystrokeProvider.state.isProcessing;
                              
                              return ElevatedButton(
                                onPressed: isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Forgot Password
                          TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.poppins(
                                  color: AppColors.textGrey,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
