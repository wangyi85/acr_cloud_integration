import 'dart:io';

import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/pages/auth/login.dart';
import 'package:audio_monitor/store/actions/device_info_action.dart';
import 'package:device_imei/device_imei.dart';
import 'package:device_info/device_info.dart';
import 'package:device_uuid/device_uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Splash extends StatefulWidget {
	Splash({super.key});

	@override
	_SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
	static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
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
		try {
			store.dispatch(SetIMEI(await DeviceImei().getDeviceImei() ?? ''));
		} catch (e) {
			print(e.toString());
		}
		store.dispatch(SetUUID(await DeviceUuid().getUUID() ?? ''));
		try {
			if (Platform.isAndroid) {
				var deviceData = await deviceInfoPlugin.androidInfo;
				store.dispatch(SetDeviceModel(deviceData.model));
				store.dispatch(SetBrand(deviceData.brand));
			} else if (Platform.isIOS) {
				var deviceData = await deviceInfoPlugin.iosInfo;
				store.dispatch(SetDeviceModel(deviceData.model));
				store.dispatch(SetBrand(deviceData.name));
			}
		} on PlatformException {
			print('platform exception');
		}
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