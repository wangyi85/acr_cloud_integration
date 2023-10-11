import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
	PasswordInput({super.key});

	@override
	_PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
	bool _showPassword = false;
	@override
	Widget build(BuildContext context) {
		return TextField(
			style: const TextStyle(
				fontFamily: 'Futura',
				fontSize: 18,
				fontWeight: FontWeight.w500,
				color: Colors.black
			),
			obscureText: !_showPassword,
			decoration: InputDecoration(
				filled: true,
				fillColor: const Color(0xfff3f4f6),
				prefixIcon: const Icon(Icons.lock_outline),
				suffixIcon: InkWell(
					onTap: () {
						setState(() {
							_showPassword = !_showPassword;
						});
					},
					child: Icon(_showPassword? Icons.visibility : Icons.visibility_off),
				),
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