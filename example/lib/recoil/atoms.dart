import 'package:flutter/foundation.dart';
import 'package:flutter_recoil/flutter_recoil.dart';

var checkBoxAtom = Atom(key: 'check_box', defaultValue: ValueNotifier(false));

// Selector checkBoxSelector = Selector('check_box_selector', (getStateValue) {
//   return getStateValue(checkBoxAtom);
// });
