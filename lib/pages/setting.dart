import 'package:audio_monitor/pages/auth/login.dart';
import 'package:audio_monitor/pages/home.dart';
import 'package:audio_monitor/pages/source.dart';
import 'package:audio_monitor/widgets/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

	void onLogout() async {
		var prefs = await SharedPreferences.getInstance();
		prefs.setBool('isRememberMe', false);
		if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Login()), ModalRoute.withName('/'));
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			bottomNavigationBar: BottomBar(onTap: onNavigate, currentIndex: 2),
			body: Container(
				width: double.infinity,
				height: double.infinity,
				padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
				color: Colors.white,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.start,
					crossAxisAlignment: CrossAxisAlignment.center,
					children: [
						Padding(
							padding: const EdgeInsets.only(top: 30, bottom: 10),
							child: Image.asset('assets/images/logo.jpg')
						),
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
							child: InkWell(
								onTap: onLogout,
								child: Row(
									children: const [
										Icon(Icons.logout_outlined),
										SizedBox(width: 10,),
										Text(
											'Log out',
											style: TextStyle(
												fontFamily: 'Futura',
												fontSize: 20,
												fontWeight: FontWeight.w500,
												color: Colors.black
											),
										)
									],
								),
							),
						)
					],
				)
			),
		);
	}
}