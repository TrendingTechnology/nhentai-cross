import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nhentai/basic/channels/nhentai.dart';
import 'package:nhentai/basic/entities/entities.dart';
import 'package:nhentai/screens/comic_reader_screen.dart';
import 'package:nhentai/screens/components/actions.dart';
import 'package:nhentai/screens/components/content_builder.dart';
import 'package:nhentai/screens/components/images.dart';

class ComicInfoScreen extends StatefulWidget {
  final int comicId;
  final String comicTitle;

  const ComicInfoScreen(this.comicId, this.comicTitle, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicInfoScreenState();
}

class _ComicInfoScreenState extends State<ComicInfoScreen> {
  late Future<ComicInfo> _future;

  Future<ComicInfo> _loadComic() {
    return nHentai.comicInfo(widget.comicId);
  }

  @override
  void initState() {
    _future = _loadComic();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comicTitle),
        actions: [...alwaysInActions(context)],
      ),
      floatingActionButton: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<ComicInfo> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.only(right: 30, bottom: 30),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (BuildContext context) {
                    return ComicReaderScreen(snapshot.requireData);
                  }));
                },
                child: const Icon(Icons.menu_book),
              ),
            );
          }
          return Container();
        },
      ),
      body: ContentBuilder(
        future: _future,
        onRefresh: () async {
          setState(() {
            _future = _loadComic();
          });
        },
        successBuilder:
            (BuildContext context, AsyncSnapshot<ComicInfo> snapshot) {
          var item = snapshot.data!;
          var mq = MediaQuery.of(context);
          var imageWidth =
              (mq.size.width < mq.size.height) ? mq.size.width : mq.size.height;
          imageWidth = imageWidth / 2;
          var subColor = Color.alphaBlend(
            Colors.grey.shade500.withAlpha(80),
            (Theme.of(context).textTheme.bodyText1?.color ?? Colors.black),
          );
          return ListView(
            children: [
              Container(height: 20),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: imageWidth,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    child: ScaleNHentaiImage(
                      url: coverImageUrl(item.mediaId),
                      originSize: Size(
                        item.images.cover.w.toDouble(),
                        item.images.cover.h.toDouble(),
                      ),
                    ),
                  ),
                ),
              ),
              Container(height: 20),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  item.title.english,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(height: 10),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  item.title.japanese,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(height: 10),
              Align(
                alignment: Alignment.center,
                child: Text.rich(TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    color: subColor,
                  ),
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: subColor,
                      ),
                    ),
                    const TextSpan(text: " "),
                    TextSpan(
                      text: formatDate(
                        DateTime.fromMillisecondsSinceEpoch(
                          item.uploadDate * 1000,
                        ),
                        [yyyy, "-", mm, "-", dd, " ", HH, ":", nn, ":", ss],
                      ),
                    ),
                    const TextSpan(text: "  "),
                  ],
                )),
              ),
              Container(height: 10),
              Align(
                alignment: Alignment.center,
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: subColor,
                    ),
                    children: [
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.image,
                              size: 14,
                              color: subColor,
                            ),
                          ),
                          const TextSpan(text: " "),
                          TextSpan(text: "${item.images.pages.length}"),
                        ],
                      ),
                      const TextSpan(text: "    "),
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.favorite_outline,
                              size: 15,
                              color: subColor,
                            ),
                          ),
                          const TextSpan(text: " "),
                          TextSpan(text: "${item.numFavorites}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: 10),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Wrap(
                  children: (item.tags.map(_buildTag)).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTag(ComicInfoTag e) {
    return Card(
      child: Text.rich(TextSpan(
        style: const TextStyle(fontSize: 10),
        children: [
          WidgetSpan(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              child: Container(
                color: Colors.grey.withAlpha(20),
                padding:
                const EdgeInsets.only(top: 2, bottom: 2, left: 4, right: 4),
                child: Text(e.name),
              ),
            ),
          ),
          WidgetSpan(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              child: Container(
                padding:
                    const EdgeInsets.only(top: 2, bottom: 2, left: 4, right: 4),
                child: Text("${e.count}"),
              ),
            ),
          ),
        ],
      )),
    );
  }
}