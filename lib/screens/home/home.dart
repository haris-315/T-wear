import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_wear/bloc/home/home_bloc.dart';
import 'package:t_wear/core/theme/theme.dart';
import 'package:t_wear/core/utils/get_theme_state.dart';
import 'package:t_wear/screens/global_widgets/custom_drawer.dart';
import 'package:t_wear/screens/global_widgets/navbar.dart';
import 'package:t_wear/screens/global_widgets/product_card.dart';
import 'package:t_wear/screens/home/product_inspection_page.dart';
import 'package:t_wear/screens/home/widgets/category.dart';
import 'package:t_wear/screens/home/widgets/custom_lazy_wrap.dart';
import 'package:t_wear/screens/home/widgets/shimmer_effect.dart';
import 'package:t_wear/screens/home/widgets/trends.dart';

// ignore: library_private_types_in_public_api
final GlobalKey<_HomeState> homeKey = GlobalKey();

class Home extends StatefulWidget {
  Home({
    key,
  }) : super(key: homeKey);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadHomeData());
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   setState(() {});
    // });
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _rotateAnimation = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    final double swidth = MediaQuery.of(context).size.width;
    final double sheight = MediaQuery.of(context).size.height;
    final CTheme themeMode = getThemeMode(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: themeMode.backgroundColor,
          appBar: NavBar(
            themeMode: themeMode,
            scrollController: scrollController,
          ),
          endDrawer: CustomDrawer(themeMode: themeMode),
          floatingActionButton: state is HomeSuccess && state.isCarted
              ? ScaleTransition(
                  scale: _scaleAnimation,
                  child: RotationTransition(
                    turns: _rotateAnimation,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (state.products['cart'] != null) {
                          Navigator.pushNamed(context, "cart",
                              arguments: [state.products['cart'], homeKey]);
                        }
                      },
                      child: Icon(
                        Icons.shopping_cart,
                        color: themeMode.iconColor,
                      ),
                    ),
                  ),
                )
              : null,
          body: SingleChildScrollView(
            controller: scrollController,
            child: state is HomeSuccess
                ? Column(
                    children: [
                      _categoryBuilder(swidth, sheight, themeMode),
                      const SizedBox(
                        height: 40,
                      ),
                      if (!state.isCategorizing)
                        TrendingPicks(
                            trendingProducts: state.products['trending'] ?? []),
                      const SizedBox(
                        height: 40,
                      ),
                      ..._buildProducts(state, swidth, sheight, themeMode)
                    ],
                  )
                : state is HomeLoading
                    ? Column(
                        children: [
                          if (state.byCategory)
                            _categoryBuilder(swidth, sheight, themeMode),
                          ShimmerEffect(
                              forCategories: state.byCategory ? true : false),
                        ],
                      )
                    : state is HomeError
                        ? Center(
                            child: Text(state.message),
                          )
                        : const Placeholder(),
          ),
        );
      },
    );
  }

  SizedBox _categoryBuilder(double swidth, double sheight, CTheme themeMode) {
    return SizedBox(
      height: swidth <= 500
          ? swidth < 400
              ? swidth * 0.22
              : swidth * 0.19
          : sheight * 0.35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: swidth <= 500
                ? EdgeInsets.only(
                    left: swidth <= 400 ? 10 : 19.0,
                    top: 22,
                    bottom: 22,
                    right: swidth <= 400 ? 10 : 19.0)
                : const EdgeInsets.only(
                    left: 19, right: 19, top: 16, bottom: 16),
            child: CategoryItem(
              category: categories[index],
              themeMode: themeMode,
            ),
          );
        },
      ),
    );
  }

  Iterable _buildProducts(
      HomeSuccess state, double swidth, double sheight, CTheme themeMode) {
    bool smallScreen = swidth <= 500;
    return state.products.keys.map(
      (key) => key == 'trending' || key == 'cart'
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: swidth),
                  Padding(
                    padding: EdgeInsets.only(left: smallScreen ? 0 : 25.0),
                    child: Text(
                      key.toString().toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: themeMode.primTextColor),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomLazyWrap(
                      itemCount: state.products[key]!.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          onTap: () {
                            print(state.isCarted);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                        product: state.products[key]![index])));
                            // Navigator.pushNamed(context, "inspect-widget",

                            //     arguments: state.products[key]![index]);
                          },
                          carted: state.products['cart'] != null
                              ? state.products['cart']!.any((product) =>
                                      state.products[key]![index] == product)
                                  ? true
                                  : false
                              : false,
                          product: state.products[key]![index],
                          cartAction: (cproduct) {
                            if (state.isCarted == false) {
                              _controller.forward();
                            }
                            context.read<HomeBloc>().add(LoadHomeData(
                                isCarting: true,
                                product: cproduct,
                                productsMap: state.products));
                          },
                        );
                      }),
                ],
              ),
            ),
    );
  }
}
