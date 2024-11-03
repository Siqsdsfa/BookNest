import 'package:go_router/go_router.dart';
import 'package:booknest/data/book_info.dart';
import 'package:booknest/screens/home_screen.dart';
import 'package:booknest/screens/item_description_screen.dart';
import 'package:booknest/screens/login_screen.dart';

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
        localBookInfo: state.extra as BookInfo,
      ),
    ),
  ],
);
