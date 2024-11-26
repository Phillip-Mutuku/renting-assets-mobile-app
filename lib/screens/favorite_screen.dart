import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class FavoriteScreen extends StatefulWidget {
const FavoriteScreen({super.key});

@override
State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with SingleTickerProviderStateMixin {
final Color navyBlue = const Color(0xFF0A1931);
late TabController _tabController;
String selectedFilter = 'All';
bool isGridView = true;

// Sample data
final List<Map<String, dynamic>> favoriteCars = [
{
'name': 'BMW 7 Series',
'type': 'Luxury',
'brand': 'BMW',
'rating': 4.9,
'reviews': 128,
'price': 85.00,
'image': 'https://i.pinimg.com/originals/d3/93/04/d393046a96199f0e8f5caa5d97ff02ea.png',
'location': 'New York City',
'distance': '2.5 km',
'features': ['GPS', 'Bluetooth', 'Manual', '5 Seats'],
'isAvailable': true,
'savedDate': '2024-02-20',
'category': 'Recent',
},
{
'name': 'Mercedes S-Class',
'type': 'Luxury',
'brand': 'Mercedes',
'rating': 4.8,
'reviews': 98,
'price': 95.00,
'image': 'https://i.pinimg.com/originals/d3/93/04/d393046a96199f0e8f5caa5d97ff02ea.png',
'location': 'Manhattan',
'distance': '3.2 km',
'features': ['GPS', 'Premium Audio', 'Automatic', '5 Seats'],
'isAvailable': true,
'savedDate': '2024-02-15',
'category': 'Luxury',
},
{
'name': 'Tesla Model 3',
'type': 'Electric',
'brand': 'Tesla',
'rating': 4.7,
'reviews': 85,
'price': 75.00,
'image': 'https://i.pinimg.com/originals/d3/93/04/d393046a96199f0e8f5caa5d97ff02ea.png',
'location': 'Brooklyn',
'distance': '4.1 km',
'features': ['Autopilot', 'Electric', 'Automatic', '5 Seats'],
'isAvailable': false,
'savedDate': '2024-02-10',
'category': 'Electric',
},
];

final List<String> filters = [
'All',
'Available',
'Luxury',
'Electric',
'SUV',
'Sports',
];

final List<String> sortOptions = [
'Recently Added',
'Price: Low to High',
'Price: High to Low',
'Rating',
'Distance',
];

String selectedSort = 'Recently Added';

@override
void initState() {
super.initState();
_tabController = TabController(length: 3, vsync: this);
}

@override
void dispose() {
_tabController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: Column(
children: [
_buildHeader(),
_buildTabBar(),
Expanded(
child: TabBarView(
controller: _tabController,
children: [
_buildAllFavorites(),
_buildCollections(),
_buildHistory(),
],
),
),
],
),
),
);
}

Widget _buildHeader() {
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
offset: const Offset(0, 2),
),
],
),
child: Column(
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
'Favorites',
style: TextStyle(
color: navyBlue,
fontSize: 24,
fontWeight: FontWeight.bold,
),
),
Row(
children: [
IconButton(
icon: Icon(
isGridView ? Icons.view_list : Icons.grid_view,
color: navyBlue,
),
onPressed: () {
setState(() {
isGridView = !isGridView;
});
},
),
IconButton(
icon: Icon(Icons.sort, color: navyBlue),
onPressed: _showSortOptions,
),
],
),
],
),
const SizedBox(height: 16),
SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: Row(
children: filters.map((filter) {
final isSelected = filter == selectedFilter;
return GestureDetector(
onTap: () {
setState(() {
selectedFilter = filter;
});
},
child: Container(
margin: const EdgeInsets.only(right: 8),
padding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 8,
),
decoration: BoxDecoration(
color: isSelected ? navyBlue : Colors.grey[100],
borderRadius: BorderRadius.circular(20),
),
child: Text(
filter,
style: TextStyle(
color: isSelected ? Colors.white : Colors.black,
fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
),
),
),
);
}).toList(),
),
),
],
),
);
}

