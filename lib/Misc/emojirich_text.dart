import 'package:flutter/material.dart';

class EmojiRichText extends StatelessWidget {
  final String text;
  final TextStyle defaultStyle;
  final TextStyle emojiStyle;
  const EmojiRichText({super.key, required this.text, required this.defaultStyle, required this.emojiStyle});

  List<EmojiRichTextHelper> getSeparatedText(){
    List<EmojiRichTextHelper> construct = [];
    final chars = text.characters;

    bool flip = false;
    String str = "";

    for (var char in chars){
      if(flip ? isEmoji(char) : !isEmoji(char)){
        str += char;
      }
      else{
        construct.add(EmojiRichTextHelper(text: str, isEmoji: flip));
        str = "";
        flip = !flip;

        str += char;
      }
    }
    if(str.isNotEmpty){
      construct.add(EmojiRichTextHelper(text: str, isEmoji: flip));
    }

    return construct;
  }

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> textSpans = [];
    final textHelper = getSeparatedText();


    for(var txtHelper in textHelper){
      textSpans.add(TextSpan(
        text: txtHelper.text,
        style: txtHelper.isEmoji ? emojiStyle : defaultStyle,
      ));
    }

    return Text.rich(
        TextSpan(
            children: textSpans
        )
    );
  }

  // Check if the given Unicode code points represent an emoji
  bool isEmoji(String str){
    final hungarianAndAsciiRegex = RegExp(r"[\x00-\x7FáéíóöőúüűÁÉÍÓÖŐÚÜŰ]");

    return !hungarianAndAsciiRegex.hasMatch(str);
  }
}

class EmojiRichTextHelper{
  final String text;
  final bool isEmoji;
  const EmojiRichTextHelper({required this.text, required this.isEmoji});
}