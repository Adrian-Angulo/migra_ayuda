import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/tutorial/presentation/config/utils/controller.dart';
import 'package:showcaseview/showcaseview.dart';
import '../providers/tutorial_providers.dart';

class HomeShowcaseWrapper extends ConsumerStatefulWidget {
  final Widget Function(BuildContext context, HomeShowcaseController controller)
      builder;
  const HomeShowcaseWrapper({
    super.key,
    required this.builder,
  });
  @override
  ConsumerState<HomeShowcaseWrapper> createState() =>
      _HomeShowcaseWrapperState();
}

class _HomeShowcaseWrapperState extends ConsumerState<HomeShowcaseWrapper> {
  static const String _tutorialKey = 'home_main_tutorial_seen';
  final _controller = HomeShowcaseController();
  Future<void> _checkAndStartTutorial(BuildContext showcaseContext) async {
    final shouldShow =
        await ref.read(shouldShowTutorialUseCaseProvider).call(_tutorialKey);
    if (shouldShow && mounted) {
      ShowCaseWidget.of(showcaseContext).startShowCase([
        _controller.filterKey,
        _controller.syncKey,
        _controller.locationKey,
        _controller.mapKey,
      ]);
    }
  }

  void _onTutorialComplete() {
    ref.read(completeTutorialUseCaseProvider).call(_tutorialKey);
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: _onTutorialComplete,
      builder: (showcaseContext) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAndStartTutorial(showcaseContext);
        });
        return widget.builder(showcaseContext, _controller);
      },
    );
  }
}
