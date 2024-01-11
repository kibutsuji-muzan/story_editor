import 'package:flutter/material.dart';
import 'package:flutter_edit_story/main.dart';
import 'package:provider/provider.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  void refresh(List list) {
    print('hello');
    setState(() {
      _locallist = list;
    });
  }

  List _locallist = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Provider.of<ListModel>(context, listen: false).addItem(1);

                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return ChangeNotifierProvider(
                      create: (context) => ListModel(),
                      child: Something(
                        notifyParent: refresh,
                      ),
                    );
                  },
                );
              },
              child: const Text('show modal'),
            ),
            const Center(
              child: Text('Your Count is'),
            ),
            Consumer<ListModel>(
              builder: (context, value, child) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: _locallist.length,
                  itemBuilder: (context, index) {
                    int item = _locallist[index];
                    return Row(
                      children: [
                        Text('$item'),
                      ],
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class Something extends StatefulWidget {
  Function notifyParent;
  Something({super.key, required this.notifyParent});

  @override
  State<Something> createState() => _SomethingState();
}

class _SomethingState extends State<Something> {
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Center(
          child: Consumer<ListModel>(
            builder: (context, value, child) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    Provider.of<ListModel>(context, listen: false)
                        .addItem(value.list.length + 1);
                    print(value.list);
                    widget.notifyParent(value.list);
                    // Navigator.of(context).pop(context);
                  });
                },
                child: Text('+'),
              );
            },
          ),
        );
      },
    );
  }
}
