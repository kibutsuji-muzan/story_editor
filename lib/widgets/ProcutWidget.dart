import 'package:flutter/material.dart';
import 'package:flutter_edit_story/var.dart';
import 'package:provider/provider.dart';

class ProductWidget extends StatefulWidget {
  Product product;
  Function ref;
  ProductWidget({
    super.key,
    required this.product,
    required this.ref,
  });

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    print(Provider.of<SelectedProduct>(context, listen: false).productId);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward().then(
          (value) => _controller.reverse(),
        );
    context.read<SelectedProduct>().setProductId(widget.product.id);
    widget.ref();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(),
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Stack(
          children: [
            Card(
              elevation: 20,
              surfaceTintColor: Colors.white,
              color: Colors.white,
              margin: const EdgeInsets.all(16.0),
              child: Container(
                height: 340,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.product.image, // Replace with your image URL
                        height: 150.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8.0),
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          widget.product.desc,
                          // 'Product Description Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                          style: const TextStyle(fontSize: 16.0),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () {},
                          child: SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Buy: \$ ${widget.product.price.toDouble()}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            (context.watch<SelectedProduct>().productId == widget.product.id)
                ? Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        widget.ref();
                        context.read<SelectedProduct>().setProductId(0);
                      },
                      child: Icon(
                        Icons.cancel,
                        size: 26,
                        color: Colors.red[600],
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
