import 'package:flutter/material.dart';

class StopRecBtn extends StatelessWidget {
	Function onStop;
	StopRecBtn({super.key, required this.onStop});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () => onStop(),
			child: Container(
				width: 260,
				height: 260,
				decoration: BoxDecoration(
					color: const Color(0xffffadad),
					borderRadius: BorderRadius.circular(260)
				),
				alignment: Alignment.center,
				child: Container(
					width: 200,
					height: 200,
					decoration: BoxDecoration(
						color: const Color(0xffff5e5e),
						borderRadius: BorderRadius.circular(200)
					),
					alignment: Alignment.center,
					child: const Text(
						'STOP\nREC',
						textAlign: TextAlign.center,
						style: TextStyle(
							fontFamily: 'Futura',
							fontSize: 30,
							fontWeight: FontWeight.w500,
							color: Colors.black
						),
					),
				),
			),
		);
	}
}