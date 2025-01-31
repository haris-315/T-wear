import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_wear/core/theme/cubit/theme_cubit.dart';
import 'package:t_wear/core/theme/theme.dart';

class CustomDrawer extends StatefulWidget {
  final CTheme themeMode;

  const CustomDrawer({
    super.key,
    required this.themeMode,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  List<Widget> drawerItems(CTheme themeMode, BuildContext context) {
    return [
      ListTile(
        leading: Icon(Icons.home, color: themeMode.iconColor),
        title: Text("Home", style: TextStyle(color: themeMode.primTextColor)),
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.pushNamed(context, "home");
        },
      ),
      ListTile(
        leading: Icon(Icons.dashboard, color: themeMode.iconColor),
        title:
            Text("Dashboard", style: TextStyle(color: themeMode.primTextColor)),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, "products");
        },
      ),
      ListTile(
        leading: Icon(Icons.contact_page, color: themeMode.iconColor),
        title:
            Text("Contact", style: TextStyle(color: themeMode.primTextColor)),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.dark_mode, color: themeMode.iconColor),
        title: Text("Switch Theme",
            style: TextStyle(color: themeMode.primTextColor)),
        onTap: () {
          Navigator.pop(context);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ThemeCubit>().toggleTheme(
                  widget.themeMode.getThemeType().runtimeType ==
                          Dark().runtimeType
                      ? Light()
                      : Dark(),
                );
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: widget.themeMode.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: widget.themeMode.appBarColor,
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  foregroundImage: AssetImage("images/hero.jpg"),
                ),
                const SizedBox(width: 12),
                Text(
                  "Guest001A",
                  style: TextStyle(
                      color: widget.themeMode.primTextColor, fontSize: 18),
                ),
              ],
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              children: drawerItems(widget.themeMode, context),
            ),
          ),
        ],
      ),
    );
  }
}
