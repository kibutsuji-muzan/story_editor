import 'package:flutter/material.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:flutter_edit_story/widgets/ProcutWidget.dart';
import 'package:provider/provider.dart';

class ProductModal extends StatefulWidget {
  Function notifyParent;
  ProductModal({super.key, required this.notifyParent});

  @override
  State<StatefulWidget> createState() => _ProductModalState();
}

class _ProductModalState extends State<ProductModal> {
  late List<Product> _products = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch_data();
  }

  void refresh() {
    setState(() {});
  }

  Future<void> fetch_data() async {
    products.forEach(
      (element) => setState(
        () => _products.add(
          Product(
              id: element['id'],
              name: element['name'],
              price: element['price'],
              image: element['image']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.9,
      minChildSize: 0.1,
      initialChildSize: 0.2,
      builder: (context, scrollController) {
        return Container(
          margin: const EdgeInsets.only(top: 50),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadiusDirectional.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Column(
              children: [
                Container(
                  height: 5,
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverList.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return ProductWidget(
                            product: _products[index],
                            ref: refresh,
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
