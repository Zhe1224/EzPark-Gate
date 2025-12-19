import 'package:flutter/material.dart';
import '../styles.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.title, required this.onPressed});

  static final bgColor=AppStyles.buttonColor;
  static const textStyle=AppStyles.defaultTextStyle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: AppStyles.defaultPadding,
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: textStyle,
      ),
    );
  }
}

//customtext is text but with custom style applied. can be overriden
class CustomText extends Text {

  //constructor invoke super, apply default style
  const CustomText(super.data,{super.textAlign=AppStyles.defaultTextAlign,super.style=AppStyles.defaultTextStyle,super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppStyles.quarterLinePadding,
      child: Text(
        data??'',
        style: AppStyles.defaultTextStyle,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        maxLines: 1,
      ),
    );
  }
}

class ConfirmButton extends CustomButton{
  static final bgColor=AppStyles.confirmButtonColor;

  const ConfirmButton({super.key, required super.title, required super.onPressed});
}

class DisabledButton extends CustomButton{
  static final bgColor=AppStyles.confirmButtonColor;
  static final textStyle=AppStyles.disabledButtonTextStyle;

  const DisabledButton({super.key, required super.title, required super.onPressed});
}
class SeriousButton extends CustomButton{
  static final bgColor=AppStyles.seriousButtonColor;
  static final textStyle=AppStyles.disabledButtonTextStyle;

  const SeriousButton({super.key, required super.title, required super.onPressed});
}