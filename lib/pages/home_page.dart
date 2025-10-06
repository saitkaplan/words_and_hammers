import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:words_and_hammers/pages/level_page.dart';
import 'package:words_and_hammers/backops/language_manager.dart';
import 'package:words_and_hammers/backops/translations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _formAnimationController;
  late AnimationController _textTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _formOpacityAnimation;
  late Animation<double> _textOpacityAnimation;

  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = false;
  bool _autoLogin = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _textTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _formOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textTransitionController,
        curve: Curves.easeInOut,
      ),
    );

    // Dil yöneticisini başlat
    _initializeLanguageManager();

    _fadeController.forward();
    _slideController.forward();
    _formAnimationController.forward();
    _textTransitionController.forward();
  }

  void _initializeLanguageManager() async {
    await LanguageManager.instance.loadLanguage();
    LanguageManager.instance.onLanguageChanged = (languageCode) {
      _textTransitionController.reset();
      _textTransitionController.forward();
      setState(() {});
    };
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _formAnimationController.dispose();
    _textTransitionController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });

    // Form animasyonunu yeniden başlat
    _formAnimationController.reset();
    _formAnimationController.forward();
  }

  void _onLogin() {
    _showFeatureNotAvailableDialog();
  }

  void _onRegister() {
    _showFeatureNotAvailableDialog();
  }

  void _onGoogleLogin() {
    _showFeatureNotAvailableDialog();
  }

  void _onAppleLogin() {
    _showFeatureNotAvailableDialog();
  }

  void _onGuestLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LevelPage()));
  }

  void _showFeatureNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double screenHeight = MediaQuery.of(context).size.height;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.06,
                  bottom: screenHeight * 0.06,
                  right: screenWidth * 0.08,
                  left: screenWidth * 0.08,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.construction,
                          color: Colors.orange.shade700,
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          Translations.getCurrent('under_development'),
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          textScaler: const TextScaler.linear(1),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Icon(
                          Icons.construction,
                          color: Colors.orange.shade700,
                          size: screenWidth * 0.05,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      Translations.getCurrent('feature_not_available'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(1),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      Translations.getCurrent('use_guest_login'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(1),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withValues(alpha: 0.5),
                        foregroundColor: Colors.black87,
                        shadowColor: Colors.black87.withValues(alpha: 0.2),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.011,
                          bottom: screenHeight * 0.011,
                          left: screenWidth * 0.075,
                          right: screenWidth * 0.075,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        Translations.getCurrent('understood'),
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: GestureDetector(
        onTap: () {
          // Klavyeyi kapat ve odaklanmayı kaldır
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.blueGrey.shade900,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blueGrey.shade900,
                  Colors.blueGrey.shade800,
                  Colors.blueGrey.shade900,
                ],
              ),
            ),
            child: Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        // Üst Bilgi Kısmı
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/logos/wnh_banner.png",
                                  width: screenWidth * 0.75,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                FadeTransition(
                                  opacity: _textOpacityAnimation,
                                  child: Text(
                                    Translations.getCurrent('app_title'),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.08,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    textScaler: const TextScaler.linear(1),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                FadeTransition(
                                  opacity: _textOpacityAnimation,
                                  child: Text(
                                    Translations.getCurrent('app_subtitle'),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: Colors.blueGrey.shade300,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                    textScaler: const TextScaler.linear(1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.06),
                        // Login/Register Bölgesi
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.06),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Mode Toggle
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: _toggleMode,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                              padding: EdgeInsets.symmetric(
                                                vertical: screenHeight * 0.015,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _isLoginMode
                                                    ? Colors.green.withValues(
                                                        alpha: 0.8,
                                                      )
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: FadeTransition(
                                                opacity: _textOpacityAnimation,
                                                child: Text(
                                                  Translations.getCurrent(
                                                    'login',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                    fontWeight: FontWeight.bold,
                                                    color: _isLoginMode
                                                        ? Colors.white
                                                        : Colors
                                                              .blueGrey
                                                              .shade300,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  textScaler:
                                                      const TextScaler.linear(
                                                        1,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: _toggleMode,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                              padding: EdgeInsets.symmetric(
                                                vertical: screenHeight * 0.015,
                                              ),
                                              decoration: BoxDecoration(
                                                color: !_isLoginMode
                                                    ? Colors.green.withValues(
                                                        alpha: 0.8,
                                                      )
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: FadeTransition(
                                                opacity: _textOpacityAnimation,
                                                child: Text(
                                                  Translations.getCurrent(
                                                    'register',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                    fontWeight: FontWeight.bold,
                                                    color: !_isLoginMode
                                                        ? Colors.white
                                                        : Colors
                                                              .blueGrey
                                                              .shade300,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  textScaler:
                                                      const TextScaler.linear(
                                                        1,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    // Username Field (only for register)
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: !_isLoginMode
                                          ? FadeTransition(
                                              opacity: _formOpacityAnimation,
                                              child: SlideTransition(
                                                position:
                                                    Tween<Offset>(
                                                      begin: const Offset(
                                                        -0.2,
                                                        0,
                                                      ),
                                                      end: Offset.zero,
                                                    ).animate(
                                                      CurvedAnimation(
                                                        parent:
                                                            _formAnimationController,
                                                        curve:
                                                            Curves.easeOutCubic,
                                                      ),
                                                    ),
                                                child: Column(
                                                  children: [
                                                    _buildTextField(
                                                      controller:
                                                          _usernameController,
                                                      label:
                                                          Translations.getCurrent(
                                                            'username',
                                                          ),
                                                      icon:
                                                          Icons.person_outline,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return Translations.getCurrent(
                                                            'username_required',
                                                          );
                                                        }
                                                        if (value.length < 3) {
                                                          return Translations.getCurrent(
                                                            'username_min_length',
                                                          );
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          screenHeight * 0.02,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                    // Email Field
                                    _buildTextField(
                                      controller: _emailController,
                                      label: Translations.getCurrent('email'),
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return Translations.getCurrent(
                                            'email_required',
                                          );
                                        }
                                        if (!value.contains('@')) {
                                          return Translations.getCurrent(
                                            'email_invalid',
                                          );
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    // Password Field
                                    _buildTextField(
                                      controller: _passwordController,
                                      label: Translations.getCurrent(
                                        'password',
                                      ),
                                      icon: Icons.lock_outline,
                                      obscureText: _obscurePassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.blueGrey.shade300,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return Translations.getCurrent(
                                            'password_required',
                                          );
                                        }
                                        if (value.length < 6) {
                                          return Translations.getCurrent(
                                            'password_min_length',
                                          );
                                        }
                                        return null;
                                      },
                                    ),
                                    // Confirm Password Field (only for register)
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: !_isLoginMode
                                          ? FadeTransition(
                                              opacity: _formOpacityAnimation,
                                              child: SlideTransition(
                                                position:
                                                    Tween<Offset>(
                                                      begin: const Offset(
                                                        -0.2,
                                                        0,
                                                      ),
                                                      end: Offset.zero,
                                                    ).animate(
                                                      CurvedAnimation(
                                                        parent:
                                                            _formAnimationController,
                                                        curve:
                                                            Curves.easeOutCubic,
                                                      ),
                                                    ),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          screenHeight * 0.02,
                                                    ),
                                                    _buildTextField(
                                                      controller:
                                                          _confirmPasswordController,
                                                      label:
                                                          Translations.getCurrent(
                                                            'confirm_password',
                                                          ),
                                                      icon: Icons.lock_outline,
                                                      obscureText:
                                                          _obscureConfirmPassword,
                                                      suffixIcon: IconButton(
                                                        icon: Icon(
                                                          _obscureConfirmPassword
                                                              ? Icons
                                                                    .visibility_off
                                                              : Icons
                                                                    .visibility,
                                                          color: Colors
                                                              .blueGrey
                                                              .shade300,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _obscureConfirmPassword =
                                                                !_obscureConfirmPassword;
                                                          });
                                                        },
                                                      ),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return Translations.getCurrent(
                                                            'confirm_password_required',
                                                          );
                                                        }
                                                        if (value !=
                                                            _passwordController
                                                                .text) {
                                                          return Translations.getCurrent(
                                                            'passwords_not_match',
                                                          );
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    // Remember Me & Auto Login Options
                                    Row(
                                      children: [
                                        // Remember Me Toggle
                                        Expanded(
                                          child: _buildToggleOption(
                                            label: Translations.getCurrent(
                                              'remember_me',
                                            ),
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberMe = value;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        // Auto Login Toggle
                                        Expanded(
                                          child: _buildToggleOption(
                                            label: Translations.getCurrent(
                                              'auto_login',
                                            ),
                                            value: _autoLogin,
                                            onChanged: (value) {
                                              setState(() {
                                                _autoLogin = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    SizedBox(height: screenHeight * 0.01),
                                    // Login/Register Button
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      transitionBuilder:
                                          (
                                            Widget child,
                                            Animation<double> animation,
                                          ) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: const Offset(0, 0.1),
                                                  end: Offset.zero,
                                                ).animate(animation),
                                                child: child,
                                              ),
                                            );
                                          },
                                      child: SizedBox(
                                        key: ValueKey(_isLoginMode),
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _isLoginMode
                                              ? _onLogin
                                              : _onRegister,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: screenHeight * 0.02,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 8,
                                            shadowColor: Colors.green
                                                .withValues(alpha: 0.3),
                                          ),
                                          child: FadeTransition(
                                            opacity: _textOpacityAnimation,
                                            child: Text(
                                              _isLoginMode
                                                  ? Translations.getCurrent(
                                                      'login',
                                                    )
                                                  : Translations.getCurrent(
                                                      'register',
                                                    ),
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.05,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                              textScaler:
                                                  const TextScaler.linear(1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    // Divider
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: Colors.blueGrey.shade400,
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.04,
                                          ),
                                          child: FadeTransition(
                                            opacity: _textOpacityAnimation,
                                            child: Text(
                                              Translations.getCurrent('or'),
                                              style: TextStyle(
                                                color: Colors.blueGrey.shade300,
                                                fontSize: screenWidth * 0.035,
                                              ),
                                              textScaler:
                                                  const TextScaler.linear(1),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.blueGrey.shade400,
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    // Social Login Buttons
                                    Row(
                                      children: [
                                        // Google Login Button
                                        Expanded(
                                          child: _buildSocialButton(
                                            icon: Icons.g_mobiledata,
                                            label: Translations.getCurrent(
                                              'google',
                                            ),
                                            onTap: _onGoogleLogin,
                                            color: Colors.red,
                                          ),
                                        ),
                                        // Apple Login Button (only on iOS)
                                        if (Platform.isIOS) ...[
                                          SizedBox(width: screenWidth * 0.03),
                                          Expanded(
                                            child: _buildSocialButton(
                                              icon: Icons.apple,
                                              label: Translations.getCurrent(
                                                'apple',
                                              ),
                                              onTap: _onAppleLogin,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    // Guest Login Button
                                    OutlinedButton(
                                      onPressed: _onGuestLogin,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            Colors.blueGrey.shade300,
                                        side: BorderSide(
                                          color: Colors.blueGrey.shade400,
                                          width: 1.5,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.015,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: FadeTransition(
                                        opacity: _textOpacityAnimation,
                                        child: Text(
                                          Translations.getCurrent(
                                            'guest_continue',
                                          ),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textScaler: const TextScaler.linear(
                                            1,
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
                        SizedBox(height: screenHeight * 0.03),
                        // Version Info
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: FadeTransition(
                            opacity: _textOpacityAnimation,
                            child: Text(
                              Translations.getCurrent('version'),
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.blueGrey.shade400,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                              textScaler: const TextScaler.linear(1),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
                // Sabit Dil Seçim Butonu
                Positioned(
                  top: screenHeight * 0.05,
                  right: screenWidth * 0.08,
                  child: _buildLanguageSelector(screenWidth, screenHeight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.blueGrey.shade300,
          fontSize: screenWidth * 0.035,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.blueGrey.shade300,
          size: screenWidth * 0.05,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade400, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade400, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.02),
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
            ),
            textScaler: const TextScaler.linear(1),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.008,
          horizontal: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value
                ? Colors.green.withValues(alpha: 0.6)
                : Colors.blueGrey.shade400.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: screenWidth * 0.045,
              height: screenWidth * 0.045,
              decoration: BoxDecoration(
                color: value ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(screenWidth * 0.0225),
                border: Border.all(
                  color: value ? Colors.green : Colors.blueGrey.shade400,
                  width: 1.5,
                ),
              ),
              child: value
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: screenWidth * 0.025,
                    )
                  : null,
            ),
            SizedBox(width: screenWidth * 0.015),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.028,
                  fontWeight: FontWeight.w500,
                  color: value
                      ? Colors.green.shade300
                      : Colors.blueGrey.shade300,
                ),
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade800.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              color: Colors.white,
              size: screenWidth * 0.045,
            ),
            SizedBox(width: screenWidth * 0.015),
            Text(
              LanguageManager.instance.currentLanguage.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: screenWidth * 0.008),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: screenWidth * 0.035,
            ),
          ],
        ),
        onSelected: (String languageCode) async {
          await LanguageManager.instance.changeLanguage(languageCode);
        },
        itemBuilder: (BuildContext context) {
          return LanguageManager.supportedLanguages.keys.map((
            String languageCode,
          ) {
            final isSelected =
                languageCode == LanguageManager.instance.currentLanguage;
            return PopupMenuItem<String>(
              value: languageCode,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.008,
                  horizontal: screenWidth * 0.02,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          screenWidth * 0.025,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : Colors.blueGrey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: screenWidth * 0.025,
                            )
                          : null,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      LanguageManager.instance.getLanguageName(languageCode),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.green.shade300
                            : Colors.blueGrey.shade700,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.blueGrey.shade900.withValues(alpha: 0.95),
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.4),
      ),
    );
  }
}
