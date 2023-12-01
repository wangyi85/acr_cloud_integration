import 'dart:io';

import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/pages/auth/login.dart';
import 'package:audio_monitor/pages/home.dart';
import 'package:audio_monitor/store/actions/device_info_action.dart';
import 'package:device_imei/device_imei.dart';
import 'package:device_info/device_info.dart';
import 'package:device_uuid/device_uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
	Splash({super.key});

	@override
	_SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
	static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
	bool _goNext = false;
	bool _rememberMe = false;

	@override
	void initState() {
		super.initState();
		getRememberState();
		Future.delayed(const Duration(seconds: 2), () {
			setState(() {
				_goNext = true;
			});
		});
	}

	Future<void> getRememberState() async {
		var prefs = await SharedPreferences.getInstance();
		if (prefs.getBool('isRememberMe') == true) {
			setState(() {
				_rememberMe = true;
			});
		}
	}

	Future<bool> _handleLocationPermission() async {
		bool serviceEnabled;
		LocationPermission permission;
		
		serviceEnabled = await Geolocator.isLocationServiceEnabled();
		if (!serviceEnabled) {
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
				content: Text('Location services are disabled. Please enable the services')));
			return false;
		}
		permission = await Geolocator.checkPermission();
		if (permission == LocationPermission.denied) {
			permission = await Geolocator.requestPermission();
			if (permission == LocationPermission.denied) {   
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('Location permissions are denied')));
				return false;
			}
		}
		if (permission == LocationPermission.deniedForever) {
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
				content: Text('Location permissions are permanently denied, we cannot request permissions.')));
			return false;
		}
		return true;
	}

	Future<String> _getAddressFromLatLng(Position position) async {
		if (position == null) return '';
		try {
			List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
		Placemark place = placeMarks[0];
		return '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
		} catch (e) {
			print(e);
			return '';
		}
	}

	Future<Position?> _getCurrentPosition() async {
		final hasPermission = await _handleLocationPermission();
		if (!hasPermission) return null;
		try {
			final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
			return position;
		} catch (e) {
			print(e);
			return null;
		}
	}

	void getDeviceInfo(store) async {
		var prefs = await SharedPreferences.getInstance();
		final location = await _getCurrentPosition();
		if (location != null) {
			prefs.setString('longitude', location.longitude.toString());
			prefs.setString('latitude', location.latitude.toString());
			final address = await _getAddressFromLatLng(location);
			prefs.setString('locationAddress', address);
		}
		try {
			var imei = await DeviceImei().getDeviceImei() ?? '';
			store.dispatch(SetIMEI(imei));
			prefs.setString('imei', imei);
		} catch (e) {
			print(e.toString());
		}
		var uuid = await DeviceUuid().getUUID() ?? '';
		store.dispatch(SetUUID(uuid));
		prefs.setString('uuid', uuid);
		try {
			if (Platform.isAndroid) {
				var deviceData = await deviceInfoPlugin.androidInfo;
				store.dispatch(SetDeviceModel(deviceData.model));
				prefs.setString('model', deviceData.model);
				store.dispatch(SetBrand(deviceData.brand));
				prefs.setString('brand', deviceData.brand);
			} else if (Platform.isIOS) {
				var deviceData = await deviceInfoPlugin.iosInfo;
				store.dispatch(SetDeviceModel(deviceData.model));
				store.dispatch(SetBrand(deviceData.name));
				prefs.setString('model', deviceData.model);
				prefs.setString('brand', deviceData.name);
			}
		} on PlatformException {
			print('platform exception');
		}
	}

	@override
	Widget build(BuildContext context) {
		if (_goNext) {
			if (_rememberMe) return Home();
			return Login();
		}
		return StoreConnector<AppState, AppState>(
			onInit: (store) => getDeviceInfo(store),
			converter: (store) => store.state,
			builder: (context, state) => Scaffold(
				body: Container(
					color: Colors.white,
					width: double.infinity,
					height: double.infinity,
					alignment: Alignment.center,
					padding: const EdgeInsets.symmetric(horizontal: 20),
					child: Image.asset('assets/images/logo.jpg'),
				),
			)
		);
	}
}