import 'package:flutter/material.dart';
import 'registration_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF2E7D32),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 60.0),
                  child: Image(
                    image: AssetImage('assets/images/logo2.jpeg'),
                    height: 120,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome to\nFarm Management',
                        style: TextStyle(
                          fontSize: 36,
                          height: 1.2,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Manage your farm efficiently',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 50),
                      _buildButton(
                        context: context,
                        title: 'SIGN IN',
                        isOutlined: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        context: context,
                        title: 'SIGN UP',
                        isOutlined: false,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        text: 'Continue with Google',
                      ),
                      const SizedBox(height: 16),
                      _buildSocialButton(
                        icon: Icons.facebook,
                        text: 'Continue with Facebook',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String title,
    required bool isOutlined,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isOutlined ? Colors.white : const Color(0xFF4CAF50),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required String text}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
