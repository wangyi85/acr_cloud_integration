import 'package:audio_monitor/pages/home.dart';
import 'package:audio_monitor/pages/source.dart';
import 'package:audio_monitor/widgets/bottombar.dart';
import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
	Setting({super.key});

	@override
	_SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
	void onNavigate(int index) {
		switch(index) {
			case 0:
				Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
				break;
			case 1:
				Navigator.push(context, MaterialPageRoute(builder: (context) => Source()));
				break;
			case 2:
				break;
			default:
				break;
		}
	}
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			bottomNavigationBar: BottomBar(onTap: onNavigate, currentIndex: 2),
			body: Container(),
		);
	}
}