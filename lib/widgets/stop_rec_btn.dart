import 'package:flutter/material.dart';

class StopRecBtn extends StatelessWidget {
	Function onStop;
	StopRecBtn({super.key, required this.onStop});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () => onStop(),
			child: Container(
				width: 130,
				height: 130,
				decoration: BoxDecoration(
					color: const Color(0xffffadad),
					borderRadius: BorderRadius.circular(260)
				),
				alignment: Alignment.center,
				child: Container(
					width: 100,
					height: 100,
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
							fontSize: 20,
							fontWeight: FontWeight.w500,
							color: Colors.black
						),
					),
				),
			),
		);
	}
}