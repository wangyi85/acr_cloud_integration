import 'package:flutter/material.dart';

class StartRecBtn extends StatelessWidget {
	Function onRecord;
	StartRecBtn({super.key, required this.onRecord});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () => onRecord(),
			child: Container(
				width: 130,
				height: 130,
				decoration: BoxDecoration(
					color: const Color(0xffbcef97),
					borderRadius: BorderRadius.circular(260)
				),
				alignment: Alignment.center,
				child: Container(
					width: 100,
					height: 100,
					decoration: BoxDecoration(
						color: const Color(0xff67d418),
						borderRadius: BorderRadius.circular(200)
					),
					alignment: Alignment.center,
					child: const Text(
						'START\nREC',
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