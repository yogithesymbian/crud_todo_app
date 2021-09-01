import 'package:crud_todo_app/navigator/crud_todo_information_parser.dart';
import 'package:crud_todo_app/navigator/crud_todo_router_delegate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: TodoListApp()));
}

class TodoListApp extends StatefulWidget {
  const TodoListApp({Key? key}) : super(key: key);

  @override
  _TodoListAppState createState() => _TodoListAppState();
}

class _TodoListAppState extends State<TodoListApp> {
  final _todoRouterDelegate = CrudTodoRouterDelegate();
  final _todoInfoParser = CrudTodoInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'To-Do List App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      routerDelegate: _todoRouterDelegate,
      routeInformationParser: _todoInfoParser,
      backButtonDispatcher: RootBackButtonDispatcher(),
    );
  }
}
