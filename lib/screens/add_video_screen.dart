import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader_updated/blocs/concrete/database/sqflite/db_sqflite_youtube_video_bloc.dart';
import 'package:flutter_youtube_downloader_updated/blocs/concrete/database/sqflite/db_sqflite_category_bloc.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/category.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/utility.dart';
import 'package:flutter_youtube_downloader_updated/models/concrete/youtube_video.dart';
import 'package:http/http.dart' as http;

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({Key? key}) : super(key: key);

  @override
  _AddVideoScreenState createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  YoutubeVideo ytVideo = YoutubeVideo();
  Future<List<Category>>? _initialData;
  final form_key = GlobalKey<FormState>();

  bool isZoomed = false;

  bool isImageBringed = false;

  double photoHeight = 300.0;

  int? selected_category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: buildBody(),
      floatingActionButton: getSaveButton(),
    );
  }

  AppBar getAppBar() {
    if (isZoomed) {
      return AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.zoom_in,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  photoHeight += 10.0;
                });
              },
            ),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                photoHeight.toInt().toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.zoom_out,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  photoHeight -= 10.0;
                });
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.red,
                size: 40,
              ),
              onPressed: create_zoom,
            ),
          ],
        ),
      );
    }
    return AppBar(
      title: const Text("Video Ekleme Ekranı"),
    );
  }

  void create_zoom() {
    setState(() {
      if (isZoomed) {
        isZoomed = false;
        photoHeight = 300.0;
      } else {
        isZoomed = true;
      }
    });
  }

  buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Form(
        key: form_key,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: isImageBringed
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    getNameField(),
                    const SizedBox(
                      height: 30,
                    ),
                    getLinkField(),
                    const SizedBox(
                      height: 30,
                    ),
                    getCategoryBox(),
                    const SizedBox(
                      height: 30,
                    ),
                    getImageContainer(),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    getNameField(),
                    const SizedBox(
                      height: 30,
                    ),
                    getLinkField(),
                    const SizedBox(
                      height: 30,
                    ),
                    getCategoryBox(),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  TextFormField getLinkField() {
    return TextFormField(
      // ignore: missing_return
      validator: (text) {
        if (text?.length == 0) {
          return "Youtube Linki Girmek Zorunludur.";
        } else if (text?.startsWith("https://youtu.be/") == false) {
          return "Girilen Link Youtube'dan Değil.";
        }
      },
      onSaved: (text) {
        setState(() {
          ytVideo.youtubeVideoLink = text;
        });
      },
      onChanged: (text) {
        setState(() {
          ytVideo.youtubeVideoLink = text;
        });
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
      decoration: InputDecoration(
          filled: true,
          hintText: "Youtube Linki",
          fillColor: Colors.blue,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
          errorStyle: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 18,
          ),
          suffixIcon: IconButton(
            icon: Icon(isImageBringed ? Icons.refresh : Icons.image_search),
            padding: const EdgeInsets.only(right: 15),
            onPressed: getMemoryImage,
            color: Colors.black,
            iconSize: 35,
            tooltip:
                isImageBringed ? "Resmi Güncelle" : "Videonun Resmini Getir",
          )),
      cursorColor: Colors.red,
      keyboardType: TextInputType.url,
    );
  }

  TextFormField getNameField() {
    return TextFormField(
      style: const TextStyle(
        fontSize: 18,
      ),
      // ignore: missing_return,
      validator: (value) {
        if (value?.length == 0 || value == null || value.isEmpty) {
          return "Video Adını Girmek Zorunludur.";
        }
      },
      onSaved: (text) {
        setState(() {
          ytVideo.name = text;
        });
      },
      cursorColor: Colors.red,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        errorStyle: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 18,
        ),
        hintText: "Video Adı",
        fillColor: Colors.blue,
        filled: true,
      ),
    );
  }

  Widget getCategoryBox() {
    return FutureBuilder(
      initialData: _initialData,
      future: dbSqfliteCategoryBloc.getAll(),
      builder: (context, snapshot) {
        if (snapshot.hasData == false &&
            snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Expanded(
                  child: Text("Kategoriler Getiriliyor. Lütfen Bekleyiniz...")),
              Expanded(child: CircularProgressIndicator()),
            ],
          );
        } else {
          List<Category> categories = snapshot.data as List<Category>? ?? [];
          if (categories.length == 0) {
            return const Text("Herhangi Bir Kategori Buluanamadı.");
          }
          return DropdownButton<int>(
            value: selected_category,
            onChanged: (value) {
              setState(() {
                selected_category = value;
              });
            },
            dropdownColor: Colors.white10,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            items: categories.map(
              (e) {
                return DropdownMenuItem(
                  child: Text(e.categoryName ?? ""),
                  value: e.id,
                );
              },
            ).toList(),
            hint: const Text("Bir Kategori Seçiniz"),
          );
        }
      },
    );
  }

  void getMemoryImage() async {
    if (ytVideo.youtubeVideoLink == null) return;
    // //img.youtube.com/vi/${ytVideo.youtubeVideoLink.substring(ytVideo.youtubeVideoLink.length - 11)}/0.jpg
    var url = Uri.https("img.youtube.com",
        "/vi/${ytVideo.youtubeVideoLink?.substring(ytVideo.youtubeVideoLink!.length - 11)}/0.jpg");
    http.Response response = await http.get(url);
    setState(() {
      ytVideo.videoImage64 = Utility.convertToString(response.bodyBytes);
      isImageBringed = true;
    });
  }

  getImageContainer() {
    if (ytVideo.videoImage64 != null &&
        (ytVideo.videoImage64?.length ?? 0) > 0) {
      return Column(
        children: [
          Image.memory(
            Utility.convertToUint8List(ytVideo.videoImage64 ?? ""),
            width: double.maxFinite,
            height: photoHeight,
            gaplessPlayback: true,
          ),
          const SizedBox(height: 15),
          Center(
            child: RaisedButton(
              child: Text(isZoomed ? "Büyütme Modunu Kapat" : "Resmi Büyüt"),
              onPressed: create_zoom,
              color: Colors.blue,
            ),
          )
        ],
      );
    } else {
      return const Center(
        child: Text("Resim Yüklenemedi."),
      );
    }
  }

  getSaveButton() {
    return FloatingActionButton(
      onPressed: () {
        saveVideo();
      },
      child: const Icon(
        Icons.save,
        color: Colors.red,
      ),
    );
  }

  void saveVideo() async {
    if (form_key.currentState?.validate() ?? false) {
      form_key.currentState?.save();
      getMemoryImage();
      if (selected_category == null) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (ctx) => AlertDialog(
            content: const Text("Bir Kategori Seçmeniz Gerekmektedir"),
            actions: [
              RaisedButton(
                  child: const Text("Tamam"),
                  onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        );
      } else {
        setState(() {
          ytVideo.categoryId = selected_category;
        });
        dbSqfliteYoutubeVideoBloc.add(ytVideo).then((value) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (ctx) => AlertDialog(
              content: const Text("Video Ekleme İşlemi Başarılı."),
              actions: [
                RaisedButton(
                  child: const Text("Tamam"),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
      }
    }
  }
}
