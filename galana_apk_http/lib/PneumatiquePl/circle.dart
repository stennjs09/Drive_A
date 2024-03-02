import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:galana_apk/PneumatiquePl/dropdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:galana_apk/main.dart';

class BlinkingCirclePl extends StatefulWidget {
  @override
  _BlinkingCircleStatePl createState() => _BlinkingCircleStatePl();
}

String dataPl = '';

class _BlinkingCircleStatePl extends State<BlinkingCirclePl>
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
          content: Text('Activer l\'appareil maintenant?'),
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
    if(iSPneumatiquePl == true) {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult != ConnectivityResult.none) {
        var url =
        Uri.parse('$urlServer/PNEUMATIQUE/GALANA/148.php?ApiKey=SDGDKWXDHT45D4D&temp_pneumatique');
        var response = await http.get(url);

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          List<String> values = jsonData.split(',');
          if (values.length == 2) {
            dataPl = values[0];
            String value2 = values[1];
            setState(() {
              _controller.forward();
            });

            if (dataPl == '0') {
              _animation = Tween<double>(begin: 10.0, end: 10.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOut,
                ),
              );
              setState(() {
                dataPl = 'PL libre';
                isLoadingPl = false;
              });
            } else {
              _animation = Tween<double>(begin: 10.0, end: 0.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOut,
                ),
              );
              setState(() {
                dataPl = values[0] + ' min';
                isLoadingPl = false;
              });
            }
          } else {
            setState(() {
              isLoadingPl = true;
            });
            await Future.delayed(Duration(seconds: 5));
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text('Activation de l\'appareil de pneumatique en cours...'),
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
            isLoadingPl = true;
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
          isLoadingPl = true;
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
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            Color damnColor = Colors.red; // Default color

            if (dataPl == 'PL libre' || dataPl == '') {
              damnColor = Colors.blue; // Change color to blue if data is 'Pl libre'
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
                child: isLoadingPl
                    ? SpinKitThreeBounce(
                        color: Colors.blue,
                        size: 40.0,
                      )
                    : Text(
                        '$dataPl',
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
        if (!isLoadingPl && dataPl != 'PL libre')
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
                        'L\'appereil est en cours ! \nNous vous prions de bien vouloir patienter un moment...',
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
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.send, color: Colors.white),
              ),
            ),
          ),
        if (!isLoadingPl && dataPl == 'PL libre')
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
                child: Icon(Icons.send, color: Colors.blue),
              ),
            ),
          ),
      ],
    );
  }
}
