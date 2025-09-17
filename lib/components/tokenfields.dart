import 'package:flutter/material.dart';

class FourDigitInput extends StatefulWidget {
  final void Function(String) onCompleted;
  final double boxSize;
  final TextStyle textStyle;
  final Color borderColor;
  final Color focusedBorderColor;

  const FourDigitInput({
    Key? key,
    required this.onCompleted,
    this.boxSize = 60,
    this.textStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    this.borderColor = Colors.grey,
    this.focusedBorderColor = Colors.blue,
  }) : super(key: key);

  @override
  State<FourDigitInput> createState() => _FourDigitInputState();
}

class _FourDigitInputState extends State<FourDigitInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    String currentCode = _controllers.map((c) => c.text).join();
    if (currentCode.length == 4) {
      widget.onCompleted(currentCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: widget.boxSize,
          height: widget.boxSize,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            maxLength: 1,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: widget.textStyle,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.focusedBorderColor),
              ),
            ),
            onChanged: (value) => _onChanged(value, index),
          ),
        );
      }),
    );
  }
}
