library pin_entry_text_field;

import 'package:flutter/material.dart';

class PinEntryTextField extends StatefulWidget {
  final int fields;
  final onSubmit;
  final fieldWidth;
  final fieldHeight;
  final fontSize;
  final isTextObscure;
  final showFieldAsBox;
  final midGap;
  final enableTextField;
 

  PinEntryTextField(
      {this.fields: 6,
      this.onSubmit,
      this.fieldWidth: 50.0,
      this.fieldHeight: 40.0,
      this.fontSize: 20.0,
      this.midGap: 10.0,
      this.isTextObscure: false,
      this.showFieldAsBox: false,
      this.enableTextField: true})
      : assert(fields > 0);

  @override
  State createState() {
    return PinEntryTextFieldState();
  }
}

class PinEntryTextFieldState extends State<PinEntryTextField> {
  List<String> _pin;
  List<FocusNode> _focusNodes;
  List<TextEditingController> _textControllers;

  @override
  void initState() {
    super.initState();
    
    _pin = List<String>(widget.fields);
    _focusNodes = List<FocusNode>(widget.fields);
    _textControllers = List<TextEditingController>(widget.fields);
  }

  @override
  void dispose() {
//    _focusNodes.forEach((FocusNode f) => f.dispose());
    _textControllers.forEach((TextEditingController t) => t.dispose());
    super.dispose();
  }

  void clearTextFields() {
    _textControllers.forEach(
        (TextEditingController tEditController) => tEditController.clear());
    _pin.clear();
  }

  Widget buildTextField(int i, BuildContext context) {
    _focusNodes[i] = FocusNode();
    _textControllers[i] = TextEditingController();

    _focusNodes[i].addListener(() {
      if (_focusNodes[i].hasFocus) {
        _textControllers[i].clear();
      }
    });

    return Container(
      decoration: BoxDecoration(color: Color(0xFFD0D0D0), borderRadius: BorderRadius.all(Radius.circular(5.0))),
      width: widget.fieldWidth,
      height: widget.fieldHeight,
      margin: EdgeInsets.only(right: 5.0),
      
      child: TextField(
        controller: _textControllers[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        enabled: widget.enableTextField,
        
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: widget.fontSize),

        focusNode: _focusNodes[i],
        obscureText: widget.isTextObscure,
        decoration: InputDecoration(
          border: InputBorder.none,
            counterText: "",
            ),
        onChanged: (String str) {
          _pin[i] = str;
          if (i + 1 != widget.fields) {
            FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
          } else {
            FocusScope.of(context).requestFocus(_focusNodes[0]);
            widget.onSubmit(_pin.join());
            clearTextFields();
            
          }
        },
        onSubmitted: (String str) {
          widget.onSubmit(_pin.join());
          clearTextFields();
        },
      ),
    );
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.fields, (int i) {
      if (i == 3) {
        return Container(
            child: Row(
          children: <Widget>[
            SizedBox(width: widget.midGap),
            buildTextField(i, context),
          ],
        ));
      } else {
        return buildTextField(i, context);
      }
    });

    //FocusScope.of(context).requestFocus(_focusNodes[0]);

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: textFields);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: generateTextFields(context),
    );
  }
}
