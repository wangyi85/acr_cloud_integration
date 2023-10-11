import 'package:audio_monitor/pages/home.dart';
import 'package:audio_monitor/pages/setting.dart';
import 'package:audio_monitor/widgets/bottombar.dart';
import 'package:flutter/material.dart';

class Source extends StatefulWidget {
	Source({super.key});

	@override
	_SourceState createState() => _SourceState();
}

class _SourceState extends State<Source> {
	void onNavigate(int index) {
		switch(index) {
			case 0:
				Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
				break;
			case 1:
				break;
			case 2:
				Navigator.push(context, MaterialPageRoute(builder: (context) => Setting()));
				break;
			default:
				break;
		}
	}
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			bottomNavigationBar: BottomBar(onTap: onNavigate, currentIndex: 1),
			body: Container(),
		);
	}
}