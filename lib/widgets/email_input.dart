import 'package:flutter/material.dart';

class EmailInput extends StatefulWidget {
	Function onChanged;
	String? initialValue;
	EmailInput({super.key, required this.onChanged, this.initialValue});

	@override
	_EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
	TextEditingController _controller = TextEditingController();
	@override
	void initState() {
		super.initState();
		_controller.text = widget.initialValue ?? '';
	}
	@override
	Widget build(BuildContext context) {
		return TextField(
			controller: _controller,
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
			keyboardType: TextInputType.emailAddress,
			onChanged: (value) => widget.onChanged(value),
		);
	}
}