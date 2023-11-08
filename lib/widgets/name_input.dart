import 'package:flutter/material.dart';

class NameInput extends StatefulWidget {
	Function onChanged;
	NameInput({super.key, required this.onChanged});

	@override
	_NameInputState createState() => _NameInputState();
}

class _NameInputState extends State<NameInput> {
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
				prefixIcon: const Icon(Icons.person_outlined),
				border: OutlineInputBorder(
					borderSide: BorderSide.none,
					borderRadius: BorderRadius.circular(5)
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(5),
					borderSide: BorderSide.none
				),
			),
			keyboardType: TextInputType.name,
			onChanged: (value) => widget.onChanged(value),
		);
	}
}