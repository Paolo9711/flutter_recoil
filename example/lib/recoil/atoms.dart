import 'dart:math';

import 'package:example/main.dart';
import 'package:flutter_recoil/flutter_recoil.dart';

final initialCheckBox = List.generate(
  10,
  (index) => CheckBoxModel(index, Random().nextInt(2) == 0),
);

final checkBoxAtom = Atom(
  key: 'check_box_atom',
  defaultValue: initialCheckBox,
  effects: [
    (onItemSet, setItemData) {
      // onItemSet.forEach((e) {
      //   print("${e.id} ${e.value}");
      // });

      // Future.delayed(const Duration(seconds: 2), () {
      //   setItemData.value = List.generate(10, (index) => CheckBoxModel(index, true));
      // });
    },
  ],
);

final checkBoxSelector = Selector(
  key: 'check_box_selector',
  getValue: (getValue) {
    final currentValue = getValue(checkBoxAtom) as List<CheckBoxModel>;

    return currentValue.where((e) => e.value).map((e) => e.id.toString()).toList();
  },
);
