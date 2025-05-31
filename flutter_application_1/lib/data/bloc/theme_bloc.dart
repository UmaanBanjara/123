import 'package:feed/config/theme/myapptheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(AppTheme.lightTheme);

  void toggleTheme() {
    emit(state.brightness == Brightness.dark
        ? AppTheme.lightTheme
        : AppTheme.darkTheme);
  }
}
