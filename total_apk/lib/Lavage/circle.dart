import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:total_apk/Lavage/dropdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:total_apk/main.dart';

class BlinkingCircle extends StatefulWidget {
  @override
  _BlinkingCircleState createState() => _BlinkingCircleState();
}

String data = '';

class _BlinkingCircleState extends State<BlinkingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    Timer.periodic(Duration(seconds: 5), (Timer t) => fetchData());

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
  }

  Future<void> confirmSendData() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Activer l\'appareil de lavage maintenant?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                sendDataToServer(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future fetchData() async {
    if(iSLavage == true) {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult != ConnectivityResult.none) {
        var url =
        Uri.parse('$urlServer/API1/148.php?ApiKey=PDS461332324SHKJD&temp_esp');
        var response = await http.get(url);
        
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          List<String> values = jsonData.split(',');
          if (values.length == 2) {
            data = values[0];
            String value2 = values[1];
            setState(() {
              _controller.forward();
            });

            if (data == '0') {
              _animation = Tween<double>(begin: 10.0, end: 10.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOut,
                ),
              );
              setState(() {
                data = 'Lavage libre';
                isLoading = false;
              });
            } else {
              _animation = Tween<double>(begin: 10.0, end: 0.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOut,
                ),
              );
              setState(() {
                data = values[0] + ' min';
                isLoading = false;
              });
            }
          } else {
            setState(() {
              isLoading = true;
            });
            await Future.delayed(Duration(seconds: 5));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text('Activation de l\'appareil de lavage en cours...'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 200),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {},
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors du connexion au serveur !'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 200),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
          setState(() {
            isLoading = true;
          });
        }
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aucune connexion Internet'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 200),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
        setState(() {
          isLoading = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isSuccess) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Nettoyage en cours...',
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
              content: Text(
                'Nettoyage interieur d\'un $selectedCategory en cours... !',
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
              backgroundColor: Colors.white,
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    isSuccess = false;
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            Color damnColor = Colors.blue; // Default color

            if (data == 'Lavage libre' || data == '') {
              damnColor = Colors
                  .red; // Change color to red if data is 'Lavage libre'
            }
            return Container(
              margin: EdgeInsets.only(top: 80),
              width: 230.0,
              height: 230.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: damnColor,
                  width: _animation.value,
                ),
              ),
              child: Center(
                child: isLoading
                    ? SpinKitThreeBounce(
                        color: Colors.red,
                        size: 40.0,
                      )
                    : Text(
                        '$data',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: damnColor,
                        ),
                      ),
              ),
            );
          },
        ),
        if (!isLoading && data != 'Lavage libre')
          Positioned(
            bottom: 20.0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Attention !',
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      content: Text(
                        'Un lavage est en cours ! \nNous vous prions de bien vouloir patienter un moment...',
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      actions: <Widget>[],
                    );
                  },
                );
              },
              child: FloatingActionButton(
                onPressed: null,
                backgroundColor: Colors.blue,
                child: Icon(Icons.send, color: Colors.white),
              ),
            ),
          ),
        if (!isLoading && data == 'Lavage libre')
          Positioned(
            bottom: 20.0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                confirmSendData();
              },
              child: FloatingActionButton(
                onPressed: null,
                backgroundColor: Colors.white,
                child: Icon(Icons.send, color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }
}
