import 'package:flutter/material.dart';
import 'package:flutter_edit_story/var.dart';

class PollsWidget extends StatefulWidget {
  const PollsWidget({super.key});

  @override
  State<PollsWidget> createState() => _PollsWidgetState();
}

class _PollsWidgetState extends State<PollsWidget> {
  grp? _radiovalue;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0, -0.5),
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 12,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Text(
              'Some Text Here',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 43, 43, 43),
              ),
            ),
          ),
          Row(
            children: [
              Radio(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: grp.Yes,
                groupValue: _radiovalue,
                onChanged: (value) {
                  setState(() {
                    _radiovalue = value;
                  });
                },
              ),
              const Text(
                '10% ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: LinearProgressIndicator(
                    color: Colors.green,
                    minHeight: 12,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    value: 0.1,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Radio(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: grp.No,
                groupValue: _radiovalue,
                onChanged: (value) {
                  setState(() {
                    _radiovalue = value;
                  });
                },
              ),
              const Text(
                '10% ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: LinearProgressIndicator(
                    color: Colors.red,
                    minHeight: 12,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    value: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
