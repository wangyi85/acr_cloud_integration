import 'package:flutter/material.dart';

class StopRecBackBtn extends StatelessWidget {
	Function onStop;
	StopRecBackBtn({super.key, required this.onStop});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () => onStop(),
			child: Container(
				width: 260,
				height: 260,
				decoration: BoxDecoration(
					color: const Color(0xffbfc7ff),
					borderRadius: BorderRadius.circular(260)
				),
				alignment: Alignment.center,
				child: Container(
					width: 200,
					height: 200,
					decoration: BoxDecoration(
						color: const Color(0xff4f65ff),
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