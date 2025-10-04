import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:words_and_hammers/pages/level_page.dart';
import 'package:words_and_hammers/services/data_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _formAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _formOpacityAnimation;

  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
    _fadeController.forward();
    _slideController.forward();
    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _formAnimationController.dispose();
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
                          "Geliştiriliyor",
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
                      "Bu özellik henüz geliştirilme aşamasında!",
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
                      "Lütfen şimdilik oyunu deneyimlemek için misafir girişini kullanabilirsiniz!",
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
                        'Anladım!',
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

  void _onGuestLogin() async {
    try {
      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Oyuncu verilerini kontrol et
      final playerDataManager = PlayerDataManager();
      PlayerData? playerData = await playerDataManager.loadPlayerData();

      // Eğer veri yoksa yeni oluştur
      if (playerData == null) {
        playerData = await playerDataManager.createNewPlayerData(isGuest: true);
        print('Yeni misafir oyuncu oluşturuldu: ${playerData.playerId}');
      } else {
        print('Mevcut oyuncu verisi yüklendi: ${playerData.playerId}');
      }

      // Loading'i kapat
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Oyun sayfasına git
      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const LevelPage()));
      }
    } catch (e) {
      // Loading'i kapat
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Hata göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş yapılırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
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
                            Text(
                              "Words & Hammers",
                              style: TextStyle(
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                              textScaler: const TextScaler.linear(1),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              "Muhteşem bir yolculuğa yelken aç!\n\nAma öncelikle bu yolculukta seni ve verilerini korumamız için giriş yapman gerekmekte!",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.blueGrey.shade300,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                              textScaler: const TextScaler.linear(1),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            "Giriş Yap",
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              color: _isLoginMode
                                                  ? Colors.white
                                                  : Colors.blueGrey.shade300,
                                            ),
                                            textAlign: TextAlign.center,
                                            textScaler: const TextScaler.linear(
                                              1,
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
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            "Kayıt Ol",
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              color: !_isLoginMode
                                                  ? Colors.white
                                                  : Colors.blueGrey.shade300,
                                            ),
                                            textAlign: TextAlign.center,
                                            textScaler: const TextScaler.linear(
                                              1,
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
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  child: !_isLoginMode
                                      ? FadeTransition(
                                          opacity: _formOpacityAnimation,
                                          child: SlideTransition(
                                            position:
                                                Tween<Offset>(
                                                  begin: const Offset(-0.2, 0),
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent:
                                                        _formAnimationController,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                            child: Column(
                                              children: [
                                                _buildTextField(
                                                  controller:
                                                      _usernameController,
                                                  label: "Kullanıcı Adı",
                                                  icon: Icons.person_outline,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Kullanıcı adı gerekli';
                                                    }
                                                    if (value.length < 3) {
                                                      return 'En az 3 karakter olmalı';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(
                                                  height: screenHeight * 0.02,
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
                                  label: "E-posta",
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'E-posta gerekli';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Geçerli bir e-posta girin';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                // Password Field
                                _buildTextField(
                                  controller: _passwordController,
                                  label: "Şifre",
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
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Şifre gerekli';
                                    }
                                    if (value.length < 6) {
                                      return 'En az 6 karakter olmalı';
                                    }
                                    return null;
                                  },
                                ),
                                // Confirm Password Field (only for register)
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                  child: !_isLoginMode
                                      ? FadeTransition(
                                          opacity: _formOpacityAnimation,
                                          child: SlideTransition(
                                            position:
                                                Tween<Offset>(
                                                  begin: const Offset(-0.2, 0),
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent:
                                                        _formAnimationController,
                                                    curve: Curves.easeOutCubic,
                                                  ),
                                                ),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: screenHeight * 0.02,
                                                ),
                                                _buildTextField(
                                                  controller:
                                                      _confirmPasswordController,
                                                  label: "Şifre Tekrar",
                                                  icon: Icons.lock_outline,
                                                  obscureText:
                                                      _obscureConfirmPassword,
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _obscureConfirmPassword
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
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
                                                      return 'Şifre tekrarı gerekli';
                                                    }
                                                    if (value !=
                                                        _passwordController
                                                            .text) {
                                                      return 'Şifreler eşleşmiyor';
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
                                SizedBox(height: screenHeight * 0.03),
                                // Login/Register Button
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 8,
                                        shadowColor: Colors.green.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      child: Text(
                                        _isLoginMode ? "Giriş Yap" : "Kayıt Ol",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        textScaler: const TextScaler.linear(1),
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
                                      child: Text(
                                        "veya",
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade300,
                                          fontSize: screenWidth * 0.035,
                                        ),
                                        textScaler: const TextScaler.linear(1),
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
                                        label: "Google",
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
                                          label: "Apple",
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
                                    foregroundColor: Colors.blueGrey.shade300,
                                    side: BorderSide(
                                      color: Colors.blueGrey.shade400,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Misafir Olarak Devam Et",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textScaler: const TextScaler.linear(1),
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
                      child: Text(
                        "Prototip 2 (Ver: 1.0.0)",
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.blueGrey.shade400,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
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
}
