import 'package:flutter/widgets.dart';
import 'custom.dart';

class JustifiedTextPair extends StatelessWidget {
  final String left;
  final String right;

  const JustifiedTextPair({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(left, textAlign: TextAlign.left),
        CustomText(right, textAlign: TextAlign.right),
      ],
    );
  }
}
