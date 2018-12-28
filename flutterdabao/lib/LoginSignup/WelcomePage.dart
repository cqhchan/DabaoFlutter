import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

class WelcomePage extends StatefulWidget {
  final int numberOfSteps;

  final VoidCallback nextPage;

  const WelcomePage({Key key, @required this.numberOfSteps, @required this.nextPage}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WelcomePageState();
  }
}

class WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Swiper(
              pagination: new SwiperPagination(),
              itemCount: 3,
              itemBuilder: (context, page) {
                return Image.asset('assets/images/welcome_image_1.png',
                    fit: BoxFit.cover);
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(bottom: 20),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Text("Welcome", style: FontHelper.medium(Colors.black, 35.0)),
                  Container(
                      padding: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
                      child: Text(
                        "We're glad to have you join our Dabao Community! \n Lets get you started in ${widget.numberOfSteps} steps",
                        style: FontHelper.medium(Colors.black, 14.0),
                        textAlign: TextAlign.center,
                      )),

                       RaisedButton(
                    child: Container(
                      height: 40,
                      width: 80,
                      child: Center(
                        child: Text(
                          'Next',
                          style: FontHelper.overlayHeader,
                        ),
                      ),
                    ),
                    color: Color(0xFFF5A510),
                    elevation: 2.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    onPressed: widget.nextPage)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
