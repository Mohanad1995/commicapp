import 'package:commicreaderappflutter/state/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChapterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context,watch,_){
      var comic=watch(comicSelected).state;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Center(child: Text('${comic.name.toUpperCase()}',style: TextStyle(
            color: Colors.white
          ),)),
        ),
        body:comic.chapters !=null && comic.chapters.length > 0 ?
        Padding(
         padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: comic.chapters.length,
              itemBuilder: (context,index){
              return GestureDetector(
                onTap: (){
                  context.read(chapterSelected).state=comic.chapters[index];
                  Navigator.pushNamed(context, '/read');
                },
                child: Column(
                  children: [
                    ListTile(title: Text('${comic.chapters[index].name}'),),
                 Divider(thickness: 2,),
                  ],
                ),
              );
              }
          ),
        ):Center(child: Text('we are translating this comic'),)
      );
    },);
  }
}
