import 'package:flutter/cupertino.dart';

class TopmenuSelector extends StatelessWidget{
  const TopmenuSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(0x6C, 0x8F, 0x96, 1.0),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
  
}