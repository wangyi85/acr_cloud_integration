import 'dart:convert';

import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/pages/auth/signup.dart';
import 'package:audio_monitor/pages/home.dart';
import 'package:audio_monitor/store/actions/user_action.dart';
import 'package:audio_monitor/utils/consts.dart';
import 'package:audio_monitor/widgets/email_input.dart';
import 'package:audio_monitor/widgets/password_input.dart';
import 'package:audio_monitor/widgets/toaster_message.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
	Login({super.key});

	@override
	_LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
	String _email = '';
	String _password = '';
	bool _rememberMe = false;

	void onFieldChanged(field, value) {
		switch (field) {
			case 'email':
				setState(() {
					_email = value;
				});
				break;
			case 'password':
				setState(() {
					_password = value;
				});
				break;
			default:
				break;
		}
	}

	void onLogin() async {
		var store = StoreProvider.of<AppState>(context);
		if (_email == '') {
			setState(() {
				_email = store.state.user.email;
			});
		}
		if (_email == '') {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage('Please insert your email address'));
			return;
		}
		else if (!EmailValidator.validate(_email)) {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage('Invalid email format!'));
			return;
		}
		else if (_password == '') {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage('Please insert your password'));
			return;
		}

		try {
			var response = (await http.post(Uri.parse('$serverBaseUrl/login'), 
				headers: <String, String>{
					'Content-Type': 'application/json; charset=UTF-8'
				},
				body: jsonEncode(<String, dynamic>{
					'email': _email,
					'password': _password
				})
			));
			var data = jsonDecode(response.body);
			if (data['status'] == 'success') {
				if (_rememberMe) {
					var prefs = await SharedPreferences.getInstance();
					prefs.setBool('isRememberMe', true);
					prefs.setInt('userId', data['user']['_id']);
					prefs.setString('name', data['user']['name']);
					prefs.setString('lastName', data['user']['last_name']);
					prefs.setString('email', data['user']['email']);
					prefs.setString('gender', data['user']['gender']);
				}
				store.dispatch(SetUser(
					User(
						id: data['user']['_id'],
						name: data['user']['name'],
						lastName: data['user']['last_name'],
						email: data['user']['email'],
						gender: data['user']['gender']
					)
				));
				if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
			} else {
				if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage(data['comment']));
			}
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage(e.toString()));
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: StoreConnector<AppState, AppState>(
				converter: (store) => store.state,
				builder: (context, state) => Container(
					width: double.infinity,
					height: double.infinity,
					color: Colors.white,
					padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
					child: Stack(
						alignment: Alignment.center,
						children: [
							Positioned.fill(
								child: ListView(
									children: [
										Padding(
											padding: const EdgeInsets.only(top: 30, bottom: 10),
											child: Image.asset('assets/images/logo.jpg'),
										),
										const Padding(
											padding: EdgeInsets.only(bottom: 30),
											child: Text(
												'Accedi alla piattaforma',
												style: TextStyle(
													fontFamily: 'Futura',
													fontSize: 20,
													fontWeight: FontWeight.w700,
													color: Colors.black
												),
											),
										),
										Padding(
											padding: const EdgeInsets.symmetric(vertical: 15),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													const Text(
														'Email',
														style: TextStyle(
															fontFamily: 'Futura',
															fontSize: 20,
															fontWeight: FontWeight.w500,
															color: Color(0xFF424956)
														),
													),
													const SizedBox(height: 10,),
													EmailInput(initialValue: state.user.email, onChanged: (value) => onFieldChanged('email', value),)
												],
											),
										),
										Padding(
											padding: const EdgeInsets.symmetric(vertical: 15),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													const Text(
														'Password',
														style: TextStyle(
															fontFamily: 'Futura',
															fontSize: 20,
															fontWeight: FontWeight.w500,
															color: Color(0xFF424956)
														),
													),
													const SizedBox(height: 10,),
													PasswordInput(onChanged: (value) => onFieldChanged('password', value),)
												],
											),
										),
										InkWell(
											onTap: () {
												setState(() {
													_rememberMe = !_rememberMe;
												});
											},
											child: Row(
												mainAxisAlignment: MainAxisAlignment.start,
												mainAxisSize: MainAxisSize.min,
												children: [
													Checkbox(
														fillColor: const MaterialStatePropertyAll(Colors.transparent),
														activeColor: Colors.black,
														checkColor: Colors.black,
														side: MaterialStateBorderSide.resolveWith((states) => const BorderSide(color: Colors.black)),
														visualDensity: VisualDensity.compact,
														value: _rememberMe,
														onChanged: (value) {
															setState(() {
																_rememberMe = value!;
															});
														},
													),
													const Text(
														'Ricordami',
														style: TextStyle(
															fontFamily: 'Futura',
															fontSize: 16,
															fontWeight: FontWeight.w400,
															color: Color(0xff424956)
														),
													)
												],
											),
										),
										TextButton(
											onPressed: onLogin,
											// onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())),
											child: Container(
												width: double.infinity,
												alignment: Alignment.center,
												color: const Color(0xff565e6d),
												padding: const EdgeInsets.symmetric(vertical: 10),
												child: const Text(
													'Accedi',
													style: TextStyle(
														fontFamily: 'Futura',
														fontSize: 20,
														fontWeight: FontWeight.w400,
														color: Colors.white
													),
												),
											)
										)
									],
								)
							),
							Positioned(
								bottom: 0,
								child: Row(
									mainAxisAlignment: MainAxisAlignment.center,
									mainAxisSize: MainAxisSize.min,
									children: [
										const Text(
											'Non Hai un account?',
											style: TextStyle(
												fontFamily: 'Futura',
												fontSize: 16,
												fontWeight: FontWeight.w400,
												color: Colors.black
											),
										),
										TextButton(
											onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Signup())),
											child: const Text(
												'Registrati',
												style: TextStyle(
													fontFamily: 'Futura',
													fontSize: 16,
													fontWeight: FontWeight.w500,
													color: Colors.black
												),
											)
										)
									],
								)
							)
						],
					),
				),
			),
		);
	}
}