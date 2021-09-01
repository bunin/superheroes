import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  final http.Client? client;

  MainPage({Key? key, this.client}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;
  late FocusNode focus;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc(client: widget.client);
    focus = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(
          child: MainIW(
            focus: focus,
            child: MainPageContent(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    focus.dispose();
    super.dispose();
  }
}

class MainIW extends InheritedWidget {
  final FocusNode focus;

  MainIW({required this.focus, required Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static MainIW? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainIW>();
  }
}

class MainPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainPageStateWidget(),
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
          child: SearchWidget(),
        ),
      ],
    );
  }
}

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();
  bool haveSearchedText = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
      controller.addListener(() {
        bloc.updateText(controller.text);
        final haveText = controller.text.isNotEmpty;
        if (haveText != haveSearchedText) {
          setState(() {
            haveSearchedText = haveText;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: MainIW.of(context)!.focus,
      autofocus: false,
      controller: controller,
      cursorColor: Colors.white,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 20,
        color: SuperheroesColors.white,
      ),
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: "Search",
        hintStyle: TextStyle(
          color: Colors.white54,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
        isDense: true,
        filled: true,
        fillColor: SuperheroesColors.indigo75,
        prefixIcon: Icon(
          Icons.search,
          color: Colors.white54,
          size: 24,
        ),
        suffix: GestureDetector(
          onTap: () => controller.clear(),
          child: Icon(
            Icons.clear,
            color: SuperheroesColors.white,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: haveSearchedText ? Colors.white : Colors.white24,
            width: haveSearchedText ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            width: 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);

    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return LoadingIndicator();
          case MainPageState.noFavorites:
            return InfoWithButton(
              buttonText: 'Search',
              title: 'No favorites yet',
              imageHeight: 119,
              imageTopPadding: 9,
              imageWidth: 108,
              assetImage: SuperheroesImages.ironMan,
              subtitle: 'Search and add',
              onTap: () {
                MainIW.of(context)!.focus.requestFocus();
              },
            );
          case MainPageState.minSymbols:
            return MinSymbols();
          case MainPageState.nothingFound:
            return InfoWithButton(
              buttonText: 'Search',
              title: 'Nothing found',
              imageHeight: 112,
              imageTopPadding: 16,
              imageWidth: 84,
              assetImage: SuperheroesImages.hulk,
              subtitle: 'Search for something else',
              onTap: () {
                MainIW.of(context)!.focus.requestFocus();
              },
            );
          case MainPageState.loadingError:
            return InfoWithButton(
              buttonText: 'Retry',
              title: 'Error happened',
              imageHeight: 106,
              imageTopPadding: 22,
              imageWidth: 126,
              assetImage: SuperheroesImages.superman,
              subtitle: 'Please, try again',
              onTap: bloc.retry,
            );
          case MainPageState.searchResults:
            return SuperheroesList(
              title: "Search results",
              stream: bloc.observeSearchedSuperheroes(),
            );
          case MainPageState.favorites:
            return SuperheroesList(
              title: "Your favorites",
              stream: bloc.observeFavoriteSuperheroes(),
            );
          default:
            return Center(
                child: Text(
              state.toString(),
              style: TextStyle(color: Colors.white),
            ));
        }
      },
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 110),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SuperheroesColors.blue),
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class MinSymbols extends StatelessWidget {
  const MinSymbols({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 110),
        child: Text(
          'Enter at least 3 symbols',
          style: TextStyle(
            color: SuperheroesColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class SuperheroesList extends StatelessWidget {
  final String title;
  final Stream<List<SuperheroInfo>> stream;

  const SuperheroesList({
    Key? key,
    required this.title,
    required this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<List<SuperheroInfo>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final List<SuperheroInfo> superheroes = snapshot.data!;
        return ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: superheroes.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTitleWidget(title: title);
            }

            final SuperheroInfo item = superheroes[index - 1];
            return ListTile(
              superhero: item,
              ableToSwipe: bloc.stateSubject.value == MainPageState.favorites,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 8);
          },
        );
      },
    );
  }
}

class ListTile extends StatelessWidget {
  final SuperheroInfo superhero;
  final bool ableToSwipe;

  const ListTile({
    Key? key,
    required this.superhero,
    required this.ableToSwipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        child: ableToSwipe
            ? Dismissible(
                key: ValueKey(superhero.id),
                child: Container(
                  color: SuperheroesColors.red,
                  child: SuperheroCard(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SuperheroPage(id: superhero.id),
                        ),
                      );
                    },
                    superheroInfo: superhero,
                  ),
                ),
                secondaryBackground: SwipeBGWidget(
                  direction: DismissDirection.endToStart,
                ),
                // secondaryBackground: ,
                background: SwipeBGWidget(
                  direction: DismissDirection.startToEnd,
                ),
                onDismissed: (_) => bloc.removeFromFavorites(superhero.id),
              )
            : SuperheroCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SuperheroPage(id: superhero.id),
                    ),
                  );
                },
                superheroInfo: superhero,
              ),
      ),
    );
  }
}

class SwipeBGWidget extends StatelessWidget {
  final DismissDirection direction;

  const SwipeBGWidget({
    Key? key,
    required this.direction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 70,
      alignment: direction == DismissDirection.startToEnd
          ? Alignment.centerLeft
          : Alignment.centerRight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: SuperheroesColors.red,
      ),
      child: Text(
        "Remove\nfrom\nfavorites".toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: SuperheroesColors.white,
        ),
        textAlign: direction == DismissDirection.startToEnd
            ? TextAlign.start
            : TextAlign.end,
      ),
    );
  }
}

class ListTitleWidget extends StatelessWidget {
  const ListTitleWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 90,
        left: 16,
        bottom: 12,
        right: 16,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: SuperheroesColors.white,
          fontSize: 24,
        ),
      ),
    );
  }
}
