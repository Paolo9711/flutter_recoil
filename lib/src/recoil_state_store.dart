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

  _EvaluatorResult<T> evaluateResult(RecoilOptions<T> recoilOptions) {
    final dependencies = List<String>.empty(growable: true);
    late Function(RecoilOptions) getRecoilState;

    getRecoilState = (options) {
      final result =
          options is Selector ? options.getValue(getRecoilState) : getModelValue(options);
      if (options is Atom) {
        dependencies.add(options.key);
      }
      return result;
    };

    final currentValue = getRecoilState(recoilOptions);
    return _EvaluatorResult(currentValue, dependencies);
  }
}

class _EvaluatorResult<T> {
  T evaluatorResult;
  List<String> dependencies;

  _EvaluatorResult(this.evaluatorResult, this.dependencies);
}
