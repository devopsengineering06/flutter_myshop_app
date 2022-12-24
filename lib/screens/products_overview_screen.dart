import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/products_grid.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatelessWidget {
  const ProductsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsContainer = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              // debugPrint('$selectedValue');
              if (selectedValue == FilterOptions.favorites) {
                productsContainer.showFavoritesOnly();
              } else {
                productsContainer.showAll();
              }
            },
            icon: const Icon(
              Icons.more_vert,
            ),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                  value: FilterOptions.favorites, child: Text('Only Favorite')),
              const PopupMenuItem(
                  value: FilterOptions.all, child: Text('Show All')),
            ],
          )
        ],
      ),
      body: const ProductsGrid(),
    );
  }
}
