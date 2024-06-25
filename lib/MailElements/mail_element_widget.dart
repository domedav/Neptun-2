import 'dart:core';
import 'package:flutter/material.dart';
import 'package:neptun2/API/api_coms.dart';
import 'package:neptun2/Misc/popup.dart';
import 'package:neptun2/language.dart';

import '../Misc/emojirich_text.dart';
import '../colors.dart';

class MailPopupDisplayTexts{
  static String title = "";
  static List<InlineSpan> description = []; //[TextSpan(text: 'Valami szöveg\n'), ClickableTextSpan.getNewClickableSpan(ClickableTextSpan.getNewOpenLinkCallback('https://google.com'), 'https://google.com', ClickableTextSpan.getStockStyle())];
  static int mailID = 0;
}

class MailElementWidget extends StatelessWidget{
  final subject;
  final details;
  final sender;
  final sendTime;
  final isRead;
  final mailID;
  final Function(MailElementWidget) callback;

  const MailElementWidget({super.key, required this.subject, required this.details, required this.sender, required this.sendTime, required this.isRead, required this.mailID, required this.callback});

  @override
  Widget build(BuildContext context) {
    //final date = DateTime.fromMillisecondsSinceEpoch(sendTime);
    final pattern = RegExp(r'<a[^>]*>(.*?)</a>');
    List<String> parts = details.split(pattern);

    return GestureDetector(
      onTap: (){
        MailPopupDisplayTexts.title = subject;
        MailPopupDisplayTexts.description = Generic.textToInlineSpan(details);
        MailPopupDisplayTexts.mailID = mailID;

        PopupWidgetHandler(mode: 3, callback: (_){

        }, onCloseCallback: (){
          callback(this);
        });
        PopupWidgetHandler.doPopup(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          color: Colors.transparent // needed for gesture ontap hittest
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            EmojiRichText(
              text: isRead ? '📭' : '📬',
              defaultStyle: TextStyle(
                color: AppColors.getTheme().onPrimaryContainer,
                fontWeight: FontWeight.w900,
                fontSize: 20.0,
              ),
              emojiStyle: TextStyle(
                  color: AppColors.getTheme().onPrimaryContainer,
                  fontSize: 20.0,
                  fontFamily: "Noto Color Emoji"
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
            Expanded(
              flex: 10,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(
                          '$subject',
                          style: TextStyle(
                            color: AppColors.getTheme().onPrimaryContainer,
                            fontWeight: !isRead ? FontWeight.w800 : FontWeight.w500,
                            fontSize: isRead ? 15.0 : 18.0,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(
                          AppStrings.getStringWithParams(AppStrings.getLanguagePack().messagePage_SentBy, [sender]),
                          style: TextStyle(
                            color: AppColors.getTheme().textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.0,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(
                          '${(parts.join().toString()).replaceAll('\n', ' ').replaceAll('\t', ' ')}...',
                          style: TextStyle(
                            color: AppColors.getTheme().textColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 13.0,
                          ),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
            /*Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Visibility(
                  visible: false,
                  maintainState: true,
                  maintainSemantics: true,
                  maintainInteractivity: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: EmojiRichText(
                    text: '📬',
                    defaultStyle: TextStyle(
                      color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                      fontWeight: FontWeight.w900,
                      fontSize: 20.0,
                    ),
                    emojiStyle: TextStyle(
                        color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                        fontSize: 20.0,
                        fontFamily: "Noto Color Emoji"
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 20)),
                      Flexible(
                        flex: 2,
                        child: Text(
                          'Küldték: ${date.year}. ${Generic.monthToText(date.month)}. ${date.day}. ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  )
                ),
              ],
            ),*/
          ],
        )
        /*Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                EmojiRichText(
                  text: isRead ? '📭' : '📬',
                  defaultStyle: const TextStyle(
                    color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                    fontWeight: FontWeight.w900,
                    fontSize: 20.0,
                  ),
                  emojiStyle: const TextStyle(
                      color: Color.fromRGBO(0x8A, 0xB6, 0xBF, 1.0),
                      fontSize: 20.0,
                      fontFamily: "Noto Color Emoji"
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Érkezett: ${date.year}. ${Generic.monthToText(date.month)}. ${date.day}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400
                    ),
                  )
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Feladó: $sender',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                    ),
                  )
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subject,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700
              ),
            ),
          ],
        ),*/
      ),
    );
  }
}