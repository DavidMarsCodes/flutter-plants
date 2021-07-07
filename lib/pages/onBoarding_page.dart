import 'package:leafety/controllers/slide_controler.dart';
import 'package:leafety/widgets/onboarding_message.dart';
import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(builder: (context, constraints) {
          return AnimatedContainer(
              decoration: new BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff1C181D),
                    Colors.black,
                  ],
                  stops: [0, 1],
                  begin: Alignment(-0.00, -5.00),
                  end: Alignment(0.00, 5.00),
                ),
              ),
              duration: Duration(milliseconds: 500),
              child: Center(
                child: Container(
                  padding: EdgeInsets.only(top: _size.height / 15),
                  constraints: BoxConstraints(maxWidth: 500, minWidth: 500),
                  width: _size.width,
                  height: _size.height,
                  child: OnBoardingSelector(
                    pages: [
                      OnboardingMessages(
                        left: 50,
                        width: 0.60,
                        height: 0.35,
                        title: "Medicinal",
                        message:
                            "Registra tu receta, encuentra tu Tratamiento.",
                        image: "assets/onBoard/medicine.svg",
                      ),
                      OnboardingMessages(
                        left: 60,
                        width: 0.50,
                        height: 0.35,
                        title: "Clubs",
                        message: "Suscríbete a clubes certificados.",
                        image: "assets/onBoard/subscriber.svg",
                      ),
                      OnboardingMessages(
                        left: 60,
                        width: 0.50,
                        height: 0.30,
                        title: "Cultivar",
                        message:
                            "Registra la evolución y el desarrollo de la medicina.",
                        image: "assets/onBoard/gardening.svg",
                      ),
                      OnboardingMessages(
                        left: 60,
                        width: 0.55,
                        height: 0.35,
                        title: "Seguridad",
                        message:
                            "Tus datos son confidenciales para tu seguridad",
                        image: "assets/onBoard/security.svg",
                      ),
                      OnboardingMessages(
                        left: 60,
                        width: 0.55,
                        height: 0.35,
                        title: "Ya estas listo!",
                        message: "",
                        image: "assets/onBoard/celebration.svg",
                      ),
                    ],
                  ),
                ),
              ));
        }));
  }
}
