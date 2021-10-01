import 'package:flutter_recoil/flutter_recoil.dart';

final checkBoxAtom = Atom<bool>(key: 'check_box', defaultValue: false);

final checkBoxSelector = Selector('check_box_selector', (getStateValue) {
  return getStateValue(checkBoxAtom);
});
