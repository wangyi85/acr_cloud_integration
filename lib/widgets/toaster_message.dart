import 'package:flutter/material.dart';

class ToasterMessage {
	static SnackBar showErrorMessage(String message) {
		return SnackBar(
			behavior: SnackBarBehavior.floating,
			backgroundColor: Colors.transparent,
			elevation: 0,
			duration: const Duration(seconds: 3),
			content: Container(
				padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
				decoration: const BoxDecoration(
					color: Color(0xFFC72C41),
					borderRadius: BorderRadius.all(Radius.circular(15))
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const Text(
							'Ooops, Error!',
							style: TextStyle(
								fontFamily: 'Almarai',
								fontSize: 18,
								fontWeight: FontWeight.w700,
								color: Colors.white
							),
						),
						const SizedBox(height: 5,),
						Text(
							message,
							style: const TextStyle(
								fontFamily: 'Almarai',
								fontSize: 16,
								fontWeight: FontWeight.w400,
								color: Colors.white
							),
							overflow: TextOverflow.ellipsis,
							maxLines: 2,
						)
					],
				)
			)
		);
	}

	static SnackBar showSuccessMessage(String message) {
		return SnackBar(
			behavior: SnackBarBehavior.floating,
			backgroundColor: Colors.transparent,
			elevation: 0,
			duration: const Duration(seconds: 3),
			content: Container(
				padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
				decoration: const BoxDecoration(
					color: Color.fromRGBO(62, 154, 77, 1),
					borderRadius: BorderRadius.all(Radius.circular(15))
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const Text(
							'Wow, Success!',
							style: TextStyle(
								fontFamily: 'Almarai',
								fontSize: 18,
								fontWeight: FontWeight.w700,
								color: Colors.white
							),
						),
						const SizedBox(height: 5,),
						Text(
							message,
							style: const TextStyle(
								fontFamily: 'Almarai',
								fontSize: 16,
								fontWeight: FontWeight.w400,
								color: Colors.white
							),
							overflow: TextOverflow.ellipsis,
							maxLines: 2,
						)
					],
				)
			)
		);
	}

	static SnackBar showWarningMessage(String message) {
		return SnackBar(
			behavior: SnackBarBehavior.floating,
			backgroundColor: Colors.transparent,
			elevation: 0,
			duration: const Duration(seconds: 3),
			content: Container(
				padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
				decoration: const BoxDecoration(
					color: Colors.amber,
					borderRadius: BorderRadius.all(Radius.circular(15))
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const Text(
							'Warning!',
							style: TextStyle(
								fontFamily: 'Almarai',
								fontSize: 18,
								fontWeight: FontWeight.w700,
								color: Colors.white
							),
						),
						const SizedBox(height: 5,),
						Text(
							message,
							style: const TextStyle(
								fontFamily: 'Almarai',
								fontSize: 16,
								fontWeight: FontWeight.w400,
								color: Colors.white
							),
							overflow: TextOverflow.ellipsis,
							maxLines: 2,
						)
					],
				)
			)
		);
	}
}