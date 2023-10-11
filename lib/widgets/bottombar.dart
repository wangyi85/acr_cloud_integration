import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
	Function onTap;
	int currentIndex;
	BottomBar({super.key, required this.onTap, required this.currentIndex});

	@override
	_BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			child: BottomNavigationBar(
				onTap: (index) => widget.onTap(index),
				currentIndex: widget.currentIndex,
				selectedItemColor: Colors.black,
				unselectedItemColor: const Color(0xff565e6d),
				items: const [
					BottomNavigationBarItem(
						icon: Icon(Icons.home_outlined),
						activeIcon: Icon(Icons.home_filled),
						label: 'Home'
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.tv_outlined),
						activeIcon: Icon(Icons.tv),
						label: 'Source'
					),
					BottomNavigationBarItem(
						icon: Icon(Icons.account_circle_outlined),
						activeIcon: Icon(Icons.account_circle),
						label: 'Setting'
					)
				]
			),
		);
	}
}