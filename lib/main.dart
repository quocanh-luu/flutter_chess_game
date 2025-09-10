import 'package:chess_game/blocs/login_bloc.dart';
import 'package:chess_game/repositories/user_repository.dart';
import 'package:chess_game/utils/theme_manager.dart';
import 'package:chess_game/utils/language_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chess_game/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
void main() async{
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final repo = UserRepository();
  runApp(
    MultiProvider(
      providers: [
        BlocProvider(create: (_) => LoginBloc(repo)),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => LanguageManager()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeManager, LanguageManager>(
      builder: (context, themeManager, languageManager, child) {
        return MaterialApp(
          navigatorObservers: [routeObserver],
          title: AppLocalizations.translate('chess_game', languageManager.locale),
          debugShowCheckedModeBanner: false,
          theme: ThemeManager.lightTheme,
          darkTheme: ThemeManager.darkTheme,
          themeMode: themeManager.themeMode,
          locale: languageManager.locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('de', 'DE'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomePage(),
        );
      },
    );
  }
}



