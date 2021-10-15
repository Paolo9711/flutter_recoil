part of '../flutter_recoil.dart';

/// A [Widget] that can use [Atom] and [Selector].
///
/// It's usage is very similar to [StatelessWidget] and implements only a [build] method.
abstract class RecoilWidget extends HookWidget {
  const RecoilWidget({Key? key}) : super(key: key);
}

class RecoilProvider<T> extends StatelessWidget {
  final Widget? child;
  final provider.Dispose<T>? dispose;
  final bool? lazy;
  final TransitionBuilder? builder;

  /// Provide a Recoil Context using [RecoilStateStore]
  ///
  /// Be sure to wrap widget that need Recoil Context, using builder method of [RecoilProvider]:
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return RecoilProvider(
  ///     builder: (context, child) {
  ///       return YourWidget(
  ///       // Widget parameters
  ///       );
  ///     },
  ///   );
  /// }
  /// ```
  const RecoilProvider({
    Key? key,
    this.child,
    this.dispose,
    this.lazy,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return provider.Provider(
      key: key,
      create: (context) => RecoilStateStore<T>(),
      child: child,
      lazy: lazy,
      builder: builder,
      dispose: (context, value) => dispose,
    );
  }
}
