import 'package:flutter/material.dart';
import 'package:galana_apk/PneumatiquePl/circle.dart';
import 'package:http/http.dart' as http;
import 'package:galana_apk/Services/delayed_animation.dart';
import 'package:galana_apk/main.dart';

class MyListViewPl extends StatefulWidget {
  @override
  _MyListViewStatePl createState() => _MyListViewStatePl();
}

String selectedCategoryPl = '315';
String selectedTypePl = 'Reparation';
int pricePl = 16000;
int tempPl = 25;
bool isLoadingPl = false;
bool isSuccessPl = false;

void sendDataToServer(BuildContext context) async {
  try {
    isLoadingPl = true;
    final url = Uri.parse(
        '$urlServer/PNEUMATIQUE/GALANA/150.php?ApiKey=FGSFDG1312SFG32&selectedCategory=$selectedCategoryPl&selectedType=$selectedTypePl&price=$pricePl&temp_pneumatique=$tempPl');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      isLoadingPl = false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez verifier la connexion au serveur!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
    }
  } catch (e) {}
}

class _MyListViewStatePl extends State<MyListViewPl> {
  void setPrice() {
    if (selectedCategoryPl == '315') {
      setState(() {
        selectedTypePl == 'Reparation' ? pricePl = 16000 : pricePl = 5000;
      });
    } else if (selectedCategoryPl == '385') {
      setState(() {
        selectedTypePl == 'Reparation' ? pricePl = 20000 : pricePl = 5000;
      });
    }

    selectedTypePl == 'Reparation' ? tempPl = 25 : tempPl = 15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(height: 20),
              ListTile(
                tileColor: Color(0xE4EFEFEF),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(40), // Ajout d'un BorderRadius
                ),
                title: Row(
                  children: [
                    Icon(Icons.control_point_duplicate),
                    SizedBox(width: 10),
                    Text('Catégorie: '),
                    Spacer(),
                    Text(selectedCategoryPl),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Catégories'),
                        content: Container(
                          height: 110,
                          width: double.maxFinite,
                          child: ListView(
                            children: [
                              for (var category in [
                                '315',
                                '385',
                              ])
                                ListTile(
                                  title: Text(
                                    category,
                                    style: TextStyle(
                                      color: selectedCategoryPl == category
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedCategoryPl = category;
                                      setPrice(); // Appel de la fonction pour définir le prix
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.type_specimen),
                    SizedBox(width: 10),
                    Text('Type'),
                    Spacer(),
                    Text(selectedTypePl),
                  ],
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Types'),
                        content: Container(
                          height: 120,
                          width: double.maxFinite,
                          child: ListView(
                            children: [
                              for (var type in [
                                'Reparation',
                                'Permutation',
                              ])
                                ListTile(
                                  title: Text(
                                    type,
                                    style: TextStyle(
                                      color: selectedTypePl == type
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedTypePl = type;
                                      setPrice(); // Appel de la fonction pour définir le prix
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          Center(
            child: DelayedAnimation(
              delay: 10,
              child: BlinkingCirclePl(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: Container(
            height: 80,
            color: Color(0xE4EFEFEF), // Couleur rouge
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: 'Temps : ',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Colors.black54),
                  children: <TextSpan>[
                    TextSpan(
                      text: '$tempPl min',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green),
                    ),
                    TextSpan(text: ' , '),
                    TextSpan(
                      text: 'Prix : ',
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.black54),
                    ),
                    TextSpan(
                      text: '$pricePl AR',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
