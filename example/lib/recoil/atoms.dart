import 'dart:math';

import 'package:example/main.dart';
import 'package:flutter_recoil/flutter_recoil.dart';

final initialCheckBox = List.generate(
  10,
  (index) => CheckBoxModel(index, Random().nextInt(2) == 0),
);

final checkBoxAtom = Atom<List<CheckBoxModel>>(
    key: 'check_box',
    defaultValue: initialCheckBox,
    effects: (setSelf) {
      // if (setSelf.value != null) setSelf.value = !setSelf.value!;
    });

final checkBoxSelector = Selector<List<String>>(
  key: 'check_box_selector',
  getValue: (getValue) {
    final currentCheckBox = getValue(checkBoxAtom).value;

    return (currentCheckBox as List<CheckBoxModel>)
        .where((e) => e.value)
        .map((e) => e.id.toString())
        .toList();
  },
);
