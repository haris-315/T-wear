import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_wear/bloc/cubit/cart_cubit.dart';
import 'package:t_wear/bloc/home/home_bloc.dart';
import 'package:t_wear/core/theme/cubit/theme_cubit.dart';
import 'package:t_wear/core/theme/theme.dart';
import 'package:t_wear/core/utils/get_admin_stat.dart';
import 'package:t_wear/core/utils/get_theme_state.dart';
import 'package:t_wear/models/product_model.dart';
import 'package:t_wear/screens/global_widgets/custom_drawer.dart';
import 'package:t_wear/screens/global_widgets/navbar.dart';
import 'package:t_wear/screens/global_widgets/product_card.dart';
import 'package:t_wear/screens/home/product_inspection_page.dart';
import 'package:t_wear/screens/home/widgets/carousal_shimmer.dart';
import 'package:t_wear/screens/home/widgets/category.dart';
import 'package:t_wear/screens/home/widgets/footer.dart';
import 'package:t_wear/screens/home/widgets/shimmer_effect.dart';
import 'package:t_wear/screens/home/widgets/trends.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  bool admin = false;
  final ScrollController scrollController = ScrollController();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadHomeData(context));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!admin) {
        bool reLoad = await showConfirmationDialog(context);
        if (reLoad) {}
      }
    });
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _rotateAnimation = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: 3));
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double swidth = MediaQuery.of(context).size.width;
    final double sheight = MediaQuery.of(context).size.height;
    final CTheme themeMode = getThemeMode(context);
    admin = isAdmin(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: themeMode.backgroundColor,
          appBar: NavBar(
            themeMode: themeMode,
            scrollController: scrollController,
          ),
          endDrawer: CustomDrawer(themeMode: themeMode),
          floatingActionButton: ScaleTransition(
            scale: _scaleAnimation,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: themeMode.borderColor ?? Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    gradient: LinearGradient(colors: [
                      themeMode.buttonColor!.withValues(alpha: .7),
                      themeMode.buttonColor!.withValues(alpha: .2)
                    ])),
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    Navigator.pushNamed(context, "cart");
                  },
                  child: Icon(
                    Icons.shopping_cart,
                    color: themeMode.iconColor,
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            controller: scrollController,
            child: state is HomeSuccess
                ? BlocBuilder<CartCubit, CartState>(
                    builder: (context, cartState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _categoryBuilder(swidth, sheight, themeMode),
                          const SizedBox(
                            height: 40,
                          ),
                          if (!state.isCategorizing)
                            TrendingPicks(
                                trendingProducts:
                                    state.products['trending'] ?? []),
                          const SizedBox(
                            height: 40,
                          ),
                          _buildProducts(
                              state,
                              swidth,
                              sheight,
                              state.isCategorizing,
                              themeMode,
                              cartState is CartSuccess
                                  ? cartState.cartedProdcuts
                                  : []),
                          SizedBox(
                            height: 20,
                          ),
                          Footer()
                        ],
                      );
                    },
                  )
                : state is HomeLoading
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (state.byCategory)
                            _categoryBuilder(swidth, sheight, themeMode)
                          else
                            SizedBox(
                              height: swidth <= 500 ? 104 : sheight * 0.35,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 18.0),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categories.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                        padding: swidth <= 500
                                            ? EdgeInsets.only(
                                                left: swidth <= 400 ? 10 : 19.0,
                                                top: 22,
                                                bottom: 22,
                                                right:
                                                    swidth <= 400 ? 10 : 19.0)
                                            : const EdgeInsets.only(
                                                left: 19,
                                                right: 19,
                                                top: 16,
                                                bottom: 16),
                                        child: ShimmerLoadingEffect(
                                          isCategory: true,
                                        ));
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            TrendingPicksShimmer(),
                            SizedBox(height: 20,),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: List<ShimmerLoadingEffect>.generate(
                                12, (index) => ShimmerLoadingEffect()),
                          )
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
    ScrollController controller = ScrollController();
    return SizedBox(
      height: swidth <= 500 ? 104 : sheight * 0.35,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0, right: 8.0),
        child: Scrollbar(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListView.builder(
              controller: controller,
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
          ),
        ),
      ),
    );
  }

  Widget _buildProducts(HomeSuccess state, double swidth, double sheight,
      bool isForCategory, CTheme themeMode, List<Product> cartedProducts) {
    bool smallScreen = swidth <= 500;

    return Wrap(
        spacing: smallScreen ? 3 : 14,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: state.products.keys
            .expand((key) => [
                  if (key == "trending")
                    SizedBox()
                  else ...[
                    if (isForCategory)
                      SizedBox(
                        width: swidth,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: smallScreen ? 12 : 25.0,
                                bottom: 18,
                                top: 8),
                            child: Text(
                              key.toString().toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  color: themeMode.primTextColor),
                            ),
                          ),
                        ),
                      ),
                    ...state.products[key]!.map((product) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: ProductCard(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailPage(product: product)));
                          },
                          carted: cartedProducts.contains(product),
                          product: product,
                          cartAction: (cproduct) {
                            context
                                .read<CartCubit>()
                                .addToCart(cproduct, cartedProducts);
                          },
                        ),
                      );
                    })
                  ],
                ])
            .toList());
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    double width = MediaQuery.of(context).size.width;
    CTheme themeMode = context.read<ThemeCubit>().state;
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SizedBox(
              width: width <= 600 ? width * .7 : width * .3,
              child: AlertDialog(
                title: Text(
                  "Admin Access",
                  style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.waving_hand,
                      color: Colors.yellowAccent,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Hello visitor, since this is just a showcase project everyone is allowed to visit it as admin. Would you like to visit the site as admin?",
                      maxLines: 5,
                      style: TextStyle(
                          color: themeMode.primTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("No"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Yes"),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;
  }
}
