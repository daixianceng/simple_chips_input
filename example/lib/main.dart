import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:simple_chips_input/simple_chips_input.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Simple Chips Input Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String output = '';
  String? deletedChip, deletedChipIndex;
  final key = GlobalKey<FormState>();
  final FocusNode focusNode = FocusNode();
  final TextFormFieldStyle style = const TextFormFieldStyle(
    keyboardType: TextInputType.phone,
    cursorColor: Colors.red,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.all(0.0),
      border: InputBorder.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Example:\nChips with phone number validation',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          Text(
            deletedChip != null
                ? 'Deleted chip: $deletedChip at index $deletedChipIndex'
                : '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
          Text(
            'Output:\n$output',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SimpleChipsInput(
              separatorCharacter: ",",
              focusNode: focusNode,
              validateInput: true,
              autoFocus: true,
              formKey: key,
              textFormFieldStyle: style,
              validateInputMethod: (String value) {
                final phoneNumberRegExp = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
                if (!phoneNumberRegExp.hasMatch(value)) {
                  return 'Enter a valid phone number';
                }
              },
              onSubmitted: (p0) {
                setState(() {
                  output = p0;
                });
              },
              onChipDeleted: (p0, p1) {
                setState(() {
                  deletedChip = p0;
                  deletedChipIndex = p1.toString();
                });
              },
              onSaved: ((p0) {
                setState(() {
                  output = p0;
                });
              }),
              chipTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              deleteIcon: Icons.delete,
              deleteIconColor: Colors.black,
              widgetContainerDecoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.red),
              ),
              chipContainerDecoration: BoxDecoration(
                color: Colors.yellow,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(50),
              ),
              placeChipsSectionAbove: false,
            ),
          ),
          MaterialButton(
            color: Colors.red,
            onPressed: (() {
              key.currentState!.save();
            }),
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
