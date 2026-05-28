import 'package:flutter/material.dart';

/// Figma handoff §11 — dissolve / smart animate, 120–450ms
abstract final class CollectoryMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);

  static const Curve ease = Curves.easeInOut;

  /// Layer drag: back layers shift up/right; front shifts down/left (px at t=1)
  static const double layerBackDx = 14;
  static const double layerBackDy = -12;
  static const double layerFrontDx = -14;
  static const double layerFrontDy = 12;
}

/// Dissolve page route (opacity fade, no slide flash).
class CollectoryDissolveRoute<T> extends PageRouteBuilder<T> {
  CollectoryDissolveRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    Duration? duration,
  }) : super(
          settings: settings,
          transitionDuration: duration ?? CollectoryMotion.medium,
          reverseTransitionDuration: duration ?? CollectoryMotion.medium,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: CollectoryMotion.ease,
              reverseCurve: CollectoryMotion.ease,
            );
            return FadeTransition(opacity: curved, child: child);
          },
        );
}

extension CollectoryNavigator on NavigatorState {
  Future<T?> pushDissolve<T extends Object?>(
    WidgetBuilder builder, {
    RouteSettings? settings,
    Duration? duration,
  }) {
    return push<T>(
      CollectoryDissolveRoute<T>(
        builder: builder,
        settings: settings,
        duration: duration,
      ),
    );
  }
}

extension CollectoryBuildContext on BuildContext {
  Future<T?> pushDissolve<T extends Object?>(
    WidgetBuilder builder, {
    RouteSettings? settings,
    Duration? duration,
  }) {
    return Navigator.of(this).pushDissolve<T>(
      builder,
      settings: settings,
      duration: duration,
    );
  }
}

/// Global Material page transitions — dissolve only.
class CollectoryPageTransitionsBuilder extends PageTransitionsBuilder {
  const CollectoryPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: CollectoryMotion.ease,
      reverseCurve: CollectoryMotion.ease,
    );
    return FadeTransition(opacity: curved, child: child);
  }
}
