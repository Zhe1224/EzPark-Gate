import 'package:flutter/widgets.dart';

import 'justified_text_pair.dart';

class NowTimeDisplay extends StatelessWidget {

  const NowTimeDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return JustifiedTextPair(
      left: "Time:",
      right: DateTime.now().toString(),
    );
  }
}
