import 'package:flutter/material.dart';
///
/*Page background is colored hsv(65,0.15,0.98) by default
Texts are centered and colored hsv(0,0,0.2) by default
Texts inside disabled and serious buttons are colored hsv(0,0,0.8)
Texts immediate sibling resolved as separate lines
All text must have at least quarter-line padding all sides.
AppBar is colored hsv(211,0.45,0.81) by default
AppBar text is colored hsv(0,0,0.9)
Buttons are colored hsv(211,0.45,0.81) and bordered with color hsv(207,0.5,0.41) by default
Disabled buttons are colored hsv(0,0,0.5)
Serious buttons are colored hsv(0,0.57,1)
Chosen option buttons are colored hsv(0,0,0.9)
Confirm buttons are colored hsv(70,0.54,0.92)
Inputted texts are left-aligned
Cards are colored hsv(252,0.04,0.9) by default
Cards have alternate color hsv(212,0.18,0.86) */
class AppStyles {
  static const double fontSize=16;
  static final Color pageBackgroundColor = const HSVColor.fromAHSV(1.0,65,0.15,0.98).toColor();
  static final Color textColor = const HSVColor.fromAHSV(1.0,0,0,0.2).toColor();
  static final Color btnTextAltColor = const HSVColor.fromAHSV(1.0,0,0,0.8).toColor();
  // Color Palette using HSVColor
  static final Color appBarColor = const HSVColor.fromAHSV(1.0, 211, 0.45, 0.81).toColor(); // HSV(211, 0.45, 0.81)
  static final Color appBarTextColor = const HSVColor.fromAHSV(1.0, 0, 0, 0.9).toColor(); // RGB equivalent for HSV(0, 0, 0.9)
  static final Color buttonColor = const HSVColor.fromAHSV(1.0, 211, 0.45, 0.81).toColor(); // HSV(211, 0.45, 0.81)
  static final Color btnBorderColor = const HSVColor.fromAHSV(1.0, 207, 0.5,0.41).toColor(); 
  static final Color seriousButtonColor = const HSVColor.fromAHSV(1.0, 0, 0.57, 1).toColor(); // HSV(0, 0.57, 1)
  static final Color confirmButtonColor = const HSVColor.fromAHSV(1.0, 70, 0.54, 0.92).toColor(); // HSV(70, 0.54, 0.92)
  static final Color disabledButtonColor = const HSVColor.fromAHSV(1.0, 0, 0, 0.5).toColor(); // HSV(0, 0, 0.5)
  static final Color chosenOptionButtonColor = const HSVColor.fromAHSV(1.0, 0, 0, 0.9).toColor(); 
  static final Color cardColor = const HSVColor.fromAHSV(1.0, 252, 0.04, 0.9).toColor(); // HSV(252, 0.04, 0.9)
  static final Color alternateCardColor = const HSVColor.fromAHSV(1.0, 212, 0.18, 0.86).toColor(); // HSV(212, 0.18, 0.86)

  // Text Styles
  static const TextStyle defaultTextStyle = TextStyle(
    color: Color(0xFF333333),
    fontSize: fontSize,
    overflow:TextOverflow.clip
  );

  static const TextAlign defaultTextAlign = TextAlign.center;
  static const TextAlign inputTextAlign = TextAlign.left;

  // RGB equivalent for HSV(0, 0, 0.8)
  static final TextStyle disabledButtonTextStyle = TextStyle(
    color: btnTextAltColor,
    fontSize: fontSize,
  );

  // RGB equivalent for HSV(0, 0.57, 1)
  static final TextStyle seriousButtonTextStyle = TextStyle(
    color: btnTextAltColor,
    fontSize: fontSize,
  );

  // RGB equivalent for HSV(0, 0, 0.8)
  static final TextStyle confirmButtonTextStyle = TextStyle(
    color: textColor,
    fontSize: fontSize,
  );

  // Padding Constants
  static const EdgeInsets defaultPadding = EdgeInsets.all(8.0);
  static const EdgeInsets quarterLinePadding = EdgeInsets.all(4.0); // Quarter-line padding
}
