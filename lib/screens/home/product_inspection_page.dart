import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:t_wear/bloc/cubit/cart_cubit.dart';
import 'package:t_wear/core/theme/theme.dart';
import 'package:t_wear/core/utils/get_theme_state.dart';
import 'package:t_wear/core/utils/screen_size.dart';
import 'package:t_wear/models/product_model.dart';
import 'package:t_wear/screens/global_widgets/custom_drawer.dart';
import 'package:t_wear/screens/global_widgets/navbar.dart';
import 'package:t_wear/screens/home/widgets/url_identifier.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImageIndex = 0;
  int rating = -1;
  List<Product> cartedProducts = [];
  ScrollController scrollController = ScrollController();
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  double get _discountedPrice => widget.product.discount != 0
      ? widget.product.price -
          (widget.product.price * (widget.product.discount / 100))
      : widget.product.price;

  quill.QuillController _quillController() => quill.QuillController(
        document: quill.Document.fromDelta(widget.product.details),
        readOnly: true,
        selection: const TextSelection.collapsed(offset: 0),
      );

  @override
  Widget build(BuildContext context) {
    final CTheme theme = getThemeMode(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final [width, height] = getScreenSize(context);

    return BlocBuilder<CartCubit, CartState>(builder: (context, state) {
      if (state is CartSuccess) {
        cartedProducts = state.cartedProdcuts;
      }
      final bool isCarted = cartedProducts.contains(widget.product);

      return Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: NavBar(
          themeMode: theme,
          scrollController: scrollController,
        ),
        endDrawer: CustomDrawer(themeMode: theme),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(theme, width),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: TextStyle(
                          color: theme.primTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Manufacturer: ${widget.product.company}",
                      style: TextStyle(
                          color: theme.secondaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Rs. ${_discountedPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: theme.primTextColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        if (widget.product.discount != 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Rs. ${widget.product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: theme.secondaryTextColor,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.product.stock > 0
                          ? 'In Stock (${widget.product.stock})'
                          : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.product.stock > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailsSection(theme, textTheme, _quillController()),
                    const SizedBox(height: 20),
                    _buildRatingSection(theme),
                    const SizedBox(height: 20),
                    _buildProductInfoSection(theme, width),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (isCarted) {
              Navigator.pushReplacementNamed(context, "cart");
            } else {
              context
                  .read<CartCubit>()
                  .addToCart(widget.product, cartedProducts);
            }
          },
          icon: Icon(Icons.shopping_cart, color: theme.iconColor),
          label: Text(isCarted ? 'Go to Cart' : 'Add to Cart',
              style: TextStyle(color: theme.primTextColor)),
          backgroundColor: theme.buttonColor,
        ),
      );
    });
  }

  Widget _buildImageCarousel(CTheme theme, double width) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: width <= 700
                ? width * .75
                : width <= 1000
                    ? width * .45
                    : width * .32,
            autoPlay: true,
            viewportFraction: 0.9,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() => _currentImageIndex = index);
            },
          ),
          items: widget.product.images.map((url) {
            return GestureDetector(
              onTap: () {
                // Navigator.push(MaterialPageRoute())
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: !isValidUrl(url.toString()) ? MemoryImage(url)  : NetworkImage(url),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_currentImageIndex > 0) {
                    _carouselController.previousPage();
                  } else {
                    _carouselController
                        .jumpToPage(widget.product.images.length - 1);
                  }
                },
                icon: Icon(Icons.arrow_left_outlined, color: theme.iconColor),
              ),
              _buildDotsIndicator(),
              IconButton(
                onPressed: () {
                  if (_currentImageIndex < widget.product.images.length - 1) {
                    _carouselController.nextPage();
                  } else {
                    _carouselController.jumpToPage(0);
                  }
                },
                icon: Icon(Icons.arrow_right_outlined, color: theme.iconColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDotsIndicator() {
    return DotsIndicator(
      dotsCount: widget.product.images.length,
      position: _currentImageIndex,
      decorator: DotsDecorator(
        activeColor: Colors.blueAccent,
        size: const Size.square(8.0),
        activeSize: const Size(18.0, 8.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(
      CTheme theme, TextTheme textTheme, quill.QuillController controller) {
    return DefaultTextStyle(
      style: TextStyle(color: theme.primTextColor),
      child: quill.QuillEditor(
        focusNode: FocusNode(),
        scrollController: ScrollController(),
        configurations: quill.QuillEditorConfigurations(
          customStyles: quill.DefaultStyles(color: theme.primTextColor),
          scrollable: false,
        ),
        controller: controller,
      ),
    );
  }

  Widget _buildRatingSection(CTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate this product:',
          style: TextStyle(
            color: theme.primTextColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () =>
                  setState(() => rating = rating == index ? -1 : index),
              child: Icon(Icons.star,
                  color: index <= rating ? Colors.amber : Colors.grey),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProductInfoSection(CTheme theme, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Information',
          style: TextStyle(
            color: theme.primTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            // Use 2 columns on wider screens
            if (constraints.maxWidth > 600) {
              return Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    children: [
                      _buildTableCell(
                          'Category:', widget.product.category.name, theme),
                      _buildTableCell('Size:', widget.product.size, theme),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('Gender:', widget.product.gender, theme),
                      _buildTableCell(
                          'Target Age:', widget.product.targetAge, theme),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell('Delivery:',
                          '${widget.product.delivery} days', theme),
                      _buildTableCell(
                          'Times Sold:', '${widget.product.timesSold}', theme),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildTableCell(
                          'Post Date:', widget.product.postDate, theme),
                      const SizedBox.shrink(),
                    ],
                  ),
                ],
              );
            } else {
              // Single column for mobile
              return Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                children: [
                  _buildTableRow(
                      'Category:', widget.product.category.name, theme),
                  _buildTableRow('Size:', widget.product.size, theme),
                  _buildTableRow('Gender:', widget.product.gender, theme),
                  _buildTableRow(
                      'Target Age:', widget.product.targetAge, theme),
                  _buildTableRow(
                      'Delivery:', '${widget.product.delivery} days', theme),
                  _buildTableRow(
                      'Times Sold:', '${widget.product.timesSold}', theme),
                  _buildTableRow('Post Date:', widget.product.postDate, theme),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value, CTheme theme) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: TextStyle(
              color: theme.secondaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            value,
            style: TextStyle(
              color: theme.primTextColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String label, String value, CTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: TextStyle(
              color: theme.secondaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            value,
            style: TextStyle(
              color: theme.primTextColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
