import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../routes/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'demo@example.com');
  final _passwordController = TextEditingController(text: 'password');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Icon(
                  Icons.description,
                  size: 64,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                    children: [
                      TextSpan(text: 'Dishaan'),
                      TextSpan(
                        text: 'Invoice',
                        style: TextStyle(color: AppColors.secondaryOrange),
                      ),
                      TextSpan(text: 'Xpert'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Email field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          final success = await authProvider.login(
                            _emailController.text,
                            _passwordController.text,
                          );

                          if (success && mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.dashboard,
                            );
                          }
                        },
                    child: authProvider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Log In'),
                  ),
                ),

                if (authProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    authProvider.error!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Navigate to forgot password screen
                  },
                  child: Text('Forgot Password?'),
                ),

                const SizedBox(height: 24),
                Text(
                  'Demo Credentials: demo@example.com / password',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
