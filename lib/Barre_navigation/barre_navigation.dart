import 'package:flutter/material.dart';

class BarreNavigation extends StatefulWidget {
  const BarreNavigation({super.key});

  @override
  State<BarreNavigation> createState() => _BarreNavigationState();
  
}

class _BarreNavigationState extends State<BarreNavigation> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    var pages;
    return  Scaffold(
      body:pages[pageIndex],
      bottomNavigationBar: buildMyNavBar(context), 
      
    );
  }
  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 0;
              });
            },
            icon:
                pageIndex == 0
                    ? const Icon(
                      Icons.home_filled,
                      color: Colors.white,
                      size: 35,
                    )
                    : const Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 1;
              });
            },
            icon:
                pageIndex == 1
                    ? const Icon(
                      Icons.work_rounded,
                      color: Colors.white,
                      size: 35,
                    )
                    : const Icon(
                      Icons.work_outline_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 2;
              });
            },
            icon:
                pageIndex == 2
                    ? const Icon(
                      Icons.widgets_rounded,
                      color: Colors.white,
                      size: 35,
                    )
                    : const Icon(
                      Icons.widgets_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 3;
              });
            },
            icon:
                pageIndex == 3
                    ? const Icon(Icons.settings_outlined, color: Colors.white, size: 35)
                    : const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
          ),
        ],
      ),
    );
  }
}