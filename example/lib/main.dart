import 'dart:math';

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

class CheckBoxModel {
  final int id;
  final bool value;

  CheckBoxModel(this.id, this.value);
}

class MyHomePage extends RecoilWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final checkBoxValues = userRecoilState(checkBoxAtom);

    final toggle = checkBoxAtom.setData(
      (currentValue) {
        if (currentValue.value == null) return;

        // currentValue.value = !currentValue.value!;
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check box'),
      ),
      body: Center(
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(
            color: Colors.grey,
            height: 0,
          ),
          itemCount: initialCheckBox.length,
          itemBuilder: (context, index) {
            final checkBox = checkBoxValues[index];
            return ListTile(
              title: Text(checkBox.id.toString()),
              trailing: Checkbox(value: checkBox.value, onChanged: (_) {}),
              onTap: () {},
            );
          },
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
    final checkBoxValue = userRecoilState(checkBoxSelector).toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check box result'),
      ),
      body: Center(
        child: Text(
          "The selected check box are: \n $checkBoxValue",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
