import 'package:audio_monitor/pages/home.dart';
import 'package:audio_monitor/widgets/email_input.dart';
import 'package:audio_monitor/widgets/password_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Login extends StatefulWidget {
	Login({super.key});

	@override
	_LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
	bool _rememberMe = false;
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Container(
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
									const Padding(
										padding: EdgeInsets.only(top: 30, bottom: 10),
										child: Text(
											'LOGO APP',
											style: TextStyle(
												fontFamily: 'Futura',
												fontSize: 30,
												fontWeight: FontWeight.w700,
												color: Colors.black
											),
										),
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
												EmailInput()
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
												PasswordInput()
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
													'Ricorddami',
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
										onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())),
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
										onPressed: (){},
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
		);
	}
}