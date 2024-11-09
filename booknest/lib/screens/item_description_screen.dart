import 'package:booknest/data/book_info.dart';
import 'package:booknest/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DescriptionScreen extends StatefulWidget {
  static const String name = 'description';
  final BookInfo? localBookInfo;
  const DescriptionScreen({super.key, this.localBookInfo});

  @override
  State<DescriptionScreen> createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController autorController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController publishDateController = TextEditingController();
  TextEditingController imageURLController = TextEditingController();
  late bool _editMode = false;
  late bool _isCheckingImage = false;
  late BookInfo? bookInfo = widget.localBookInfo;

  CollectionReference collRef =
      FirebaseFirestore.instance.collection("books_info");

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => context.pushNamed(HomeScreen.name),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          title: const Text('Book Description'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                deleteBook(bookInfo!.docID);
              },
              icon: const Icon(Icons.delete_forever_rounded, size: 35),
            ),
          ],
        ),
        floatingActionButton: GestureDetector(
          onTap: () {
            if (_editMode) {
              handleUploadBook();
              setState(() {
                _editMode = false;
              });
            } else {
              setTextControllers();
              setState(() {
                _editMode = true;
              });
            }
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.lightBlue,
            ),
            child: Icon(
              _editMode ? Icons.check : Icons.edit,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: _toggleEditMode(),
        ),
      ),
    );
  }

  Widget _toggleEditMode() {
    if (_editMode) {
      return _editablePage();
    } else {
      return _uneditablePage();
    }
  }

  Widget _editablePage() {
    return ListView(
      children: [
        const SizedBox(height: 15),
        createNewBookTextField(
            'Title', const Icon(Icons.text_fields_rounded), titleController),
        const SizedBox(height: 15),
        createNewBookTextField(
            'Autor', const Icon(Icons.person), autorController),
        const SizedBox(height: 15),
        createNewBookTextField('Description',
            const Icon(Icons.text_fields_rounded), descriptionController),
        const SizedBox(height: 15),
        createNewBookTextField('Date of publication',
            const Icon(Icons.date_range_outlined), publishDateController),
        const SizedBox(height: 15),
        createNewBookTextField(
            'Image url', const Icon(Icons.link), imageURLController),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () {
            setState(() => _isCheckingImage = true);
          },
          child: const Text("Check Image"),
        ),
        _isCheckingImage
            ? tryCreateImage(imageURLController.text)
            : const SizedBox(),
      ],
    );
  }

  Widget _uneditablePage() {
    return ListView(
      children: [
        Text(
          '${bookInfo?.title} (${bookInfo?.publishDate})',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text('${bookInfo?.autor}', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        tryCreateImage('${bookInfo?.imageURL}'),
        likesBar(),
        const SizedBox(height: 10),
        Text('${bookInfo?.description}', style: const TextStyle(fontSize: 15)),
        Text('Created by user: ${bookInfo?.uploadedBy}',
            style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Future<void> deleteBook(String docID) async {
    await collRef.doc(docID).delete();
    if (mounted) {
      context.pushNamed(HomeScreen.name);
    }
  }

  Future<void> handleUploadBook() async {
    if (mounted) {
      setState(() {
        bookInfo?.title = titleController.text;
        bookInfo?.autor = autorController.text;
        bookInfo?.description = descriptionController.text;
        bookInfo?.publishDate = publishDateController.text;
        bookInfo?.imageURL = imageURLController.text;
      });
    }
    await collRef.doc(bookInfo?.docID).update({
      'title': titleController.text,
      'autor': autorController.text,
      'description': descriptionController.text,
      'publishDate': publishDateController.text,
      'imageURL': imageURLController.text,
    });
  }

  void setTextControllers() {
    titleController.text = bookInfo!.title;
    autorController.text = bookInfo!.autor;
    descriptionController.text = bookInfo!.description;
    publishDateController.text = bookInfo!.publishDate;
    imageURLController.text = bookInfo!.imageURL;
    _isCheckingImage = false;
  }

  Widget tryCreateImage(String url) {
    return Image.network(
      url,
      height: 400,
      width: double.maxFinite,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.image_not_supported, size: 200);
      },
    );
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

  Widget likesBar() {
    return SizedBox(
      height: 40,
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              int intLikes = bookInfo!.likes.toInt();
              intLikes = intLikes + 1;
              setState(() {
                bookInfo?.likes = intLikes;
              });
              await collRef.doc(bookInfo?.docID).update({
                'likes': intLikes.toString(),
              });
            },
            child: Row(
              children: [
                const Icon(Icons.thumb_up, color: Colors.black),
                const SizedBox(width: 10),
                Text(bookInfo!.likes.toString(),
                    style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
          const VerticalDivider(),
          ElevatedButton(
            onPressed: () async {
              int intDislikes = bookInfo!.dislikes.toInt();
              intDislikes = intDislikes + 1;
              setState(() {
                bookInfo?.dislikes = intDislikes;
              });
              await collRef.doc(bookInfo?.docID).update({
                'dislikes': intDislikes.toString(),
              });
            },
            child: Row(
              children: [
                const Icon(Icons.thumb_down, color: Colors.black),
                const SizedBox(width: 10),
                Text(bookInfo!.dislikes.toString(),
                    style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
