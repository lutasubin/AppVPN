import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/controllers/main_controller/splash/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final Animation<double> _logoAnimation;
  late final Animation<double> _textFade;
  late final Animation<double> _textScale;

  late final SplashController splashController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeController();
  }

  void _initializeAnimations() {
    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _logoAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoController.forward();

    // Text animations
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    // Start text animation after 1s
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _textController.forward();
    });
  }

  void _initializeController() {
    splashController = Get.find<SplashController>();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    // Không cần delete controller vì nó là permanent
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02091A),
      body: Stack(
        children: [
          _buildCenterContent(),
          _buildBottomContent(),
        ],
      ),
    );
  }

  Widget _buildCenterContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _logoAnimation,
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 86,
              height: 86,
            ),
          ),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _textScale,
            child: FadeTransition(
              opacity: _textFade,
              child: const Text(
                'Free VPN Fast & Safe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContent() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          color: const Color(0xFF02091A),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                backgroundColor: Color(0xFF767C8A),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFF15E24),
                ),
                minHeight: 8,
              ),
              SizedBox(height: 10),
              Text(
                'This action can contain ads',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
