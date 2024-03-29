import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

typedef TextCallBack = Function(String);

class MessageInputPage extends StatefulWidget {
  final TextCallBack textCallBack;
  final String defaultText;

  MessageInputPage({Key key, @required this.textCallBack, this.defaultText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MessageInputPageState();
  }
}

class _MessageInputPageState extends State<MessageInputPage> {
  TextEditingController controller = TextEditingController();
  FocusNode _myFocusNode;

  @override
  void initState() {
    super.initState();
    if (widget.defaultText != null) controller.text = widget.defaultText;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Message",
            style: FontHelper.overlayHeader,
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: TextFormField(
            focusNode: _myFocusNode,
            maxLength: 100,
            controller: controller,
            maxLines: 5,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            onFieldSubmitted: (text) {
              widget.textCallBack(text);
              Navigator.of(context).pop();
            },
            style: FontHelper.medium(Colors.black, 12.0),
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorHelper.dabaoOffGrey70, width: 0.2)),
                contentPadding: EdgeInsets.all(10.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: ColorHelper.dabaoOffGrey70, width: 0.2)),
                hintText: 'e.g. Add Egg, Add Mashed Potato'),
          ),
        ),
      ),
      onWillPop: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        widget.textCallBack(controller.text);
        // Navigator.of(context).pop();
        return Future.value(true);
      },
    );
  }
}
