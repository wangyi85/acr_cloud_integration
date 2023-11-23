import 'dart:convert';

import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/pages/auth/login.dart';
import 'package:audio_monitor/store/actions/user_action.dart';
import 'package:audio_monitor/utils/consts.dart';
import 'package:audio_monitor/widgets/age_input.dart';
import 'package:audio_monitor/widgets/email_input.dart';
import 'package:audio_monitor/widgets/name_input.dart';
import 'package:audio_monitor/widgets/password_input.dart';
import 'package:audio_monitor/widgets/toaster_message.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
	@override
	_SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
	String _name = '';
	String _lastName = '';
	String _age = '0';
	String _email = '';
	String _password = '';
	String _gender = 'Select';

	void onFieldChanged(field, value) {
		switch (field) {
			case 'name':
				setState(() {
					_name = value;
				});
				break;
			case 'lastname':
				setState(() {
					_lastName = value;
				});
				break;
			case 'age':
				setState(() {
					_age = value;
				});
				break;
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

	void onSignup() async {
		if (_name == '') {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage('Please insert your name'));
			return;
		}
		else if (_lastName == '') {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage('Please insert your last name'));
			return;
		}
		else if (_email == '') {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage('Please insert your email address'));
			return;
		}
		else if (_gender == 'Select') {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage('Please select your gender'));
			return;
		}
		else if (_age == '0') {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage('Please insert your age'));
			return;
		}
		else if (!EmailValidator.validate(_email)) {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage('Invalid email!'));
			return;
		}
		else if (!(num.tryParse(_age) != null)) {
			ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showErrorMessage('Invalid age!'));
			return;
		}

		var store = StoreProvider.of<AppState>(context);

		try {
			var response = (await http.post(Uri.parse('$serverBaseUrl/signup'), 
				headers: <String, String>{
					'Content-Type': 'application/json; charset=UTF-8'
				},
				body: jsonEncode(<String, dynamic>{
					'name': _name,
					'last_name': _lastName,
					'gender': _gender,
					'age': _age,
					'email': _email,
					'password': _password
				})
			));
			var data = jsonDecode(response.body);
			if (data['status'] == 'success') {
				store.dispatch(SetUser(User(id: 0, name: _name, lastName: _lastName, email: _email, gender: _gender)));
				if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
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
				builder: (context, state) => LayoutBuilder(
					builder: (BuildContext context, BoxConstraints viewportConstraints) {
						return SingleChildScrollView(
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
							child: ConstrainedBox(
								constraints: BoxConstraints(
									minHeight: viewportConstraints.maxHeight
								),
								child: IntrinsicHeight(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.stretch,
										children: <Widget>[
											Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Padding(
														padding: const EdgeInsets.only(top: 30, bottom: 10),
														child: Image.asset('assets/images/logo.jpg')
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
																	'Name',
																	style: TextStyle(
																		fontFamily: 'Futura',
																		fontSize: 20,
																		fontWeight: FontWeight.w500,
																		color: Color(0xFF424956)
																	),
																),
																const SizedBox(height: 10,),
																NameInput(onChanged: (value) => onFieldChanged('name', value),)
															],
														),
													),
													Padding(
														padding: const EdgeInsets.symmetric(vertical: 15),
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																const Text(
																	'Last Name',
																	style: TextStyle(
																		fontFamily: 'Futura',
																		fontSize: 20,
																		fontWeight: FontWeight.w500,
																		color: Color(0xFF424956)
																	),
																),
																const SizedBox(height: 10,),
																NameInput(onChanged: (value) => onFieldChanged('lastname', value))
															],
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
																EmailInput(onChanged: (value) => onFieldChanged('email', value),)
															],
														),
													),
													Padding(
														padding: const EdgeInsets.symmetric(vertical: 15),
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																const Text(
																	'Gender',
																	style: TextStyle(
																		fontFamily: 'Futura',
																		fontSize: 20,
																		fontWeight: FontWeight.w500,
																		color: Color(0xFF424956)
																	),
																),
																const SizedBox(height: 10,),
																DropdownButton<String>(
																	value: _gender,
																	items: <String>['Select', 'Male', 'Female', 'Not wish to answer']
																		.map<DropdownMenuItem<String>>((String value) {
																			return DropdownMenuItem<String>(
																			value: value,
																			child: Text(
																				value,
																				style: const TextStyle(
																					fontFamily: 'Futura',
																					fontSize: 16,
																					fontWeight: FontWeight.w400,
																					color: Color(0xFF424956)
																				),
																			),
																		);
																	}).toList(),
																	onChanged: (String? newValue) {
																		setState(() {
																			_gender = newValue!;
																		});
																	},
																),
															],
														),
													),
													Padding(
														padding: const EdgeInsets.symmetric(vertical: 15),
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																const Text(
																	'Age',
																	style: TextStyle(
																		fontFamily: 'Futura',
																		fontSize: 20,
																		fontWeight: FontWeight.w500,
																		color: Color(0xFF424956)
																	),
																),
																const SizedBox(height: 10,),
																AgeInput(onChanged: (value) => onFieldChanged('age', value),)
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
												],
											),
											Spacer(),
											TextButton(
												onPressed: onSignup,
												child: Container(
													width: double.infinity,
													alignment: Alignment.center,
													color: const Color(0xff565e6d),
													padding: const EdgeInsets.symmetric(vertical: 10),
													child: const Text(
														'Registrati',
														style: TextStyle(
															fontFamily: 'Futura',
															fontSize: 20,
															fontWeight: FontWeight.w400,
															color: Colors.white
														),
													),
												)
											),
											TextButton(
												onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Login())),
												child: Container(
													width: double.infinity,
													alignment: Alignment.center,
													padding: const EdgeInsets.symmetric(vertical: 10),
													child: const Text(
														'Torna al login',
														style: TextStyle(
															fontFamily: 'Futura',
															fontSize: 20,
															fontWeight: FontWeight.w500,
															color: Colors.black
														),
													),
												)
											)
										],
									),
								),
							),
						);
					}),
			)
		);
	}
}