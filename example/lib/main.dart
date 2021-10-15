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
    final checkBox = useRecoilState(checkBoxAtom);

    void onTileTap(int checkBoxID) {
      checkBox.setData(
        checkBox.data
            .map(
              (e) => e.id == checkBoxID ? CheckBoxModel(e.id, !e.value) : e,
            )
            .toList(),
      );
    }

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
            final currentCheckBox = checkBox.data[index];
            return ListTile(
              title: Text(currentCheckBox.id.toString()),
              trailing: Checkbox(
                value: currentCheckBox.value,
                onChanged: (_) => onTileTap(currentCheckBox.id),
              ),
              onTap: () => onTileTap(currentCheckBox.id),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                onPressed: () {
                  checkBox.setData(checkBox.data.map((e) => CheckBoxModel(e.id, false)).toList());
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.arrow_forward_ios_rounded),
      ),
    );
  }
}

class ResultScreen extends RecoilWidget {
  final VoidCallback onPressed;
  const ResultScreen({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final checkBoxValue = useRecoilSelectorState(checkBoxSelector);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: onPressed,
        child: const Icon(Icons.file_upload),
      ),
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
