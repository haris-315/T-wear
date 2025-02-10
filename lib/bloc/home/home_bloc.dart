import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_wear/models/category.dart';
import 'package:t_wear/models/product_model.dart';
import 'package:t_wear/repos/products_repo.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  ProductsRepo repo = ProductsRepo();

  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>((event, emit) async {
      if (!event.isCarting) {
        emit(HomeLoading());
        var data = await repo.getProducts();
        data.fold((fail) => emit(HomeError(message: fail.message)),
            (data) => emit(HomeSuccess(products: data)));
      } else {
        event.productsMap!['cart'] = [
          ...?event.productsMap?['cart'],
          event.product as Product
        ];
        emit(HomeSuccess(
            isCarted: true,
            products: event.productsMap as Map<dynamic, List<Product>>));
      }
    });
    on<GetByCategory>((event, emit) async {
      emit(HomeLoading(byCategory: true));
      var data = await repo.getProductsByCategory(event.category);
      data.fold(
          (fail) => emit(HomeError(message: fail.message)),
          (data) => emit(HomeSuccess(
              products: data,
              isCategorizing: event.category.id == 8 ? false : true)));
    });
    on<GetBySearch>((event, emit) async {
      emit(HomeLoading(byCategory: true));
      var data = await repo.getProductsBySearch(event.query);
      data.fold(
          (fail) => emit(HomeError(message: fail.message)),
          (data) => emit(HomeSuccess(
              products: data,
              isCategorizing:
                  event.query == "" || event.query.isEmpty ? false : true)));
    });

    on<RemoveFromCart>((event, emit) {
      HomeSuccess oldState = state as HomeSuccess;
      Map<dynamic, List<Product>> products = oldState.products;
      if (products['cart'] != null || products['cart'] != []) {
        products['cart']?.remove(event.product);
      }
      emit(HomeSuccess(
          products: products,
          isCarted: products['cart'] != null ? true : false));
    });
  }
}
