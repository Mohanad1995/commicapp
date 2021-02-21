import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:commicreaderappflutter/model/comic.dart';
import 'package:commicreaderappflutter/state/state_manager.dart';
import 'package:commicreaderappflutter/ui/screens/chapter_page.dart';
import 'package:commicreaderappflutter/ui/screens/read_Page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_riverpod/all.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
      name: 'commic_redaer_flutter',
      options: Platform.isMacOS || Platform.isIOS?
      FirebaseOptions(
          appId:'IOS KEY',
          apiKey: 'AIzaSyA86Ib5f_HZZan6Xg8FWJcGXB2lyo2VqzU',
          projectId: 'commicapp',
          messagingSenderId: '262555834681',
          databaseURL:'https://commicapp-default-rtdb.firebaseio.com',
      )
          : FirebaseOptions(
        appId:'1:262555834681:android:eb15d8197b992b6eda30e8',
        apiKey: 'AIzaSyA86Ib5f_HZZan6Xg8FWJcGXB2lyo2VqzU',
        projectId: 'commicapp',
        messagingSenderId: '262555834681',
        databaseURL:'https://commicapp-default-rtdb.firebaseio.com',
      )
  );
    runApp(ProviderScope(child: MyApp(app: app)));
}

class MyApp extends StatelessWidget {
  FirebaseApp app;
  MyApp({this.app});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/chapters':(context)=>ChapterPage(),
        '/read':(context)=>ReadPage()
      },
      title: 'Comic Reader',
      home: MyHomePage(title: 'Comic Reader',app: app,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title,this.app}) : super(key: key);
  final String title;
  final FirebaseApp app;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference _bannerRef,_comicRef;
  List<Comic> listComicFromFirebase = new List<Comic>();
  @override
  void initState() {
    // TODO: implement initState
    final FirebaseDatabase _database=FirebaseDatabase(app: widget.app);
    _bannerRef= _database.reference().child('Banners');
    _comicRef= _database.reference().child('Comic');
    super.initState();
 }
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context,watch,_){
      var searchEnable=watch(isSearch).state;
      return  Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title:searchEnable
            ?TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                hintText: 'Comic name or category',
                hintStyle: TextStyle(
                  color: Colors.white60
                )
              ),
              autofocus: false,
              style: DefaultTextStyle.of(context).style
                .copyWith(fontStyle: FontStyle.italic,
              fontSize: 18,
                color: Colors.white
              ),
            ),
              suggestionsCallback: (searchString) async{
              return await searchComic(searchString);
              },
              itemBuilder: (context,comic){
              return ListTile(
                leading: Image.network(comic.image),
                title: Text('${comic.name}'),
                subtitle: Text('${comic.category == null ?  '' :comic.category}'),
              );
              },
              onSuggestionSelected: (comic){
              context.read(comicSelected).state=comic;
              Navigator.pushNamed(context, '/chapters');
              }
                )
              : Text(widget.title),
          actions: [
            IconButton(icon: Icon(Icons.search),
              onPressed: ()=>context.read(isSearch).state=!context.read(isSearch).state,
            )
          ],
        ),
        body: FutureBuilder<List<String>>(
          future: getBanners(_bannerRef),
          builder: (context,snapshot){
            if(snapshot.hasData){
              return Column(
                children: [
                  CarouselSlider(items:snapshot.data.map((e) =>
                      Builder(
                        builder: (context){
                          return Image.network(e,fit: BoxFit.cover,);
                        },
                      )
                  ).toList(),
                    options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 1,
                        initialPage: 0,
                        height: MediaQuery.of(context).size.height/3
                    ),
                  ),
                  Row(
                    children: [
                      Expanded( flex: 4,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            color:Color(0xFFF44A3E),
                            child: Text('New COMIC',style: TextStyle
                              (
                                color: Colors.white
                            ),),
                          )
                      ),
                      Expanded( flex: 1,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            color:Colors.black87,
                            child: Text(''),
                          )
                      )
                    ],
                  ),
                  FutureBuilder
                    (
                      future: getComic(_comicRef),
                      builder: (context,snapshot){
                        if(snapshot.hasError)
                          return Center(child: Text('${snapshot.error}'),);
                        else if(snapshot.hasData){
                          listComicFromFirebase =new List<Comic>();
                          snapshot.data.forEach((item){
                            var comic=Comic.fromJson(json.decode(json.encode(item)));
                            listComicFromFirebase.add(comic);
                          });

                          return Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              padding: const EdgeInsets.all(4),
                              mainAxisSpacing: 1,
                              crossAxisSpacing: 1,
                              children: listComicFromFirebase.map((comic){
                                return GestureDetector(
                                  onTap: (){
                                    context.read(comicSelected).state=comic;
                                    Navigator.pushNamed(context, '/chapters');
                                  },
                                  child: Card(
                                      elevation: 12,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(comic.image,fit: BoxFit.cover,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                  color:Color(0xAA434343),
                                                  padding: EdgeInsets.all(8),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                        Text('${comic.name}',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,

                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                              ),
                                            ],
                                          ),

                                        ],
                                      )

                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                        return Center(child: CircularProgressIndicator(),) ;
                      }


                  )
                ],
              );
            }
            else if(snapshot.hasError)
              return Center(child: Text('${snapshot.error}'),);
            return  Center(child: CircularProgressIndicator(),);
          },
        ),
      );
    });
  }
  Future<List<dynamic>> getComic(DatabaseReference comicRef){
    return comicRef.once().then((snapshot) => snapshot.value);
  }
  Future<List<String>> getBanners(DatabaseReference bannerRef) {
    return bannerRef.once().then((snapshot) => snapshot.value.cast<String>().toList());
  }

  Future<List<Comic>>searchComic(String searchString) async{
    return listComicFromFirebase.where((comic) =>
        comic.name
        .toLowerCase()
        .contains(searchString.toLowerCase())
              ||
                       (comic.category !=null
                       && comic.category.toLowerCase()
                       .contains(searchString.toLowerCase()))
    ).toList();
  }
}

