import 'package:flutter/material.dart';

class AddressInput extends StatefulWidget {
	Function onChanged;
	AddressInput({super.key, required this.onChanged});

	@override
	_AddressInputState createState() => _AddressInputState();
}

class _AddressInputState extends State<AddressInput> {
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
				prefixIcon: const Icon(Icons.location_on_outlined),
				border: OutlineInputBorder(
					borderSide: BorderSide.none,
					borderRadius: BorderRadius.circular(5)
				),
				focusedBorder: OutlineInputBorder(
					borderRadius: BorderRadius.circular(5),
					borderSide: BorderSide.none
				),
			),
			keyboardType: TextInputType.streetAddress,
			onChanged: (value) => widget.onChanged(value),
		);
	}
}