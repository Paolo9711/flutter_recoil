import 'package:flutter/foundation.dart';
import '../flutter_recoil.dart';

typedef RecoilState<T> = T Function(AtomOptions<T> atomOptions);
typedef GetRecoilValue<T> = T Function(RecoilState<T> recoilState);
typedef GetAtomValue<T> = Function(ValueNotifier<T?> atomValue);
