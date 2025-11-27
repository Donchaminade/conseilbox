import 'package:conseilbox/shared/widgets/music_wave_loader.dart';
import 'package:conseilbox/shared/widgets/status_popup.dart';
import 'package:flutter/material.dart';
import 'package:conseilbox/features/home/home_screen.dart';
import 'package:conseilbox/config/app_colors.dart';
import 'package:conseilbox/shared/widgets/bgstyle.dart'; // Import GeometricBackground

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codeController = TextEditingController();
  final String _correctCode = "IrokouKaizen";
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isObscure = true; // Added for password visibility toggle

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MusicWaveLoader(),
                SizedBox(height: 20),
                Text("En cours..."),
              ],
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));
    Navigator.of(context).pop();

    if (_codeController.text == _correctCode) {
      if (mounted) {
        await showStatusPopup(
            context, PopupStatus.success, "Connexion réussie !");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        await showStatusPopup(
            context, PopupStatus.error, "Code incorrect. Veuillez réessayer.");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GeometricBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0), // Padding around the content
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200, //taille du logo
                  ),
                  const SizedBox(
                      height: 4), // Espace entre le logo et le formulaire
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: AppColors.cafe.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _codeController,
                          obscureText: _isObscure, // Use the state variable
                          decoration: InputDecoration(
                            labelText: "Entrez le code unique",
                            errorText:
                                _errorMessage.isNotEmpty ? _errorMessage : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cafe,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
