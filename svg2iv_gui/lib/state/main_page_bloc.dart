import 'package:bloc/bloc.dart';
import 'package:svg2iv_gui/state/main_page_event.dart';
import 'package:svg2iv_gui/state/main_page_state.dart';

class MainPageBloc extends Bloc<MainPageEvent, MainPageState> {
  MainPageBloc() : super(const MainPageState.initial(isThemeDark: false)) {
    on<MainPageEvent>((event, emit) => emit(mapEventToState(event)));
  }

  MainPageState mapEventToState(MainPageEvent event) {
    if (event is ToggleThemeButtonClicked) {
      return MainPageState(isThemeDark: !state.isThemeDark);
    } else {
      throw UnimplementedError();
    }
  }
}
