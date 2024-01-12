import 'package:flutter/material.dart';
import 'package:flutter_edit_story/var.dart';

class ScrollModal extends StatefulWidget {
  Function notifyParent;
  ScrollModal({super.key, required this.notifyParent});

  @override
  State<StatefulWidget> createState() => _ScrollModalState();
}

class _ScrollModalState extends State<ScrollModal> {
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
                      SliverGrid.builder(
                        itemCount: allWidgetsList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              widget.notifyParent(allWidgetsList[index]);
                              Navigator.of(context).pop(context);
                            },
                            child: GridTile(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: allWidgetsList[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
