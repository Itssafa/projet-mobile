import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Podcast Explorer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {"title": "Technology", "color": Colors.blue, "icon": Icons.computer},
    {"title": "Comedy", "color": Colors.yellow, "icon": Icons.emoji_emotions},
    {"title": "Business", "color": Colors.green, "icon": Icons.business_center},
    {"title": "Health", "color": Colors.pink, "icon": Icons.favorite},
  ];

  final List<Map<String, dynamic>> podcasts = [
    {
      "title": "Tech Talk Daily",
      "author": "Neil Hughes",
      "image": "https://cdn-icons-png.flaticon.com/512/483/483361.png"
    },
    {
      "title": "Laugh Out Loud",
      "author": "Jane Doe",
      "image": "https://cdn-icons-png.flaticon.com/512/616/616408.png"
    },
    {
      "title": "Startup Stories",
      "author": "John Smith",
      "image": "https://cdn-icons-png.flaticon.com/512/4712/4712108.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Podcast Explorer"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Barre de recherche
            TextField(
              decoration: InputDecoration(
                hintText: "Search podcasts...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🏷️ Catégories
            const Text(
              "Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: cat['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cat['icon'], color: cat['color'], size: 30),
                        const SizedBox(height: 5),
                        Text(
                          cat['title'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 🎙️ Podcasts recommandés
            const Text(
              "Recommended Podcasts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: podcasts.map((podcast) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        podcast["image"],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      podcast["title"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(podcast["author"]),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.blue),
                      onPressed: () {
                        // Action de lecture
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
