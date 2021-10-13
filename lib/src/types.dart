import 'package:flutter/foundation.dart';
import '../flutter_recoil.dart';

typedef RecoilState<T> = T Function(RecoilOptions<T> atomOptions);
typedef GetRecoilValue<T> = T Function(RecoilState recoilState);
typedef GetAtomValue<T> = void Function(ValueNotifier<T> atomValue);
typedef AtomEffect<T> = void Function(T onItemSet, ValueNotifier<T> setItemData)?;
