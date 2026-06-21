import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapit_sdk/snapit_sdk.dart';
import 'config.dart';
import 'screens/catalog_screen.dart';
import 'screens/setup_credentials_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved credentials from local storage
  try {
    final prefs = await SharedPreferences.getInstance();
    SnapITConfig.runtimeApiKey = prefs.getString('snapit_api_key') ?? '';
    SnapITConfig.runtimeUserId = prefs.getString('snapit_user_id') ?? '';
    SnapITConfig.runtimeModelName =
        prefs.getString('snapit_model_name') ?? 'fast';
    SnapITConfig.runtimeVersion = prefs.getDouble('snapit_version') ?? 1.1;
  } catch (e) {
    debugPrint('Failed to load credentials from SharedPreferences: $e');
  }

  runApp(const FashionApp());
}

class FashionApp extends StatelessWidget {
  const FashionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AURA - SnapIT SDK Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0C),
        primaryColor: const Color(0xFFFF3F6C), // Vibrant brand pink
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF3F6C),
          secondary: Color(0xFF06B6D4), // Cyan accent
          surface: Color(0xFF16161A),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const SnapITSDKDemoScreen(),
    );
  }
}

class SnapITSDKDemoScreen extends StatefulWidget {
  const SnapITSDKDemoScreen({super.key});

  @override
  State<SnapITSDKDemoScreen> createState() => _SnapITSDKDemoScreenState();
}

class _SnapITSDKDemoScreenState extends State<SnapITSDKDemoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _apiKeyController;
  late final TextEditingController _userIdController;

  // Sample garment image URL for the try-on flow (a premium denim jacket)
  final String _sampleGarmentUrl =
      'https://images.unsplash.com/flagged/photo-1585052201332-b8c0ce30972f?q=80&w=435&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: SnapITConfig.apiKey);
    _userIdController = TextEditingController(text: SnapITConfig.userId);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  /// 🚀 Core Integration Logic
  /// This demonstrates how to invoke SnapIT.launchTryOnFlow within your app.
  void _launchVirtualTryOn() {
    if (!_formKey.currentState!.validate()) return;

    final apiKey = _apiKeyController.text.trim();
    final userId = _userIdController.text.trim();

    // Cache the credentials locally for convenience in the demo app
    _saveCredentialsToCache(apiKey, userId);

    SnapIT.launchTryOnFlow(
      context: context,
      apiKey: apiKey,
      userId: userId,
      garmentImageUrl: _sampleGarmentUrl,
      productId: 'demo_tshirt',
      modelName: SnapITConfig.modelName,
      version: SnapITConfig.version,
      metadata: const {
        'source': 'pub_dev_example_home',
        'campaign': 'example_integration',
      },
      theme: const SnapITTheme(
        primaryColor: Color(0xFFFF3F6C), // Match the brand accent color
        backgroundColor: Color(0xFF0A0A0C),
        cardColor: Color(0xFF16161A),
        borderRadius: 16.0,
      ),
      onSuccess: (resultImageUrl, generationId) {
        debugPrint('Try-On Completed! Result Image: $resultImageUrl');
        _showSuccessSnackBar(resultImageUrl);
      },
      onFailure: (errorMessage) {
        debugPrint('Try-On Failed: $errorMessage');
        _showErrorDialog(errorMessage);
      },
    );
  }

  Future<void> _saveCredentialsToCache(String apiKey, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('snapit_api_key', apiKey);
      await prefs.setString('snapit_user_id', userId);
      SnapITConfig.runtimeApiKey = apiKey;
      SnapITConfig.runtimeUserId = userId;
    } catch (e) {
      debugPrint('Failed to cache credentials: $e');
    }
  }

  void _showSuccessSnackBar(String resultUrl) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Success! Generation completed.',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16161A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16161A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'VTON Error',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToStoreDemo() {
    final apiKey = _apiKeyController.text.trim();
    final userId = _userIdController.text.trim();
    if (apiKey.isNotEmpty && userId.isNotEmpty) {
      _saveCredentialsToCache(apiKey, userId);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CatalogScreen()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SetupCredentialsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF1F121F), // Subtle purple atmosphere glow
              Color(0xFF0A0A0C),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title / Branding
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'S N A P I T',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'VIRTUAL TRY-ON SDK DEMO',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Garment Showcase Card
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(_sampleGarmentUrl),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black87,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.6),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'PREMIUM GARMENT',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Elegant Green A-Line Dress',
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sample item powered by Snapmydesign API',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // API Credentials Form
                  Text(
                    'SDK CONFIGURATION',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // API Key Field
                  TextFormField(
                    controller: _apiKeyController,
                    style:
                        GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'smd_live_...',
                      labelText: 'API KEY',
                      labelStyle: GoogleFonts.outfit(
                          color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF16161A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.vpn_key_outlined,
                          color: Colors.white30, size: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your SMD API Key';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // User ID Field
                  TextFormField(
                    controller: _userIdController,
                    style:
                        GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Your Dashboard User ID',
                      labelText: 'USER ID',
                      labelStyle: GoogleFonts.outfit(
                          color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF16161A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          color: Colors.white30, size: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your User ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Big Glowing VTON Try-On Button
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          const Color(0xFFEC4899), // Pink to Rose gradient
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _launchVirtualTryOn,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: Text(
                        'LAUNCH VIRTUAL TRY-ON',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white12)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'OR EXPLORE',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white30,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white12)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Secondary Button: Advanced Store Demo
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _navigateToStoreDemo,
                    icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                    label: Text(
                      'BROWSE FULL STORE DEMO',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