Widget _buildTabBar() {
return Container(
color: Colors.white,
child: TabBar(
controller: _tabController,
labelColor: navyBlue,
unselectedLabelColor: Colors.grey,
indicatorColor: navyBlue,
tabs: const [
Tab(text: 'All'),
Tab(text: 'Collections'),
Tab(text: 'History'),
],
),
);
}

  Widget _buildAllFavorites() {
    final filteredCars = favoriteCars.where((car) {
      if (selectedFilter == 'All') return true;
      if (selectedFilter == 'Available') return car['isAvailable'];
      return car['type'] == selectedFilter;
    }).toList();

    if (isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredCars.length,
        itemBuilder: (context, index) => _buildGridItem(filteredCars[index]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCars.length,
      itemBuilder: (context, index) => _buildListItem(filteredCars[index]),
    );
  }

  Widget _buildGridItem(Map<String, dynamic> car) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Section - Takes up 60% of the space
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: car['image'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: Icon(Icons.car_rental, color: navyBlue),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                      onPressed: () => _removeFavorite(car),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (!car['isAvailable'])
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Not Available',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Details Section - Takes up 40% of the space
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        car['type'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${car['rating']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        ' (${car['reviews']})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${car['price']}/day',
                    style: TextStyle(
                      color: navyBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildListItem(Map<String, dynamic> car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showCarDetails(car),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox( // Added SizedBox with fixed height
          height: 140, // Increased height to accommodate content
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Changed to start alignment
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: car['image'],
                      width: 140, // Increased width
                      height: 140, // Matched height with parent
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 140,
                          height: 140,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 140,
                        height: 140,
                        color: Colors.grey[100],
                        child: Icon(Icons.car_rental, color: navyBlue),
                      ),
                    ),
                  ),
                  if (!car['isAvailable'])
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Not\nAvailable',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to space between
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      car['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      car['type'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () => _removeFavorite(car),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${car['rating']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' (${car['reviews']})',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                car['distance'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${car['price']}/day',
                            style: TextStyle(
                              color: navyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCollections() {
    final collections = {
      'Luxury Cars': favoriteCars.where((car) => car['type'] == 'Luxury').length,
      'Electric Vehicles': favoriteCars.where((car) => car['type'] == 'Electric').length,
      'SUVs': favoriteCars.where((car) => car['type'] == 'SUV').length,
      'Sports Cars': favoriteCars.where((car) => car['type'] == 'Sports').length,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'My Collections',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...collections.entries.map((entry) => _buildCollectionCard(
          title: entry.key,
          count: entry.value,
          onTap: () => _showCollectionDetails(entry.key),
        )),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: _createNewCollection,
          style: OutlinedButton.styleFrom(
            foregroundColor: navyBlue,
            side: BorderSide(color: navyBlue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Create New Collection'),
        ),
      ],
    );
  }

  Widget _buildCollectionCard({
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '$count vehicles',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: navyBlue,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildHistory() {
    final historyCars = [...favoriteCars]..sort(
          (a, b) => DateTime.parse(b['savedDate']).compareTo(DateTime.parse(a['savedDate'])),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recently Added',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...historyCars.map((car) => _buildHistoryItem(car)),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> car) {
    final savedDate = DateTime.parse(car['savedDate']);
    final now = DateTime.now();
    final difference = now.difference(savedDate);
    String timeAgo;

    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h ago';
    } else {
      timeAgo = '${difference.inMinutes}m ago';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: car['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[100],
                child: Icon(Icons.car_rental, color: navyBlue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Added to ${car['category']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeAgo,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showHistoryOptions(car),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Sort By',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortOptions.map(
                (option) => ListTile(
              title: Text(option),
              trailing: option == selectedSort
                  ? Icon(Icons.check, color: navyBlue)
                  : null,
              onTap: () {
                setState(() {
                  selectedSort = option;
                });
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showCarDetails(Map<String, dynamic> car) {
    // Implement car details view
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(car['name']),
          ),
          body: Center(
            child: Text('Car Details View - ${car['name']}'),
          ),
        ),
      ),
    );
  }

  void _removeFavorite(Map<String, dynamic> car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Favorites?'),
        content: Text('Are you sure you want to remove ${car['name']} from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement remove logic
              setState(() {
                favoriteCars.remove(car);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${car['name']} removed from favorites'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      setState(() {
                        favoriteCars.add(car);
                      });
                    },
                  ),
                ),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showCollectionDetails(String collectionName) {
    // Implement collection details view
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(collectionName),
          ),
          body: Center(
            child: Text('Collection Details View - $collectionName'),
          ),
        ),
      ),
    );
  }

  void _createNewCollection() {
    // Implement create new collection logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Collection'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Collection Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement create logic
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showHistoryOptions(Map<String, dynamic> car) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: navyBlue),
            title: const Text('Remove from History'),
            onTap: () {
              Navigator.pop(context);
              _removeFavorite(car);
            },
          ),
          ListTile(
            leading: Icon(Icons.folder_outlined, color: navyBlue),
            title: const Text('Move to Collection'),
            onTap: () {
              Navigator.pop(context);
              // Implement move to collection logic
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}