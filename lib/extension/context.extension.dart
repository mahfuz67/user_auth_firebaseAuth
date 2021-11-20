
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension ContextExtension on BuildContext {

  void read(Provider provider) {
    WidgetRef ref = WidgetRef as WidgetRef;
    ref.read(provider);
  }

}