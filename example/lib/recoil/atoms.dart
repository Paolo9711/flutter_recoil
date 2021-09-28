import 'package:flutter/foundation.dart';
import 'package:flutter_recoil/flutter_recoil.dart';

var checkBoxAtom = Atom('check_box', ValueNotifier(false));

Action toggleCheckBox = (get) {
  var checkBoxValue = get(checkBoxAtom);
  checkBoxValue.value = !checkBoxValue.value;
};

Selector checkBoxSelector = Selector('check_box_selector', (GetStateValue get) {
  return get(checkBoxAtom);
});
