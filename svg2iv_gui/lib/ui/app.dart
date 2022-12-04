import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/main_page_bloc.dart';
import '../state/main_page_state.dart';
import '../ui/main_page.dart';
import '../util/custom_material_localizations.dart';

const _androidGreen = Color(0xFF00DE7A);
const _androidBlue = Color(0xFF2196F3);

class App extends StatelessWidget {
  const App({super.key, required this.bloc});

  static const name = 'svg2iv';

  final MainPageBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc,
      child: BlocBuilder<MainPageBloc, MainPageState>(
        bloc: bloc,
        builder: (context, _) {
          final textTheme = Typography.material2018()
              .englishLike
              .apply(fontFamily: 'WorkSans');
          const inputDecorationTheme = InputDecorationTheme(
            border: OutlineInputBorder(),
          );
          return MaterialApp(
            home: const MainPage(),
            title: 'svg2iv',
            theme: ThemeData.from(
              colorScheme: const ColorScheme.light(
                primary: _androidBlue,
                secondary: _androidGreen,
              ),
              textTheme: textTheme,
            ).copyWith(inputDecorationTheme: inputDecorationTheme),
            darkTheme: ThemeData.from(
              colorScheme: const ColorScheme.dark(
                primary: _androidGreen,
                secondary: _androidBlue,
              ),
              textTheme: textTheme,
            ).copyWith(inputDecorationTheme: inputDecorationTheme),
            themeMode: bloc.state.themeMode,
            localizationsDelegates: const [
              CustomMaterialLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
