import 'package:commicreaderappflutter/model/chapter.dart';
import 'package:commicreaderappflutter/model/comic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final comicSelected = StateProvider((ref) =>Comic());
final chapterSelected =StateProvider((ref)=>Chapters());
final isSearch = StateProvider((ref)=>false);