import 'package:flutter/material.dart';
import 'package:flutter_recoil/flutter_recoil.dart';

import 'recoil/atoms.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RecoilProvider(
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter Recoil Demo',
          home: child,
          debugShowCheckedModeBanner: false,
        );
      },
      child: const MyHomePage(),
    );
  }
}

class MyHomePage extends RecoilWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final checkBoxValue = userRecoilState<bool>(checkBoxAtom);

    final toggle = checkBoxAtom.setData(
      (currentValue) {
        currentValue.value = !currentValue.value;
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check box'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Check box"),
            Checkbox(
              value: checkBoxValue.value,
              onChanged: (_) => toggle(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ResultScreen()),
          );
        },
        child: const Icon(Icons.arrow_forward_ios_rounded),
      ),
    );
  }
}

class ResultScreen extends RecoilWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final checkBoxValue = userRecoilState(checkBoxSelector);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check box result'),
      ),
      body: Center(
        child: Text(checkBoxValue.value.toString()),
      ),
    );
  }
}
