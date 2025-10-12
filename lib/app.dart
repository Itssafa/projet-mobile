import'package:flutter/material.dart';
import 'package:my_app/utils/theme/theme.dart';

class  App extends StatelessWidget {
  const App ({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      themeMode: ThemeMode.system,
      theme: CAppTheme.lightTheme ,
      darkTheme: CAppTheme.darkTheme,
    );
  }
}
