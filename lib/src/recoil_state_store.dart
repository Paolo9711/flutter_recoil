import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../flutter_recoil.dart';

/// Manage and evaluate values of atoms and selectors
class RecoilStateStore<T> {
  Map<String, dynamic> states = {};

  RecoilStateStore();

  factory RecoilStateStore.of(BuildContext context) =>
      provider.Provider.of<RecoilStateStore<T>>(context);

  getModelValue(RecoilOptions atomOptions) {
    if (states.containsKey(atomOptions.key)) {
      return states[atomOptions.key];
    }

    final modelValue = atomOptions is Atom ? atomOptions.defaultValueNotifier : null;
    states[atomOptions.key] = modelValue;

    return modelValue;
  }

  _EvaluatorResult<T> evaluateResult(RecoilOptions<T> atomOptions) {
    final dependencies = <String>[];

    if (atomOptions is Selector<T>) {
      return _EvaluatorResult<T>(
        atomOptions.getValue((state) => getModelValue(state).value),
        dependencies,
      );
    }

    dependencies.add(atomOptions.key);
    return _EvaluatorResult<T>(getModelValue(atomOptions), dependencies);
  }
}

class _EvaluatorResult<T> {
  T evaluatorResult;
  List<String> dependencies;

  _EvaluatorResult(this.evaluatorResult, this.dependencies);
}
