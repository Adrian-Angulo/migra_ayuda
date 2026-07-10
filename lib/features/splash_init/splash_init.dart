import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/database/sembast_database.dart';
import 'package:migra_ayuda/core/router/app_router_mobile.dart';
import 'package:migra_ayuda/core/router/routes.dart';

class SplashScreenInit extends ConsumerStatefulWidget {
  const SplashScreenInit({super.key});

  @override
  ConsumerState<SplashScreenInit> createState() => _SplashScreenInitState();
}

class _SplashScreenInitState extends ConsumerState<SplashScreenInit> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await SembastDatabase.instance.database;
    /* await ref.read(reviewRepositoryProvider); */
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    context.go(Routes.loginMovil);
    ref.read(routerMovilNotifierProvider).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              "assets/logo/Fondo_splash.png",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(),

                    //--------------------------------
                    // LOGO
                    //--------------------------------

                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: SizedBox(
                        height: size.height * .18,
                        child: Image.asset(
                          'assets/logo/Logo.png',
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    FadeInDown(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 800),
                      child: Image.asset(
                        'assets/logo/MigraAyuda.png',
                        width: size.width * 0.65,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 18),

                    FadeIn(
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        'Tu guía para migrar.',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    FadeIn(
                      delay: const Duration(milliseconds: 1000),
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        'Información, orientación y apoyo\ncuando más lo necesitas.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                              height: 1.5,
                            ),
                      ),
                    ),

                    const Spacer(),

                    //--------------------------------
                    // Loading
                    //--------------------------------
                    const FadeIn(
                      delay: Duration(milliseconds: 1000),
                      duration: Duration(milliseconds: 600),
                      child: SizedBox(
                        width: 220,
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    FadeInUp(
                      delay: const Duration(milliseconds: 1000),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Cargando...',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xff009688),
                                ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
