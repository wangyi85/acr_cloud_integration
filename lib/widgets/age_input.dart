import 'package:flutter/material.dart';

class AgeInput extends StatefulWidget {
	Function onChanged;
	AgeInput({super.key, required this.onChanged});

	@override
	_AgeInputState createState() => _AgeInputState();
}

class _AgeInputState extends State<AgeInput> {
	@override
	Widget build(BuildContext context) {
		return TextField(
			style: const TextStyle(
				fontFamily: 'Futura',
				fontSize: 18,
				fontWeight: FontWeight.w500,
				color: Colors.black
			),
			decoration: InputDecoration(
				filled: true,
				fillColor: const Color(0xfff3f4f6),
				prefixIcon: const Icon(Icons.person_outline),
				border: OutlineInputBorder(
					borderSide: BorderSide.none,
					borderRadius: BorderRadius.circular(5)
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(5),
					borderSide: BorderSide.none
				),
			),
			keyboardType: TextInputType.number,
			onChanged: (value) => widget.onChanged(value),
		);
	}
}