import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'catalog_screen.dart';

class SetupCredentialsScreen extends StatefulWidget {
  const SetupCredentialsScreen({super.key});

  @override
  State<SetupCredentialsScreen> createState() => _SetupCredentialsScreenState();
}

class _SetupCredentialsScreenState extends State<SetupCredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _apiKeyController;
  late final TextEditingController _userIdController;
  late final TextEditingController _versionController;
  String _selectedModel = 'fast';
  bool _isLoading = false;
  bool _isAutofilledFromCache = false;

  @override
  void initState() {
    super.initState();
    // Check if the credentials came from SharedPreferences cache
    _isAutofilledFromCache = SnapITConfig.runtimeApiKey.isNotEmpty || 
                             SnapITConfig.runtimeUserId.isNotEmpty;

    _apiKeyController = TextEditingController(text: SnapITConfig.apiKey);
    _userIdController = TextEditingController(text: SnapITConfig.userId);
    _selectedModel = SnapITConfig.modelName;
    _versionController = TextEditingController(text: SnapITConfig.version.toString());
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _userIdController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final apiKey = _apiKeyController.text.trim();
    final userId = _userIdController.text.trim();
    final modelName = _selectedModel;
    final version = double.tryParse(_versionController.text.trim()) ?? 1.1;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('snapit_api_key', apiKey);
      await prefs.setString('snapit_user_id', userId);
      await prefs.setString('snapit_model_name', modelName);
      await prefs.setDouble('snapit_version', version);

      // Update runtime config
      SnapITConfig.runtimeApiKey = apiKey;
      SnapITConfig.runtimeUserId = userId;
      SnapITConfig.runtimeModelName = modelName;
      SnapITConfig.runtimeVersion = version;

      if (mounted) {
        // Navigate to CatalogScreen and clear history
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CatalogScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving credentials: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Aura Logo Branding
                  Center(
                    child: Text(
                      'A U R A',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      height: 2,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Header title
                  Text(
                    'Configure SDK',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enter your SnapIT API Key and User ID to enable the virtual try-on features.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_isAutofilledFromCache) ...[
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2E1E), // Subtle dark forest green
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Autofilled from cache',
                              style: TextStyle(
                                color: Colors.green[300],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const SizedBox(height: 16),
                  ],

                  // API Key Field
                  const Text(
                    'API KEY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _apiKeyController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'smd_...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: const Color(0xFF16161A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                      prefixIcon: const Icon(Icons.vpn_key_outlined, color: Colors.white30, size: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'API Key is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // User ID Field
                  const Text(
                    'USER ID',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _userIdController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter your User ID',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: const Color(0xFF16161A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.white30, size: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'User ID is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Model Selection
                  const Text(
                    'MODEL QUALITY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildModelOption('fast', 'Fast', Icons.speed_rounded),
                      const SizedBox(width: 12),
                      _buildModelOption('medium', 'Medium', Icons.balance_rounded),
                      const SizedBox(width: 12),
                      _buildModelOption('quality', 'Quality', Icons.high_quality_rounded),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // SDK Version Field
                  const Text(
                    'SDK VERSION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _versionController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'e.g. 1.1',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: const Color(0xFF16161A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                      prefixIcon: const Icon(Icons.code_rounded, color: Colors.white30, size: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Version is required';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Please enter a valid float/decimal number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // Save & Continue Button
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _saveAndContinue,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'SAVE & CONTINUE',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
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

  Widget _buildModelOption(String value, String label, IconData icon) {
    final isSelected = _selectedModel == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedModel = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.15) : const Color(0xFF16161A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.white.withValues(alpha: 0.05),
              width: 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.white38,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white38,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
