import 'package:flutter/material.dart';

class EmailInput extends StatefulWidget {
	EmailInput({super.key});

	@override
	_EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
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
				prefixIcon: const Icon(Icons.mail_outline),
				border: OutlineInputBorder(
					borderSide: BorderSide.none,
					borderRadius: BorderRadius.circular(5)
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(5),
					borderSide: BorderSide.none
				),
			),
		);
	}
}