import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'firebase_options.dart';

// ==================== APP COLORS ====================

class AppColors {
  static const background = Color(0xFF0B1220);
  static const surface = Color(0xFF111C2E);
  static const surfaceLight = Color(0xFF17253A);

  static const primary = Color(0xFF38BDF8);
  static const secondary = Color(0xFF60A5FA);

  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFF87171);

  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eight GPS',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.surface,
          elevation: 0,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return const HomePage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}

// ==================== LOGIN PAGE ====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSignUp = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Store user info in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'email': _emailController.text.trim(),
          'createdAt': DateTime.now(),
          'displayName': 'User ${DateTime.now().millisecondsSinceEpoch}',
        });
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Authentication failed';
      });
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eight GPS App'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.location_on,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 30),
            Text(
              _isSignUp ? 'Create Account' : 'Welcome Back',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_isSignUp ? 'Sign Up' : 'Login'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => _isSignUp = !_isSignUp);
              },
              child: Text(
                _isSignUp
                    ? 'Already have an account? Login'
                    : 'Don\'t have an account? Sign up',
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Demo Credentials:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Email: demo@example.com'),
            const Text('Password: demo123456'),
          ],
        ),
      ),
    );
  }
}

// ==================== HOME PAGE ====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CameraSensorsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // Keeps each page alive when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 70,

              // Dark navigation bar
              backgroundColor: AppColors.surface,

              // Background behind selected icon
              indicatorColor: AppColors.surfaceLight,

              // Selected/unselected icon colors
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(
                      color: AppColors.primary,
                      size: 25,
                    );
                  }

                  return const IconThemeData(
                    color: AppColors.textSecondary,
                    size: 23,
                  );
                },
              ),

              // Text colors
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    );
                  }

                  return const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  );
                },
              ),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sensors_outlined),
                  selectedIcon: Icon(Icons.sensors),
                  label: 'Sensors',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== DASHBOARD PAGE ====================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      const String lat = '13.7563';
      const String lon = '100.5018';

      final response = await http
          .get(
            Uri.parse(
              'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load weather data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to connect to weather service';
        _isLoading = false;
      });
    }
  }

  String _getWeatherDescription(int code) {
    const weatherDescriptions = {
      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Foggy',
      48: 'Foggy',
      51: 'Light drizzle',
      53: 'Moderate drizzle',
      55: 'Dense drizzle',
      61: 'Slight rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      71: 'Slight snow',
      73: 'Moderate snow',
      75: 'Heavy snow',
      80: 'Slight rain showers',
      81: 'Moderate rain showers',
      82: 'Violent rain showers',
      85: 'Slight snow showers',
      86: 'Heavy snow showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with hail',
      99: 'Thunderstorm with hail',
    };

    return weatherDescriptions[code] ?? 'Unknown';
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) {
      return Icons.wb_sunny_rounded;
    } else if (code <= 3) {
      return Icons.cloud_rounded;
    } else if (code <= 48) {
      return Icons.foggy;
    } else if (code <= 67 || code <= 82) {
      return Icons.water_drop_rounded;
    } else if (code <= 86) {
      return Icons.ac_unit_rounded;
    } else {
      return Icons.thunderstorm_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchWeatherData,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== HEADER ====================

                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    final user = snapshot.data;

                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back 👋',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user?.email?.split('@').first ?? 'User',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Profile icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.surfaceLight,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                            size: 25,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),

                // ==================== WEATHER HEADER ====================

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Current Weather',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 15,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Bangkok',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==================== WEATHER CARD ====================

                _buildWeatherCard(),

                const SizedBox(height: 28),

                // ==================== FEATURES ====================

                const Text(
                  'Features',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Access your device capabilities',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.camera_alt_rounded,
                        title: 'Camera',
                        description: 'Photos & videos',
                        iconColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.location_on_rounded,
                        title: 'GPS',
                        description: 'Live location',
                        iconColor: AppColors.success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.sensors_rounded,
                        title: 'Gyroscope',
                        description: 'Motion data',
                        iconColor: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FeatureCard(
                        icon: Icons.speed_rounded,
                        title: 'Sensors',
                        description: 'Device status',
                        iconColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== WEATHER CARD ====================

  Widget _buildWeatherCard() {
    if (_isLoading) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            IconButton(
              onPressed: _fetchWeatherData,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) {
      return const SizedBox();
    }

    final current = _weatherData!['current'];

    final double temperature = (current['temperature_2m'] as num).toDouble();

    final double windSpeed = (current['wind_speed_10m'] as num).toDouble();

    final int weatherCode = current['weather_code'] as int;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF172A46),
            Color(0xFF102039),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weather icon + temperature

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _getWeatherIcon(weatherCode),
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              IconButton(
                onPressed: _fetchWeatherData,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${temperature.toStringAsFixed(0)}°',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'C',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            _getWeatherDescription(weatherCode),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            height: 1,
            color: AppColors.surfaceLight,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(
                Icons.air_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Wind',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${windSpeed.toStringAsFixed(1)} km/h',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== FEATURE CARD ====================

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CAMERA & SENSORS PAGE ====================
class CameraSensorsPage extends StatefulWidget {
  const CameraSensorsPage({super.key});

  @override
  State<CameraSensorsPage> createState() => _CameraSensorsPageState();
}

class _CameraSensorsPageState extends State<CameraSensorsPage> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;

  XFile? _capturedPhoto;

  Position? _currentPosition;
  String _gpsStatus = 'Loading GPS...';

  List<double> _gyroscope = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    _initializeSensors();
  }

  void _initializeSensors() {
    gyroscopeEvents.listen((GyroscopeEvent event) {
      if (!mounted) return;

      setState(() {
        _gyroscope = [event.x, event.y, event.z];
      });
    });

    _getCurrentLocation();
  }

  // ==================== GPS ====================

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _gpsStatus = 'Getting your location...';
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _gpsStatus = 'Location services disabled';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _gpsStatus = 'Location permission denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _gpsStatus = 'Location updated';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _gpsStatus = 'Unable to get location';
      });
    }
  }

  // ==================== VIDEO ====================

  Future<void> _initializeVideo(String path) async {
    await _videoController?.dispose();

    if (kIsWeb) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(path));
    } else {
      _videoController = VideoPlayerController.file(File(path));
    }

    try {
      await _videoController!.initialize();

      if (!mounted) return;

      setState(() {});

      _videoController!.play();
    } catch (e) {
      debugPrint('Video initialization error: $e');
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final XFile? pickedVideo = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (pickedVideo != null) {
      await _initializeVideo(pickedVideo.path);
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (video == null) return;

      await _initializeVideo(video.path);

      if (!mounted) return;

      setState(() {
        _capturedPhoto = null;
      });
    } catch (e) {
      debugPrint('VIDEO ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to record video: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== HEADER ====================

              const Text(
                'Sensors',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Camera, GPS and device motion',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 28),

              // ==================== CAMERA ====================

              _buildSectionHeader(
                icon: Icons.videocam_rounded,
                title: 'Camera & Video',
                color: AppColors.primary,
              ),

              const SizedBox(height: 12),

              _buildVideoCard(),

              const SizedBox(height: 28),

              // ==================== GPS ====================

              _buildSectionHeader(
                icon: Icons.location_on_rounded,
                title: 'GPS Location',
                color: AppColors.success,
              ),

              const SizedBox(height: 12),

              _buildGPSCard(),

              const SizedBox(height: 28),

              // ==================== GYROSCOPE ====================

              _buildSectionHeader(
                icon: Icons.sensors_rounded,
                title: 'Gyroscope',
                color: AppColors.secondary,
              ),

              const SizedBox(height: 12),

              _buildGyroscopeCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SECTION HEADER ====================

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==================== VIDEO CARD ====================

  Widget _buildVideoCard() {
    final hasVideo =
        _videoController != null && _videoController!.value.isInitialized;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.surfaceLight,
        ),
      ),
      child: Column(
        children: [
          // MEDIA PREVIEW
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: Container(
              height: 220,
              width: double.infinity,
              color: Colors.black,
              child: _capturedPhoto != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(_capturedPhoto!.path),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.photo_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : hasVideo
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(
                                  _videoController!,
                                ),
                              ),
                            ),
                            VideoProgressIndicator(
                              _videoController!,
                              allowScrubbing: true,
                              padding: EdgeInsets.zero,
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (_videoController!.value.isPlaying) {
                                        _videoController!.pause();
                                      } else {
                                        _videoController!.play();
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    _videoController!.value.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.video_library_outlined,
                                color: AppColors.textSecondary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No photo or video selected',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
            ),
          ),

          // BUTTONS

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.videocam_rounded,
                    label: 'Record Video',
                    color: AppColors.primary,
                    onPressed: _recordVideo,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.video_library_rounded,
                    label: 'Choose Video',
                    color: AppColors.secondary,
                    onPressed: _pickVideoFromGallery,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== GPS CARD ====================

  Widget _buildGPSCard() {
    final position = _currentPosition;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.surfaceLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: AppColors.success,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Location',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _gpsStatus,
                      style: TextStyle(
                        color: position != null
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _getCurrentLocation,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (position != null) ...[
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: AppColors.surfaceLight,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildGPSValue(
                    label: 'Latitude',
                    value: position.latitude.toStringAsFixed(6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGPSValue(
                    label: 'Longitude',
                    value: position.longitude.toStringAsFixed(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGPSValue(
                    label: 'Altitude',
                    value: '${position.altitude.toStringAsFixed(2)} m',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGPSValue(
                    label: 'Accuracy',
                    value: '${position.accuracy.toStringAsFixed(2)} m',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGPSValue({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== GYROSCOPE CARD ====================

  Widget _buildGyroscopeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.surfaceLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.rotate_right_rounded,
                  color: AppColors.secondary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Rotation',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Live gyroscope data',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: AppColors.success,
                      size: 7,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildGyroValue(
                  axis: 'X',
                  value: _gyroscope[0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildGyroValue(
                  axis: 'Y',
                  value: _gyroscope[1],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildGyroValue(
                  axis: 'Z',
                  value: _gyroscope[2],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGyroValue({
    required String axis,
    required double value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            axis,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'rad/s',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTION BUTTON ====================

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 19,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== PROFILE PAGE ====================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          _userData = doc.data();
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userData?['displayName'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? 'No email',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // User Information
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: 'Email',
                      value: user?.email ?? 'N/A',
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'User ID',
                      value: user?.uid.substring(0, 12) ?? 'N/A',
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'Account Created',
                      value: _userData?['createdAt'] != null
                          ? _userData!['createdAt']
                              .toDate()
                              .toString()
                              .split('.')[0]
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Info
            const Text(
              'App Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: 'App Name',
                      value: 'Eight GPS',
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'Version',
                      value: '1.0.0',
                    ),
                    const Divider(),
                    _InfoRow(
                      label: 'Platform',
                      value: kIsWeb ? 'Web' : 'Mobile',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
