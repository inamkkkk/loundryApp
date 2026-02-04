import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loundryapp/core/theme/white_label_theme.dart';
import 'package:loundryapp/features/pos/presentation/screens/pos_scaffold.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'LaundryPOS',
          debugShowCheckedModeBanner: false,
          theme: WhiteLabelTheme.themeData, // New Theme
          home: const PosScaffold(), // New Home Shell
        );
      },
    );
  }
}
