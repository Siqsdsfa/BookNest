import 'package:booknest/data/book_info.dart';
import 'package:booknest/screens/item_description_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailsScreenData {
  String previousScreen;
  BookInfo bookInfo;
  DetailsScreenData({
    required this.previousScreen,
    required this.bookInfo,
  });
}

void goToBookDetails(
    BuildContext context, BookInfo bookInfo, String prevScreen) {
  context.pushNamed(
    DescriptionScreen.name,
    extra: DetailsScreenData(previousScreen: prevScreen, bookInfo: bookInfo),
  );
}

Widget tryCreateImage(String url) {
  return Image.network(
    url,
    height: 150,
    width: 150,
    errorBuilder: (context, error, stackTrace) {
      return const Icon(Icons.image_not_supported, size: 120);
    },
  );
}

class PublicationCardSkeleton extends StatelessWidget {
  const PublicationCardSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Skeleton(
          height: 100,
          width: 100,
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(),
              SizedBox(height: 8),
              Skeleton(),
              SizedBox(height: 8),
              Skeleton(width: 80),
              SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height, this.width});

  final double? height, width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(8),
    );
  }
}

Widget bookTextField(
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
