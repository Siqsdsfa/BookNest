import 'package:booknest/data/book_info.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:booknest/screens/item_description_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booknest/core/globals.dart' as globals;

class HomeScreen extends StatefulWidget {
  static const String name = 'home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController autorController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController publishDateController = TextEditingController();
  TextEditingController imageURLController = TextEditingController();

  CollectionReference collRef =
      FirebaseFirestore.instance.collection("books_info");

  bool _validURL = false;
  bool isCheckingImage = false;

  late bool _isLoading = true;
  late bool _fetchingRequired = true;
  List<BookInfo> _booksList = [];

  fetchRecords() async {
    var records =
        await FirebaseFirestore.instance.collection("books_info").get();
    await mapRecords(records);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  mapRecords(QuerySnapshot<Map<String, dynamic>> records) {
    var list = records.docs
        .map(
          (element) => BookInfo(
            title: element['title'],
            autor: element['autor'],
            description: element['description'],
            publishDate: element['publishDate'],
            imageURL: element['imageURL'],
            uploadedBy: element['uploadedBy'],
            docID: element['docID'],
          ),
        )
        .toList();
    if (mounted) {
      setState(() {
        _booksList = list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fetchingRequired) {
      fetchRecords();
      setState(() {
        _fetchingRequired = false;
      });
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("BookNest"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _fetchingRequired = true;
                _isLoading = true;
              });
            },
            icon: const Icon(Icons.refresh_rounded, size: 35),
          ),
        ],
      ),
      body: _toggleLoadingPage(),
      floatingActionButton: GestureDetector(
        onTap: () {
          clearTextControllers();
          createNewBook();
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.lightBlue,
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }

  Widget _toggleLoadingPage() {
    if (_isLoading == true) {
      debugPrint('Is Loading');
      return _notLoadedPage();
    } else {
      debugPrint('Has already loaded');
      return _loadedPage();
    }
  }

  Widget _notLoadedPage() {
    return const Padding(
      padding: EdgeInsets.all(15),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _loadedPage() {
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome ${globals.email}'),
              const SizedBox(height: 40),
              ListView.builder(
                itemCount: _booksList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final tile = _booksList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Card(
                      elevation: 4,
                      shadowColor: Colors.black12,
                      child: ListTile(
                        leading: IconButton(
                          onPressed: () {
                            _goToBookDetails(context, tile);
                          },
                          icon: const Icon(Icons.open_in_new),
                        ),
                        title: Column(
                          children: [
                            Text(
                              tile.title,
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            tryCreateImage(tile.imageURL),
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            _isLoading = true;
                            await deleteBook(_booksList[index].docID);
                            if (mounted) {
                              setState(() {
                                _fetchingRequired = true;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove_rounded),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _goToBookDetails(BuildContext context, BookInfo tile) {
    context.pushNamed(
      DescriptionScreen.name,
      extra: BookInfo(
        title: tile.title,
        autor: tile.autor,
        description: tile.description,
        publishDate: tile.publishDate,
        imageURL: tile.imageURL,
        uploadedBy: tile.uploadedBy,
        docID: tile.docID,
      ),
    );
  }

  Future createNewBook() => showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                insetPadding: const EdgeInsets.only(top: 60, bottom: 60),
                scrollable: true,
                title: const Text("Book"),
                content: Column(
                  children: [
                    createNewBookTextField('Title',
                        const Icon(Icons.text_fields_rounded), titleController),
                    const SizedBox(height: 5),
                    createNewBookTextField(
                        'Autor', const Icon(Icons.person), autorController),
                    const SizedBox(height: 5),
                    createNewBookTextField(
                        'Description',
                        const Icon(Icons.text_fields_rounded),
                        descriptionController),
                    const SizedBox(height: 5),
                    createNewBookTextField(
                        'Date of publication',
                        const Icon(Icons.date_range_outlined),
                        publishDateController),
                    const SizedBox(height: 5),
                    createNewBookTextField('Image url', const Icon(Icons.link),
                        imageURLController),
                    const SizedBox(height: 5),
                    TextButton(
                      onPressed: () {
                        setState(() => isCheckingImage = true);
                      },
                      child: const Text("Check Image"),
                    ),
                    isCheckingImage
                        ? tryCreateImage(imageURLController.text)
                        : const SizedBox(),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      handleCreateNewBook(context);
                    },
                    child: const Text("Submit"),
                  ),
                ],
              );
            },
          );
        },
      );

  Widget tryCreateImage(String url) {
    return Image.network(
      url,
      height: 200,
      width: double.maxFinite,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.image_not_supported, size: 120);
      },
    );
  }

  Future<void> handleCreateNewBook(BuildContext context) async {
    if (titleController.text.isEmpty ||
        autorController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        publishDateController.text.isEmpty ||
        imageURLController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empty Fields')),
      );
    } else {
      _validURL =
          Uri.tryParse(imageURLController.text)?.hasAbsolutePath ?? false;
      if (_validURL == true) {
        Navigator.of(context).pop();
        _isLoading = true;
        await uploadBook();
        clearTextControllers();
        if (mounted) {
          setState(() {
            _fetchingRequired = true;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid URL')),
        );
      }
    }
  }

  Future<void> uploadBook() async {
    var pushRef = await collRef.add({
      'title': titleController.text,
      'autor': autorController.text,
      'description': descriptionController.text,
      'publishDate': publishDateController.text,
      'imageURL': imageURLController.text,
      'uploadedBy': globals.userID,
      'docID': '',
    }).then((DocumentReference doc) {
      collRef.doc(doc.id).update({
        'docID': doc.id.toString(),
      });
    });

    debugPrint(pushRef.toString());
  }

  Future<void> deleteBook(String docID) async {
    await collRef.doc(docID).delete();
  }

  void clearTextControllers() {
    titleController.clear();
    autorController.clear();
    descriptionController.clear();
    publishDateController.clear();
    imageURLController.clear();
    isCheckingImage = false;
  }
}

Widget createNewBookTextField(
    String title, Icon icon, TextEditingController controller) {
  return TextField(
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      labelText: title,
      prefixIcon: icon,
      hintText: title,
    ),
    controller: controller,
  );
}
