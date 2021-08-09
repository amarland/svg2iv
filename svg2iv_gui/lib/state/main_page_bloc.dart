import 'package:bloc/bloc.dart';
import 'package:svg2iv_gui/state/main_page_event.dart';
import 'package:svg2iv_gui/state/main_page_state.dart';

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {
  MainPageBloc() : super(const MainPageState.initial(isThemeDark: false));

  @override
  Stream<MainPageState> mapEventToState(MainPageEvent event) async* {
    if (event is ToggleThemeButtonClicked) {
      yield MainPageState(isThemeDark: !state.isThemeDark);
    }
    else {
      throw UnimplementedError();
    }
  }
}
