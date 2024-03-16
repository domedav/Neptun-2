import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableTextSpan extends StatelessWidget{
  final VoidCallback callback;
  final String text;
  final TextStyle style;

  const ClickableTextSpan({super.key, required this.callback, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        HapticFeedback.lightImpact();
        callback();
      },
      child: Text(
        text,
        style: style,
      ),
      onLongPress: ()async{
        HapticFeedback.lightImpact();
        await Clipboard.setData(ClipboardData(text: text));
        if(!Platform.isAndroid){
          return;
        }
        Fluttertoast.showToast(
          msg: 'Másolva! 📋',
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 14,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: const Color.fromRGBO(0x1A, 0x1A, 0x1A, 1.0),
          textColor: Colors.white,
        );
      },
    );
  }

  static WidgetSpan getNewClickableSpan(VoidCallback callback, String text, TextStyle style){
    return WidgetSpan(child: ClickableTextSpan(callback: callback, text: text, style: style));
  }

  static TextStyle getStockStyle(){
    return const TextStyle(color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0), decoration: TextDecoration.underline, decorationColor: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0));
  }

  static VoidCallback getNewOpenLinkCallback(String text){
    return ()async{
      if(!Platform.isAndroid){
        return;
      }
      final url = Uri.parse(text);
      await launchUrl(url);
    };
  }
}