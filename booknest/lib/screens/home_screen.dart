import 'package:booknest/core/navbar.dart';
import 'package:booknest/core/utils.dart';
import 'package:booknest/data/book_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  static const String name = 'home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController writerController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController publishDateController = TextEditingController();
  TextEditingController imageURLController = TextEditingController();

  CollectionReference collRef =
      FirebaseFirestore.instance.collection("books_info");
  final _currentUser = FirebaseAuth.instance.currentUser!;

  bool _validURL = false;
  bool isCheckingImage = false;

  late bool _isLoading = true;
  late bool _fetchingRequired = true;
  List<BookInfo> _booksList = [];

  void fetchRecords() async {
    QuerySnapshot<Map<String, dynamic>> records;
    try {
      records = await FirebaseFirestore.instance.collection("books_info").get();
      mapRecords(records);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void mapRecords(QuerySnapshot<Map<String, dynamic>> records) {
    var list = records.docs
        .map(
          (element) => BookInfo(
            title: element['title'],
            writer: element['writer'],
            description: element['description'],
            publishDate: element['publishDate'],
            imageURL: element['imageURL'],
            uploadedBy: element['uploadedBy'],
            docID: element['docID'],
            likes: element['likes'],
            dislikes: element['dislikes'],
            usersLikes: element['usersLikes'],
            usersDislikes: element['usersDislikes'],
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => context.pushNamed(HomeScreen.name),
      child: Scaffold(
        drawer: const NavBar(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          title: const Text("BookNest"),
          centerTitle: true,
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
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ListView.separated(
        itemBuilder: (context, index) => const PublicationCardSkeleton(),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemCount: 10,
      ),
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
              Text('Welcome ${_currentUser.email}!'),
              const SizedBox(height: 40),
              ListView.builder(
                itemCount: _booksList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final tile = _booksList[index];
                  return Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(),
                            ),
                            onPressed: () {
                              goToBookDetails(context, tile, HomeScreen.name);
                            },
                            child: Row(
                              children: [
                                tryCreateImage(tile.imageURL),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        tile.title,
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(tile.writer,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Divider(color: Color.fromARGB(135, 162, 162, 162)),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
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
                title: const Text("Upload Book"),
                content: Column(
                  children: [
                    bookTextField('Title',
                        const Icon(Icons.text_fields_rounded), titleController),
                    const SizedBox(height: 5),
                    bookTextField(
                        'Writer', const Icon(Icons.person), writerController),
                    const SizedBox(height: 5),
                    bookTextField(
                        'Description',
                        const Icon(Icons.text_fields_rounded),
                        descriptionController),
                    const SizedBox(height: 5),
                    bookTextField(
                        'Date of publication',
                        const Icon(Icons.date_range_outlined),
                        publishDateController),
                    const SizedBox(height: 5),
                    bookTextField('Image url', const Icon(Icons.link),
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

  Future<void> handleCreateNewBook(BuildContext context) async {
    if (titleController.text.isEmpty ||
        writerController.text.isEmpty ||
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
      'writer': writerController.text,
      'description': descriptionController.text,
      'publishDate': publishDateController.text,
      'imageURL': imageURLController.text,
      'uploadedBy': _currentUser.uid,
      'docID': '',
      'likes': 0,
      'dislikes': 0,
      'usersLikes': [],
      'usersDislikes': [],
    }).then((DocumentReference doc) {
      collRef.doc(doc.id).update({
        'docID': doc.id.toString(),
      });
    });

    debugPrint(pushRef.toString());
  }

  void clearTextControllers() {
    titleController.clear();
    writerController.clear();
    descriptionController.clear();
    publishDateController.clear();
    imageURLController.clear();
    isCheckingImage = false;
  }
}
