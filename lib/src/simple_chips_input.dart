import 'package:flutter/material.dart';
import 'package:simple_chips_input/src/text_form_field_syle.dart';

/// The [SimpleChipsInput] widget is a text field that allows the user to input and create chips out of it.
class SimpleChipsInput extends StatefulWidget {
  /// Creates a [SimpleChipsInput] widget.
  ///
  /// Read the [API reference](https://pub.dev/documentation/simple_chips_input/latest/simple_chips_input/simple_chips_input-library.html) for full documentation.
  const SimpleChipsInput({
    super.key,
    required this.separatorCharacter,
    this.initialValue,
    this.placeChipsSectionAbove = true,
    this.widgetContainerDecoration = const BoxDecoration(),
    this.marginBetweenChips =
        const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
    this.paddingInsideWidgetContainer = const EdgeInsets.all(8.0),
    this.textFormFieldStyle = const TextFormFieldStyle(),
    this.chipTextStyle,
    this.focusNode,
    this.autoFocus = false,
    this.controller,
    this.createCharacter = ' ',
    this.deleteIcon,
    this.inputValidator,
    this.eraseKeyLabel = 'Backspace',
    this.formKey,
    this.onChanged,
    this.onValueChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onSaved,
    this.onChipDeleted,
  });

  final String? initialValue;

  /// Character to seperate the output. For example: ' ' will seperate the output by space.
  final String separatorCharacter;

  /// Whether to place the chips section above or below the text field.
  final bool placeChipsSectionAbove;

  /// Decoration for the main widget container.
  final BoxDecoration widgetContainerDecoration;

  /// Margin between the chips.
  final EdgeInsets marginBetweenChips;

  /// Padding inside the main widget container;
  final EdgeInsets paddingInsideWidgetContainer;

  /// FocusNode for the text field.
  final FocusNode? focusNode;

  /// Controller for the textfield.
  final TextEditingController? controller;

  /// The input character used for creating a chip.
  final String createCharacter;

  /// Text style for the chip.
  final TextStyle? chipTextStyle;

  /// Icon for the delete method.
  final Widget? deleteIcon;

  /// Validation method.
  final String? Function(String?)? inputValidator;

  /// The key label used for erasing a chip. Defaults to Backspace.
  final String eraseKeyLabel;

  /// Whether to autofocus the widget.
  final bool autoFocus;

  /// Form key to access or validate the form outside the widget.
  final GlobalKey<FormState>? formKey;

  /// Style for the textfield.
  final TextFormFieldStyle textFormFieldStyle;

  final void Function(String, List<String>)? onValueChanged;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String)? onSubmitted;
  final void Function(String)? onSaved;

  /// Callback when a chip is deleted. Returns the deleted chip content and index.
  final void Function(String, int)? onChipDeleted;

  @override
  State<SimpleChipsInput> createState() => _SimpleChipsInputState();
}

class _SimpleChipsInputState extends State<SimpleChipsInput> {
  late final TextEditingController _controller;
  // ignore: prefer_typing_uninitialized_variables
  late final _formKey;
  late final List<String> _chipsText;
  late final FocusNode _focusNode;

  String get output => _chipsText.join(widget.separatorCharacter);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    _focusNode = widget.focusNode ?? FocusNode();
    _chipsText = widget.initialValue != null && widget.initialValue != ''
        ? widget.initialValue!.split(widget.separatorCharacter)
        : [];
  }

  List<Widget> _buildChipsSection() {
    final List<Widget> chips = [];
    for (int i = 0; i < _chipsText.length; i++) {
      chips.add(
        Container(
          margin: widget.marginBetweenChips,
          child: InputChip(
            label: Text(
              _chipsText[i],
              style: widget.chipTextStyle,
            ),
            deleteIcon: widget.deleteIcon,
            onDeleted: () {
              widget.onChipDeleted?.call(_chipsText[i], i);
              setState(() {
                _chipsText.removeAt(i);
              });
              widget.onValueChanged?.call(output, _chipsText);
            },
          ),
        ),
      );
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: widget.paddingInsideWidgetContainer,
        decoration: widget.widgetContainerDecoration,
        child: SingleChildScrollView(
          child: Wrap(
            children: [
              if (widget.placeChipsSectionAbove) ...[
                ..._buildChipsSection(),
              ],
              RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (event) {
                  if (event.data.logicalKey.keyLabel == widget.eraseKeyLabel) {
                    if (_controller.text.isEmpty && _chipsText.isNotEmpty) {
                      setState(() {
                        _chipsText.removeLast();
                      });
                      widget.onValueChanged?.call(output, _chipsText);
                    }
                  }
                },
                child: TextFormField(
                  autofocus: widget.autoFocus,
                  focusNode: _focusNode,
                  controller: _controller,
                  keyboardType: widget.textFormFieldStyle.keyboardType,
                  maxLines: widget.textFormFieldStyle.maxLines,
                  minLines: widget.textFormFieldStyle.minLines,
                  enableSuggestions:
                      widget.textFormFieldStyle.enableSuggestions,
                  showCursor: widget.textFormFieldStyle.showCursor,
                  cursorWidth: widget.textFormFieldStyle.cursorWidth,
                  cursorColor: widget.textFormFieldStyle.cursorColor,
                  cursorRadius: widget.textFormFieldStyle.cursorRadius,
                  cursorHeight: widget.textFormFieldStyle.cursorHeight,
                  onChanged: (value) {
                    if (value.endsWith(widget.createCharacter)) {
                      _controller.text = _controller.text
                          .substring(0, _controller.text.length - 1);
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length),
                      );
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _chipsText.add(_controller.text);
                          _controller.clear();
                        });
                        widget.onValueChanged?.call(output, _chipsText);
                      }
                    }
                    widget.onChanged?.call(value);
                  },
                  decoration: widget.textFormFieldStyle.decoration,
                  validator: widget.inputValidator,
                  onEditingComplete: () {
                    widget.onEditingComplete?.call();
                  },
                  onFieldSubmitted: ((value) {
                    if (value.isNotEmpty) {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _chipsText.add(_controller.text);
                          _controller.clear();
                        });
                        widget.onValueChanged?.call(output, _chipsText);
                      }
                    }
                    widget.onSubmitted?.call(output);
                  }),
                  onSaved: (value) {
                    if (value!.isNotEmpty) {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _chipsText.add(_controller.text);
                          _controller.clear();
                        });
                        widget.onValueChanged?.call(output, _chipsText);
                      }
                    }
                    widget.onSaved?.call(output);
                  },
                ),
              ),
              if (!widget.placeChipsSectionAbove) ...[
                ..._buildChipsSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
