import 'package:booknest/core/utils.dart';
import 'package:booknest/data/book_info.dart';
import 'package:booknest/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DescriptionScreen extends StatefulWidget {
  static const String name = 'description';
  final DetailsScreenData previousAndDetailsInfo;
  const DescriptionScreen({super.key, required this.previousAndDetailsInfo});

  @override
  State<DescriptionScreen> createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController writerController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController publishDateController = TextEditingController();
  TextEditingController imageURLController = TextEditingController();

  final _currentUser = FirebaseAuth.instance.currentUser!;
  bool _editMode = false;
  bool _isCheckingImage = false;
  bool _checkUserFeedback = true;
  bool _toggleLike = false;
  bool _toggleDislike = false;
  late String prevScreen = widget.previousAndDetailsInfo.previousScreen;
  late BookInfo bookInfo = widget.previousAndDetailsInfo.bookInfo;

  CollectionReference collRef =
      FirebaseFirestore.instance.collection("books_info");

  @override
  Widget build(BuildContext context) {
    if (_checkUserFeedback) {
      setState(() {
        if (bookInfo.usersLikes.contains(_currentUser.uid)) {
          _toggleLike = true;
          _toggleDislike = false;
        } else if (bookInfo.usersDislikes.contains(_currentUser.uid)) {
          _toggleLike = false;
          _toggleDislike = true;
        }
        _checkUserFeedback = false;
      });
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => context.pushNamed(prevScreen),
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
                deleteBook(bookInfo.docID);
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
        bookTextField(
            'Title', const Icon(Icons.text_fields_rounded), titleController),
        const SizedBox(height: 15),
        bookTextField('Writer', const Icon(Icons.person), writerController),
        const SizedBox(height: 15),
        bookTextField('Description', const Icon(Icons.text_fields_rounded),
            descriptionController),
        const SizedBox(height: 15),
        bookTextField('Date of publication',
            const Icon(Icons.date_range_outlined), publishDateController),
        const SizedBox(height: 15),
        bookTextField('Image url', const Icon(Icons.link), imageURLController),
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
          '${bookInfo.title} (${bookInfo.publishDate})',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(bookInfo.writer, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        tryCreateImage(bookInfo.imageURL),
        likesBar(),
        const SizedBox(height: 10),
        Text(bookInfo.description, style: const TextStyle(fontSize: 15)),
        Text('Created by user: ${bookInfo.uploadedBy}',
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
        bookInfo.title = titleController.text;
        bookInfo.writer = writerController.text;
        bookInfo.description = descriptionController.text;
        bookInfo.publishDate = publishDateController.text;
        bookInfo.imageURL = imageURLController.text;
      });
    }
    await collRef.doc(bookInfo.docID).update({
      'title': titleController.text,
      'writer': writerController.text,
      'description': descriptionController.text,
      'publishDate': publishDateController.text,
      'imageURL': imageURLController.text,
    });
  }

  void setTextControllers() {
    titleController.text = bookInfo.title;
    writerController.text = bookInfo.writer;
    descriptionController.text = bookInfo.description;
    publishDateController.text = bookInfo.publishDate;
    imageURLController.text = bookInfo.imageURL;
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

  Widget likesBar() {
    return SizedBox(
      height: 40,
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _toggleLike ? Colors.blue : Colors.grey),
            onPressed: () async {
              handleLike();
            },
            child: Row(
              children: [
                Icon(Icons.thumb_up,
                    color: _toggleLike ? Colors.white : Colors.black),
                const SizedBox(width: 10),
                Text(bookInfo.likes.toString(),
                    style: TextStyle(
                        color: _toggleLike ? Colors.white : Colors.black)),
              ],
            ),
          ),
          const VerticalDivider(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _toggleDislike ? Colors.blue : Colors.grey),
            onPressed: () async {
              handleDislike();
            },
            child: Row(
              children: [
                Icon(Icons.thumb_down,
                    color: _toggleDislike ? Colors.white : Colors.black),
                const SizedBox(width: 10),
                Text(bookInfo.dislikes.toString(),
                    style: TextStyle(
                        color: _toggleDislike ? Colors.white : Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleLike() async {
    int newLikesCount;
    int newDislikesCount;
    List<dynamic> elementToList = [_currentUser.uid];
    if (_toggleDislike) {
      _toggleDislike = false;
      newDislikesCount = bookInfo.dislikes - 1;
      bookInfo.dislikes = newDislikesCount;

      await collRef.doc(bookInfo.docID).update({
        'usersDislikes': FieldValue.arrayRemove(elementToList),
        'dislikes': newDislikesCount,
      });
    }
    if (_toggleLike) {
      _toggleLike = false;
      newLikesCount = bookInfo.likes - 1;
      bookInfo.likes = newLikesCount;

      await collRef.doc(bookInfo.docID).update({
        'usersLikes': FieldValue.arrayRemove(elementToList),
        'likes': newLikesCount,
      });
    } else {
      _toggleLike = true;
      newLikesCount = bookInfo.likes + 1;
      bookInfo.likes = newLikesCount;

      await collRef.doc(bookInfo.docID).update({
        'usersLikes': FieldValue.arrayUnion(elementToList),
        'likes': newLikesCount,
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  void handleDislike() async {
    int newLikesCount;
    int newDislikesCount;
    List<dynamic> elementToList = [_currentUser.uid];
    if (_toggleLike) {
      _toggleLike = false;
      newLikesCount = bookInfo.likes - 1;
      bookInfo.likes = newLikesCount;

      await collRef.doc(bookInfo.docID).update({
        'usersLikes': FieldValue.arrayRemove(elementToList),
        'likes': newLikesCount,
      });
    }
    if (_toggleDislike) {
      _toggleDislike = false;
      newDislikesCount = bookInfo.dislikes - 1;
      bookInfo.dislikes = newDislikesCount;

      await collRef.doc(bookInfo.docID).update({
        'usersDislikes': FieldValue.arrayRemove(elementToList),
        'dislikes': newDislikesCount,
      });
    } else {
      _toggleDislike = true;
      newDislikesCount = bookInfo.dislikes + 1;
      bookInfo.dislikes = newDislikesCount;

      await collRef.doc(bookInfo.docID).update({
        'usersDislikes': FieldValue.arrayUnion(elementToList),
        'dislikes': newDislikesCount,
      });
    }
    if (mounted) {
      setState(() {});
    }
  }
}
