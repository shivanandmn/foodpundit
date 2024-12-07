import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/size_config.dart';
import '../../utils/ui_constants.dart';
import 'package:foodpundit/providers/app_auth_provider.dart';
import 'package:foodpundit/services/network_service.dart';
import '../../widgets/no_internet_dialog.dart';
import '../../screens/home/home_page.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/loading_overlay.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  final _networkService = NetworkService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _moveToPassword() {
    _emailFocusNode.unfocus();
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }

  Future<bool> _checkNetwork() async {
    final connectionType = await _networkService.getConnectionType();
    if (!await _networkService.checkConnection()) {
      if (!mounted) return false;

      bool shouldRetry = await NoInternetDialog.show(context, connectionType);
      if (shouldRetry) {
        // Check connection again
        return await _networkService.checkConnection();
      }
      return false;
    }
    return true;
  }

  Future<void> _handleSignIn(Future<void> Function() signInMethod) async {
    if (!await _checkNetwork()) return;

    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      await signInMethod();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      // Navigate to home if sign in was successful
      final provider = Provider.of<AppAuthProvider>(context, listen: false);
      if (provider.user != null) {
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    await _handleSignIn(() async {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      await authProvider.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    });
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    await _handleSignIn(() async {
      final provider = Provider.of<AppAuthProvider>(context, listen: false);
      await provider.signInWithGoogleNew();
    });
  }

  Future<void> _handleAppleSignIn() async {
    await _handleSignIn(() async {
      final provider = Provider.of<AppAuthProvider>(context, listen: false);
      await provider.signInWithApple();
    });
  }

  Future<void> _handleAnonymousSignIn() async {
    await _handleSignIn(() async {
      final provider = Provider.of<AppAuthProvider>(context, listen: false);
      await provider.signInAnonymously();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_emailFocusNode.hasFocus || _passwordFocusNode.hasFocus) {
          _emailFocusNode.unfocus();
          _passwordFocusNode.unfocus();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          'Sign In',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => _moveToPassword(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleEmailSignIn(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailSignIn,
                          child: Text(_isLoading ? 'Signing In...' : 'Sign In'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text('Forgot Password?'),
                        ),
                        const SizedBox(height: 24),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _handleGoogleSignIn(context),
                          icon: const Icon(Icons.g_mobiledata),
                          label: Text(_isLoading
                              ? 'Signing in...'
                              : 'Continue with Google'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        if (Theme.of(context).platform ==
                            TargetPlatform.iOS) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _handleAppleSignIn,
                            icon: const Icon(Icons.apple),
                            label: Text(_isLoading
                                ? 'Signing in...'
                                : 'Continue with Apple'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleAnonymousSignIn,
                          icon: const Icon(Icons.person_outline),
                          label: Text(_isLoading
                              ? 'Signing in...'
                              : 'Continue as Guest'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
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
