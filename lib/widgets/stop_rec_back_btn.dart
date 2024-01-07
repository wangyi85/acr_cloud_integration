import 'package:flutter/material.dart';

class StopRecBackBtn extends StatelessWidget {
	Function onStop;
	StopRecBackBtn({super.key, required this.onStop});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () => onStop(),
			child: Container(
				width: 130,
				height: 130,
				decoration: BoxDecoration(
					color: const Color(0xffbfc7ff),
					borderRadius: BorderRadius.circular(260)
				),
				alignment: Alignment.center,
				child: Container(
					width: 100,
					height: 100,
					decoration: BoxDecoration(
						color: Color.fromARGB(255, 202, 0, 24),
						borderRadius: BorderRadius.circular(200)
					),
					alignment: Alignment.center,
					child: const Text(
						'STOP',
						textAlign: TextAlign.center,
						style: TextStyle(
							fontFamily: 'Futura',
							fontSize: 20,
							fontWeight: FontWeight.w500,
							color: Color.fromARGB(255, 245, 245, 245)
						),
					),
				),
			),
		);
	}
}