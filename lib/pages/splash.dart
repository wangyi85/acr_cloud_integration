import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/pages/auth/login.dart';
import 'package:audio_monitor/store/actions/device_info_action.dart';
import 'package:device_imei/device_imei.dart';
import 'package:device_uuid/device_uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

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

	void getDeviceInfo(store) async {
		store.dispatch(SetIMEI(await DeviceImei().getDeviceImei() ?? ''));
		store.dispatch(SetDeviceModel((await DeviceImei().getDeviceInfo())!.model ?? ''));
		store.dispatch(SetUUID(await DeviceUuid().getUUID() ?? ''));
		store.dispatch(SetBrand((await DeviceImei().getDeviceInfo())!.manufacture ?? ''));
	}

	@override
	Widget build(BuildContext context) {
		if (_goNext) return Login();
		return StoreConnector<AppState, AppState>(
			onInit: (store) => getDeviceInfo(store),
			converter: (store) => store.state,
			builder: (context, state) => Scaffold(
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
			)
		);
	}
}