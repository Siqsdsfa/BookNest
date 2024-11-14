import 'package:booknest/core/auth.dart';
import 'package:booknest/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String name = 'login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool hidePass = true;
  bool succesfulLogin = false;
  String? errorMessage;

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() {
        succesfulLogin = true;
      });
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      succesfulLogin = false;
      setState(() {
        errorMessage = 'Something went wrong';
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() {
        succesfulLogin = true;
      });
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      succesfulLogin = false;
      setState(() {
        errorMessage = 'Something went wrong';
      });
    }
  }

  void clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    hidePass = true;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);

    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      clearFields();
      switch (_tabController.index) {
        case 0:
          debugPrint("Sign in");
          break;
        case 1:
          debugPrint("Sign up");
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => context.pushNamed(LoginScreen.name),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Log In'),
              Tab(text: 'Create Account'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            loginScreen(),
            createAccountScreen(),
          ],
        ),
      ),
    );
  }

  void togglePasswordVisibility() => setState(() => hidePass = !hidePass);

  Widget loginScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue,
            Colors.green,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          15.0,
        ),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 40),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.account_circle_outlined,
                            color: Colors.white, size: 180),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),
              loginTextField(
                'Email',
                Icons.person_rounded,
                _emailController,
                false,
              ),
              const SizedBox(height: 25),
              loginTextField(
                'Password',
                Icons.key_rounded,
                _passwordController,
                true,
              ),
              const SizedBox(height: 50),
              checkLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget createAccountScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue,
            Colors.green,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          15.0,
        ),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 40),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.account_circle_outlined,
                            color: Colors.white, size: 180),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50),
              loginTextField(
                'Email',
                Icons.person_rounded,
                _emailController,
                false,
              ),
              const SizedBox(height: 25),
              loginTextField(
                'Password',
                Icons.key_rounded,
                _passwordController,
                true,
              ),
              const SizedBox(height: 25),
              loginTextField(
                'Confirm Password',
                Icons.key_rounded,
                _confirmPasswordController,
                true,
              ),
              const SizedBox(height: 80),
              checkSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginTextField(String title, IconData iconData,
      TextEditingController controller, bool isPasswordField) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white),
        ),
        labelText: title,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(iconData, color: Colors.white),
        suffixIcon: isPasswordField != false
            ? IconButton(
                icon: hidePass
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
                onPressed: togglePasswordVisibility,
                color: Colors.white,
              )
            : null,
      ),
      controller: controller,
      obscureText: isPasswordField != false ? hidePass : false,
    );
  }

  Widget checkLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
      ),
      child: const Text(
        'Login',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        handleLogin();
      },
    );
  }

  void handleLogin() async {
    String mail = _emailController.text;
    String pass = _passwordController.text;
    if (mail.isEmpty || pass.isEmpty) {
      createSnackBar('Mail or password not filled');
    } else {
      await signInWithEmailAndPassword();
      if (succesfulLogin) {
        if (mounted) {
          context.pushNamed(HomeScreen.name);
        }
      } else {
        createSnackBar('Failed Login');
        _passwordController.clear();
      }
    }
  }

  Widget checkSignUpButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
      ),
      child: const Text(
        'Create Account',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        handleSignUp();
      },
    );
  }

  void handleSignUp() async {
    String mail = _emailController.text;
    String pass = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    if (mail.isEmpty || pass.isEmpty || confirmPassword.isEmpty) {
      createSnackBar('Fields not filled');
    } else {
      if (pass == confirmPassword) {
        await createUserWithEmailAndPassword();
        if (succesfulLogin) {
          if (mounted) {
            context.pushNamed(HomeScreen.name);
          }
        } else {
          createSnackBar('Failed Login');
        }
      } else {
        createSnackBar('Passwords must be the same');
      }
    }
  }

  void createSnackBar(String text) {
    debugPrint(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}
