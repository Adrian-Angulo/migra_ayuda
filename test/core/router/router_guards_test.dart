import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/guards/mobile_redirect_guard.dart';
import 'package:migra_ayuda/core/router/guards/web_redirect_guard.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:migra_ayuda/features/users/domain/entities/migrant.dart';
import 'package:mocktail/mocktail.dart';

class MockBuildContext extends Mock implements BuildContext {}
class MockGoRouterState extends Mock implements GoRouterState {}

GoRouterState createMockState(String location) {
  final state = MockGoRouterState();
  when(() => state.matchedLocation).thenReturn(location);
  when(() => state.uri).thenReturn(Uri.parse(location));
  return state;
}

final testAdminUser = Migrant(
  id: 'admin-1',
  name: 'Admin User',
  email: 'admin@test.com',
  originCountry: 'Colombia',
  destinationCountry: 'España',
  age: '30',
  role: 'Admin',
  profileComplete: true,
);

final testMigrantComplete = Migrant(
  id: 'migrant-1',
  name: 'Migrant User',
  email: 'migrant@test.com',
  originCountry: 'Colombia',
  destinationCountry: 'España',
  age: '25',
  role: 'Migrante',
  profileComplete: true,
);

final testMigrantIncomplete = Migrant(
  id: 'migrant-2',
  name: 'Incomplete Migrant',
  email: 'incomplete@test.com',
  originCountry: 'Colombia',
  destinationCountry: 'España',
  age: '25',
  role: 'Migrante',
  profileComplete: false,
);

void main() {
  late MockBuildContext mockContext;

  setUp(() {
    mockContext = MockBuildContext();
  });

  group('WebRedirectGuard Tests', () {
    test('Retorna null cuando auth está cargando (isLoading)', () {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _LoadingAuthNotifier()),
        ],
      );

      final state = createMockState(Routes.dashboardHome);
      final result = webRedirectGuard(mockContext, state, container.read(refProvider));

      expect(result, isNull);
    });

    test('Permite acceso a /login y /reset-password si usuario es null', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(null)),
        ],
      );
      await container.read(authNotifierProvider.future);

      final loginState = createMockState(Routes.login);
      expect(webRedirectGuard(mockContext, loginState, container.read(refProvider)), isNull);

      final resetState = createMockState(Routes.resetPassword);
      expect(webRedirectGuard(mockContext, resetState, container.read(refProvider)), isNull);
    });

    test('Redirige a /login si usuario es null e intenta acceder a dashboard', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(null)),
        ],
      );
      await container.read(authNotifierProvider.future);

      final state = createMockState(Routes.dashboardHome);
      expect(webRedirectGuard(mockContext, state, container.read(refProvider)), Routes.login);
    });

    test('Redirige a /login si usuario no tiene rol Admin', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(testMigrantComplete)),
        ],
      );
      await container.read(authNotifierProvider.future);

      final state = createMockState(Routes.dashboardHome);
      expect(webRedirectGuard(mockContext, state, container.read(refProvider)), Routes.login);
    });

    test('Redirige a /dashboard/home si Admin está en /login', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(testAdminUser)),
        ],
      );
      await container.read(authNotifierProvider.future);

      final state = createMockState(Routes.login);
      expect(webRedirectGuard(mockContext, state, container.read(refProvider)), Routes.dashboardHome);
    });

    test('Permite navegación en dashboard si Admin está autenticado', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(testAdminUser)),
        ],
      );
      await container.read(authNotifierProvider.future);

      final state = createMockState(Routes.dashboardHome);
      expect(webRedirectGuard(mockContext, state, container.read(refProvider)), isNull);
    });
  });

  group('MobileRedirectGuard Tests', () {
    test('Permite splashInit sin redirigir', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(null)),
          onboardingProvider.overrideWith(() => _MockOnboardingNotifier(false)),
        ],
      );
      await container.read(authNotifierProvider.future);
      await container.read(onboardingProvider.future);

      final state = createMockState(Routes.splashInit);
      expect(mobileRedirectGuard(mockContext, state, container.read(refProvider)), isNull);
    });

    test('Redirige a /onboarding si no ha completado el onboarding', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(null)),
          onboardingProvider.overrideWith(() => _MockOnboardingNotifier(false)),
        ],
      );
      await container.read(authNotifierProvider.future);
      await container.read(onboardingProvider.future);

      final state = createMockState(Routes.loginMovil);
      expect(mobileRedirectGuard(mockContext, state, container.read(refProvider)), Routes.onboarding);
    });

    test('Redirige a /loginMovil si no hay sesión y onboarding ya fue completado', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(null)),
          onboardingProvider.overrideWith(() => _MockOnboardingNotifier(true)),
        ],
      );
      await container.read(authNotifierProvider.future);
      await container.read(onboardingProvider.future);

      final state = createMockState(Routes.home);
      expect(mobileRedirectGuard(mockContext, state, container.read(refProvider)), Routes.loginMovil);
    });

    test('Redirige a /completeProfile si usuario tiene perfil incompleto', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(testMigrantIncomplete)),
          onboardingProvider.overrideWith(() => _MockOnboardingNotifier(true)),
        ],
      );
      await container.read(authNotifierProvider.future);
      await container.read(onboardingProvider.future);

      final state = createMockState(Routes.home);
      expect(mobileRedirectGuard(mockContext, state, container.read(refProvider)), Routes.completeProfile);
    });

    test('Redirige a /home si usuario Migrante completo está en /loginMovil', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(testMigrantComplete)),
          onboardingProvider.overrideWith(() => _MockOnboardingNotifier(true)),
        ],
      );
      await container.read(authNotifierProvider.future);
      await container.read(onboardingProvider.future);

      final state = createMockState(Routes.loginMovil);
      expect(mobileRedirectGuard(mockContext, state, container.read(refProvider)), Routes.home);
    });

    test('Permite acceso a /reset-password si usuario es null y completó onboarding', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(null)),
          onboardingProvider.overrideWith(() => _MockOnboardingNotifier(true)),
        ],
      );
      await container.read(authNotifierProvider.future);
      await container.read(onboardingProvider.future);

      final state = createMockState(Routes.resetPassword);
      expect(mobileRedirectGuard(mockContext, state, container.read(refProvider)), isNull);
    });

    test('Permite acceso a /home si usuario Migrante tiene perfil completo', () async {
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(() => _MockAuthNotifier(testMigrantComplete)),
          onboardingProvider.overrideWith(() => _MockOnboardingNotifier(true)),
        ],
      );
      await container.read(authNotifierProvider.future);
      await container.read(onboardingProvider.future);

      final state = createMockState(Routes.home);
      expect(mobileRedirectGuard(mockContext, state, container.read(refProvider)), isNull);
    });
  });
}

final refProvider = Provider<Ref>((ref) => ref);

class _LoadingAuthNotifier extends AuthNotifier {
  @override
  Future<Migrant?> build() async {
    state = const AsyncValue.loading();
    return null;
  }
}

class _MockAuthNotifier extends AuthNotifier {
  final Migrant? initialUser;
  _MockAuthNotifier(this.initialUser);

  @override
  Future<Migrant?> build() async {
    return initialUser;
  }
}

class _MockOnboardingNotifier extends OnboardingNotifier {
  final bool initialValue;
  _MockOnboardingNotifier(this.initialValue);

  @override
  Future<bool> build() async {
    return initialValue;
  }
}
