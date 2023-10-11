import 'package:audio_monitor/pages/auth/login.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
	Splash({super.key});

	@override
	_SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
	bool _goNext = false;

	@override
	void initState() {
		super.initState();
		Future.delayed(const Duration(seconds: 2), () {
			setState(() {
				_goNext = true;
			});
		});
	}
	@override
	Widget build(BuildContext context) {
		if (_goNext) return Login();
		return Scaffold(
			body: Container(
				color: Colors.white,
				width: double.infinity,
				height: double.infinity,
				alignment: Alignment.center,
				child: const Text(
					'LOGO APP',
					style: TextStyle(
						fontFamily: 'Futura',
						fontSize: 40,
						fontWeight: FontWeight.w700,
						color: Colors.black,
					),
				),
			),
		);
	}
}