import 'package:booknest/core/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:booknest/screens/home_screen.dart';
import 'package:booknest/screens/item_description_screen.dart';
import 'package:booknest/screens/login_screen.dart';
import 'package:booknest/screens/likes_and_dislikes_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      name: LoginScreen.name,
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: HomeScreen.name,
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: DescriptionScreen.name,
      path: '/description',
      builder: (context, state) => DescriptionScreen(
        previousAndDetailsInfo: state.extra as DetailsScreenData,
      ),
    ),
    GoRoute(
      name: LikesAndDislikesScreen.name,
      path: '/likes_dislikes',
      builder: (context, state) => const LikesAndDislikesScreen(),
    ),
  ],
  initialLocation: FirebaseAuth.instance.currentUser != null ? '/home' : '/',
);
