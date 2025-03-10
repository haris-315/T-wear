import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_wear/bloc/home/home_bloc.dart';
import 'package:t_wear/core/theme/cubit/theme_cubit.dart';
import 'package:t_wear/core/theme/theme.dart';
import 'package:t_wear/core/utils/get_admin_stat.dart';
import 'package:t_wear/core/utils/screen_size.dart';
import 'package:t_wear/screens/global_widgets/nav_item.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  final IconButton? popBtn;
  const NavBar(
      {super.key,
      required this.themeMode,
      required this.scrollController,
      this.popBtn});

  final CTheme themeMode;

  List<NavItem> navItems(CTheme themeMode, BuildContext context, bool isAdmin) {
    String? routeName = ModalRoute.of(context)!.settings.name;
    return [
      if (routeName != "home")
        NavItem(
          title: "Home",
          themeMode: themeMode,
          action: () {
            Navigator.pushReplacementNamed(context, "home");
          },
        ),
      if (!isAdmin)
        if (routeName != "profile")
          NavItem(
            title: "Profile",
            themeMode: themeMode,
            action: () {
              Navigator.pushNamed(context, "profile");
            },
          ),
      if (isAdmin)
        if (routeName != "dashboard")
          NavItem(
            title: "Dashboard",
            themeMode: themeMode,
            action: () {
              Navigator.pushNamed(context, "dashboard");
            },
          ),
      if (routeName == "home")
        NavItem(
          title: "Dev Contact",
          themeMode: themeMode,
          action: () {
            scrollController.animateTo(scrollController.position.extentTotal,
                duration: Duration(milliseconds: 1200), curve: Curves.easeIn);
          },
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final [width, height] = getScreenSize(context);
    bool admin = isAdmin(context);
    return AppBar(
      iconTheme: IconThemeData(color: themeMode.iconColor),
      backgroundColor: themeMode.appBarColor,
      leading: popBtn,
      title: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            scrollController.animateTo(0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCirc);
          },
          child: Text(
            "Twear",
            style:
                TextStyle(color: themeMode.primTextColor, fontFamily: "jman"),
          ),
        ),
      ),
      actions: [
        if (ModalRoute.of(context)?.settings.name == "home" ||
            ModalRoute.of(context)?.settings.name == "/")
          SearchField(themeMode: themeMode, width: width),
        if (width <= 700)
          DrawerButton(
            color: themeMode.iconColor,
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          )
        else ...[
          IconButton(
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme(
                  themeMode.getThemeType().runtimeType == Dark().runtimeType
                      ? Light()
                      : Dark());
            },
            icon: themeMode.getThemeType().runtimeType == Dark().runtimeType
                ? const Icon(
                    Icons.light_mode_sharp,
                    color: Colors.white,
                  )
                : Transform.rotate(
                    angle: 12,
                    child: const Icon(
                      Icons.nightlight_round_sharp,
                      color: Colors.black,
                    ),
                  ),
          ),
          ...navItems(themeMode, context, admin)
        ]
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.themeMode,
    required this.width,
  });

  final CTheme themeMode;
  final dynamic width;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final FocusNode _fNode = FocusNode();
  bool isSearchBarFocused = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fNode.addListener(() {
      if (_fNode.hasFocus) {
        setState(() {
          isSearchBarFocused = true;
        });
      } else {
        setState(() {
          isSearchBarFocused = false;
        });
      }
    });
  }

  _search(String query) {
    context.read<HomeBloc>().add(GetBySearch(query: query));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: isSearchBarFocused
                    ? widget.themeMode.borderColor2 ?? Colors.red
                    : widget.themeMode.borderColor ?? Colors.red),
            borderRadius: BorderRadius.circular(16)),
        height: 34,
        width: widget.width * .4,
        child: SearchBar(
          controller: controller,
          onChanged: (query) {
            if (query.isEmpty || query == "") {
              context.read<HomeBloc>().add(GetBySearch(query: query));
            }
          },
          focusNode: _fNode,
          onSubmitted: _search,
          overlayColor: WidgetStateColor.resolveWith((_) => Colors.transparent),
          textStyle: WidgetStateTextStyle.resolveWith(
              (_) => TextStyle(color: widget.themeMode.primTextColor)),
          shadowColor: WidgetStateColor.resolveWith((_) => Colors.transparent),
          backgroundColor: WidgetStateColor.resolveWith(
              (_) => widget.themeMode.appBarColor ?? Colors.red),
          hintText: "Search",
          hintStyle: WidgetStateProperty.resolveWith(
              (_) => TextStyle(color: widget.themeMode.primTextColor)),
          trailing: [
            InkWell(
              onTap: () {
                if (!isSearchBarFocused && controller.text.isEmpty) {
                  _search(controller.text.trim());
                } else {
                  controller.text = "";
                  _search("");
                }
              },
              child: Icon(
                !isSearchBarFocused && controller.text.isEmpty
                    ? Icons.search
                    : Icons.clear,
                size: 26,
                color: widget.themeMode.iconColor,
              ),
            ),
          ],
        ));
  }
}
