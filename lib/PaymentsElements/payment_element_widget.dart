import 'package:flutter/material.dart';
import 'package:neptun2/API/api_coms.dart';
import 'package:neptun2/language.dart';
import '../Misc/emojirich_text.dart';
import '../colors.dart';

class PaymentElementWidget extends StatelessWidget{
  final int ID;
  final int ammount;
  final int dueDateMs;
  final String name;
  const PaymentElementWidget({super.key, required this.ammount, required this.dueDateMs, required this.name, required this.ID});

  @override
  Widget build(BuildContext context) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final dueDate = DateTime.fromMillisecondsSinceEpoch(dueDateMs);
    final isNonTimed = dueDateMs <= 0;
    final isMissed = dueDateMs < nowMs && !isNonTimed;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: isMissed ? BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        //color: AppColors.getTheme().rootBackground,
        border: Border.all(
          color: AppColors.getTheme().errorRed,
          width: 1
        ),
      ) : null,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            name,
            style: TextStyle(
              color: AppColors.getTheme().textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              EmojiRichText(
                text: isMissed ? '🙉' : '💰',
                defaultStyle: TextStyle(
                  color: AppColors.getTheme().onPrimaryContainer,
                  fontWeight: FontWeight.w900,
                  fontSize: 20.0,
                ),
                emojiStyle: TextStyle(
                    color: AppColors.getTheme().onPrimaryContainer,
                    fontSize: isMissed ? 26.1 : 20.0,
                    fontFamily: "Noto Color Emoji"
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Text(
                    AppStrings.getStringWithParams(AppStrings.getLanguagePack().paymentPage_MoneyDisplay, [ammount]),
                    style: TextStyle(
                      color: AppColors.getTheme().onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  )
              ),
              !isNonTimed ? const Expanded(flex: 1, child: SizedBox()) : const SizedBox(),
              !isNonTimed ? Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      dueDate.year.toString(),
                      style: TextStyle(
                        color: AppColors.getTheme().textColor.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        fontSize: 12.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${Generic.monthToText(dueDate.month)} ${dueDate.day}',
                      style: TextStyle(
                        color: AppColors.getTheme().onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ) : const SizedBox(),
            ],
          ),
          !isNonTimed ? Text(
            isMissed ? AppStrings.getStringWithParams(AppStrings.getLanguagePack().paymentPage_PaymentMissedTime, [-(Duration(milliseconds: dueDateMs - nowMs).inDays + 1)]) : AppStrings.getStringWithParams(AppStrings.getLanguagePack().paymentPage_PaymentDeadlineTime, [Duration(milliseconds: dueDateMs - nowMs).inDays + 1]),
            style: TextStyle(
              color: AppColors.getTheme().textColor.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ) : const SizedBox(),
        ],
      ),
    );
  }
}