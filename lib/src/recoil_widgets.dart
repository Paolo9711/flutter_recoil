import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart' as provider;
import '../flutter_recoil.dart';

abstract class RecoilWidget extends HookWidget {
  const RecoilWidget({Key? key}) : super(key: key);
}

class RecoilProvider<T> extends StatelessWidget {
  final Widget? child;
  final provider.Dispose<T>? dispose;
  final bool? lazy;
  final TransitionBuilder? builder;

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
