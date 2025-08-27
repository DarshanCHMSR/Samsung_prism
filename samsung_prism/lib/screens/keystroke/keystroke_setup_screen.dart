import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/keystroke_auth_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/keystroke_recorder.dart';
import '../../models/keystroke_models.dart';

class KeystrokeSetupScreen extends StatefulWidget {
  const KeystrokeSetupScreen({super.key});

  @override
  State<KeystrokeSetupScreen> createState() => _KeystrokeSetupScreenState();
}

class _KeystrokeSetupScreenState extends State<KeystrokeSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _trainingPasswordController = TextEditingController();
  
  int _currentStep = 0;
  int _trainingSamplesCollected = 0;
  final int _requiredSamples = 5;
  List<KeystrokeSession> _trainingSessions = [];
  bool _isTraining = false;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  void _loadConfiguration() async {
    final keystrokeProvider = Provider.of<KeystrokeAuthProvider>(context, listen: false);
    await keystrokeProvider.loadConfiguration();
    
    if (keystrokeProvider.isConfigured && keystrokeProvider.serverIp != null) {
      _serverUrlController.text = 'http://${keystrokeProvider.serverIp}:5000';
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _trainingPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    final keystrokeProvider = Provider.of<KeystrokeAuthProvider>(context, listen: false);
    
    setState(() {
      _isTraining = true;
    });

    try {
      // Parse URL to extract server IP
      final uri = Uri.parse(_serverUrlController.text.trim());
      final serverIp = uri.host;
      final port = uri.port != 0 ? uri.port : 5000;
      final useHttps = uri.scheme == 'https';
      
      // Test server connection
      await keystrokeProvider.configure(
        serverIp: serverIp,
        port: port,
        useHttps: useHttps,
      );
      
      if (keystrokeProvider.isConfigured) {
        _showMessage('Server connection successful!', isError: false);
        _nextStep();
      } else {
        _showMessage('Failed to connect to server. Please check the URL.', isError: true);
      }
    } catch (e) {
      _showMessage('Connection error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isTraining = false;
      });
    }
  }

  void _trainModel() async {
    final keystrokeProvider = Provider.of<KeystrokeAuthProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final userId = authProvider.user?.uid ?? 'demo_user';
    
    setState(() {
      _isTraining = true;
    });

    try {
      // Train the model with collected samples
      for (final session in _trainingSessions) {
        await keystrokeProvider.trainUser(userId, session: session);
      }
      
      if (keystrokeProvider.state.status != KeystrokeAuthStatus.error) {
        _showMessage('Model training completed successfully!', isError: false);
        
        // Navigate back to login
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/enhanced-login');
        }
      } else {
        _showMessage('Model training failed. Please try again.', isError: true);
      }
    } catch (e) {
      _showMessage('Training error: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isTraining = false;
      });
    }
  }

  void _onKeystrokeSessionComplete(KeystrokeSession session) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid ?? 'demo_user';
    
    final sessionWithUser = session.copyWith(userId: userId);
    _trainingSessions.add(sessionWithUser);
    
    setState(() {
      _trainingSamplesCollected = _trainingSessions.length;
    });

    if (_trainingSamplesCollected >= _requiredSamples) {
      _showMessage('All training samples collected!', isError: false);
      _nextStep();
    } else {
      _showMessage('Sample ${_trainingSamplesCollected}/$_requiredSamples collected. Please type the password again.', isError: false);
      _trainingPasswordController.clear();
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentStep ? AppColors.primaryBlue : AppColors.textLight,
          ),
        );
      }),
    );
  }

  Widget _buildServerConfigurationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Server Configuration',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure the keystroke authentication server URL',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _serverUrlController,
                decoration: InputDecoration(
                  labelText: 'Server URL',
                  hintText: 'http://localhost:5000',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter server URL';
                  }
                  try {
                    Uri.parse(value.trim());
                    return null;
                  } catch (e) {
                    return 'Please enter a valid URL';
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isTraining ? null : _testConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isTraining
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Test Connection',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingDataStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collect Training Data',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Type your password $_requiredSamples times to train the keystroke model',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 24),
        
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.keyboard,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Training Progress',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '$_trainingSamplesCollected / $_requiredSamples samples collected',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: _trainingSamplesCollected / _requiredSamples,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        if (_trainingSamplesCollected < _requiredSamples) ...[
          KeystrokeRecorder(
            onSessionComplete: _onKeystrokeSessionComplete,
            hintText: 'Type your password to record timing pattern',
            obscureText: true,
          ),
          const SizedBox(height: 16),
          Text(
            'Type naturally as you would during normal login. The system will record your keystroke timing patterns.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textGrey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All training samples collected successfully!',
                    style: GoogleFonts.poppins(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proceed to Training',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModelTrainingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Train Model',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Train the machine learning model with your keystroke patterns',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.psychology,
                size: 64,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                'Ready to Train',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your keystroke patterns have been collected. Click below to train the authentication model.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isTraining ? null : _trainModel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isTraining
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Training Model...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Train Model',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/enhanced-login');
            },
            child: Text(
              'Skip for now',
              style: GoogleFonts.poppins(
                color: AppColors.textGrey,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Keystroke Setup',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Consumer<KeystrokeAuthProvider>(
                      builder: (context, keystrokeProvider, child) {
                        switch (_currentStep) {
                          case 0:
                            return _buildServerConfigurationStep();
                          case 1:
                            return _buildTrainingDataStep();
                          case 2:
                            return _buildModelTrainingStep();
                          default:
                            return _buildServerConfigurationStep();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: _previousStep,
                        child: Text(
                          'Previous',
                          style: GoogleFonts.poppins(
                            color: AppColors.textGrey,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    
                    Text(
                      'Step ${_currentStep + 1} of 3',
                      style: GoogleFonts.poppins(
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox.shrink(), // Placeholder for symmetry
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
