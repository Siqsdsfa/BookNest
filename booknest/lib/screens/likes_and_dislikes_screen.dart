import 'package:booknest/data/book_info.dart';
import 'package:booknest/core/utils.dart';
import 'package:booknest/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikesAndDislikesScreen extends StatefulWidget {
  const LikesAndDislikesScreen({super.key});
  static const String name = 'likes_dislikes';
  @override
  State<LikesAndDislikesScreen> createState() => _LikesAndDislikesScreenState();
}

class _LikesAndDislikesScreenState extends State<LikesAndDislikesScreen> {
  late bool _isLoading = true;
  bool fetchingRequired = true;
  List<BookInfo> likedBooks = [];
  List<BookInfo> dislikedBooks = [];
  final _currentUser = FirebaseAuth.instance.currentUser!;

  void fetchRecords() async {
    try {
      await fetchLikesRecords();
      await fetchDislikesRecords();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchLikesRecords() async {
    var records = await FirebaseFirestore.instance
        .collection("books_info")
        .where('usersLikes', arrayContains: _currentUser.uid)
        .get();

    if (mounted) {
      setState(() {
        likedBooks = mapRecords(records);
      });
    }
  }

  Future<void> fetchDislikesRecords() async {
    var records = await FirebaseFirestore.instance
        .collection("books_info")
        .where('usersDislikes', arrayContains: _currentUser.uid)
        .get();

    if (mounted) {
      setState(() {
        dislikedBooks = mapRecords(records);
      });
    }
  }

  List<BookInfo> mapRecords(QuerySnapshot<Map<String, dynamic>> records) {
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
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (fetchingRequired == true) {
      _isLoading = true;
      fetchRecords();
      setState(() {
        fetchingRequired = false;
      });
    }
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) => context.pushNamed(HomeScreen.name),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            title: const Text("Feedback"),
            centerTitle: true,
            bottom: const TabBar(tabs: [
              Tab(
                icon: Icon(
                  Icons.thumb_up,
                  size: 40,
                ),
                text: 'Likes',
              ),
              Tab(
                icon: Icon(
                  Icons.thumb_down,
                  size: 40,
                ),
                text: 'Dislikes',
              )
            ]),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    fetchingRequired = true;
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 35),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              _toggleLikesPage(),
              _toggleDislikesPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleLikesPage() {
    if (_isLoading == true) {
      debugPrint('Is Loading');
      return _notLoadedPage();
    } else {
      debugPrint('Has already loaded');
      return _likesPage();
    }
  }

  Widget _toggleDislikesPage() {
    if (_isLoading == true) {
      debugPrint('Is Loading');
      return _notLoadedPage();
    } else {
      debugPrint('Has already loaded');
      return _dislikesPage();
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

  Widget _likesPage() {
    if (likedBooks.isNotEmpty) {
      return ListView(
        children: [
          ListView.builder(
            itemCount: likedBooks.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final tile = likedBooks[index];
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
                          goToBookDetails(context, tile);
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
                                          fontSize: 12, color: Colors.black)),
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
      );
    } else {
      return const Center(child: Text('No books liked yet!'));
    }
  }

  Widget _dislikesPage() {
    if (dislikedBooks.isNotEmpty) {
      return ListView(
        children: [
          ListView.builder(
            itemCount: dislikedBooks.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final tile = dislikedBooks[index];
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
                          goToBookDetails(context, tile);
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
                                          fontSize: 12, color: Colors.black)),
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
      );
    } else {
      return const Center(child: Text('It seems you don\' dilike anything!'));
    }
  }
}
