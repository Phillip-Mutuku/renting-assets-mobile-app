import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExploreScreen extends StatefulWidget {
const ExploreScreen({super.key});

@override
State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
final Color navyBlue = const Color(0xFF0A1931);
final TextEditingController _searchController = TextEditingController();
bool isMapView = false;
String selectedFilter = 'All';

// Sample data
final List<Map<String, dynamic>> popularBrands = [
{
'name': 'BMW',
'logo': 'https://www.car-logos.org/wp-content/uploads/2011/09/bmw.png',
'carsCount': 45,
},
{
'name': 'Toyota',
'logo': 'https://www.car-logos.org/wp-content/uploads/2011/09/toyota.png',
'carsCount': 38,
},
{
'name': 'Mercedes',
'logo': 'https://www.car-logos.org/wp-content/uploads/2011/09/mercedes.png',
'carsCount': 42,
},
{
'name': 'Tesla',
'logo': 'https://www.car-logos.org/wp-content/uploads/2011/09/tesla.png',
'carsCount': 15,
},
];

final List<Map<String, dynamic>> cars = [
{
'name': 'Toyota Fortuner',
'type': 'SUV',
'brand': 'Toyota',
'rating': 4.8,
'reviews': 128,
'price': 85.00,
'image': 'https://i.pinimg.com/originals/d3/93/04/d393046a96199f0e8f5caa5d97ff02ea.png',
'location': 'New York City',
'distance': '2.5 km',
'features': ['GPS', 'Bluetooth', 'Manual', '5 Seats'],
'isPopular': true,
},
{
'name': 'Tesla Model 3',
'type': 'Electric',
'brand': 'Tesla',
'rating': 4.9,
'reviews': 95,
'price': 95.00,
'image': 'https://i.pinimg.com/originals/d3/93/04/d393046a96199f0e8f5caa5d97ff02ea.png',
'location': 'Brooklyn',
'distance': '3.8 km',
'features': ['Autopilot', 'Electric', 'Auto', '5 Seats'],
'isPopular': true,
},
];

final List<String> filters = [
'All',
'Nearest',
'Popular',
'Top Rated',
'Luxury',
'SUV',
'Electric',
];

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: Column(
children: [
_buildHeader(),
Expanded(
child: isMapView
? _buildMapView()
    : _buildListView(),
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
children: [
Expanded(
child: Container(
decoration: BoxDecoration(
color: Colors.grey[100],
borderRadius: BorderRadius.circular(12),
),
child: TextField(
controller: _searchController,
decoration: InputDecoration(
hintText: 'Search for cars',
prefixIcon: Icon(Icons.search, color: navyBlue),
border: InputBorder.none,
contentPadding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 12,
),
),
),
),
),
const SizedBox(width: 12),
GestureDetector(
onTap: () {
setState(() {
isMapView = !isMapView;
});
},
child: Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: navyBlue,
borderRadius: BorderRadius.circular(12),
),
child: Icon(
isMapView ? Icons.list : Icons.map,
color: Colors.white,
),
),
),
],
),
const SizedBox(height: 16),
SizedBox(
height: 40,
child: ListView.builder(
scrollDirection: Axis.horizontal,
itemCount: filters.length,
itemBuilder: (context, index) {
final filter = filters[index];
final isSelected = filter == selectedFilter;
return GestureDetector(
onTap: () {
setState(() {
selectedFilter = filter;
});
},
child: Container(
margin: const EdgeInsets.only(right: 8),
padding: const EdgeInsets.symmetric(horizontal: 16),
decoration: BoxDecoration(
color: isSelected ? navyBlue : Colors.grey[100],
borderRadius: BorderRadius.circular(20),
),
child: Center(
child: Text(
filter,
style: TextStyle(
color: isSelected ? Colors.white : Colors.black,
fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
),
),
),
),
);
},
),
),
],
),
);
}

Widget _buildListView() {
return ListView(
padding: const EdgeInsets.all(16),
children: [
_buildPopularBrandsSection(),
const SizedBox(height: 24),
_buildAvailableCarsSection(),
],
);
}

Widget _buildPopularBrandsSection() {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
'Popular Brands',
style: TextStyle(
color: navyBlue,
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
TextButton(
onPressed: () {},
child: Text(
'See All',
style: TextStyle(color: navyBlue),
),
),
],
),
const SizedBox(height: 16),
SizedBox(
height: 100,
child: ListView.builder(
scrollDirection: Axis.horizontal,
itemCount: popularBrands.length,
itemBuilder: (context, index) {
final brand = popularBrands[index];
return Container(
width: 100,
margin: const EdgeInsets.only(right: 12),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.1),
blurRadius: 8,
offset: const Offset(0, 2),
),
],
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
CachedNetworkImage(
imageUrl: brand['logo'],
height: 40,
placeholder: (context, url) => Shimmer.fromColors(
baseColor: Colors.grey[300]!,
highlightColor: Colors.grey[100]!,
child: Container(
height: 40,
color: Colors.white,
),
),
errorWidget: (context, url, error) => Icon(
Icons.car_rental,
size: 40,
color: navyBlue,
),
),
const SizedBox(height: 8),
Text(
brand['name'],
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
Text(
'${brand['carsCount']} cars',
style: TextStyle(
color: Colors.grey[600],
fontSize: 12,
),
),
],
),
);
},
),
),
],
);
}

Widget _buildAvailableCarsSection() {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Available Cars',
style: TextStyle(
color: navyBlue,
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 16),
ListView.builder(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
itemCount: cars.length,
itemBuilder: (context, index) {
final car = cars[index];
return GestureDetector(
onTap: () => _showCarDetails(car),
child: Container(
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
child: Column(
children: [
Stack(
children: [
ClipRRect(
borderRadius: const BorderRadius.vertical(
top: Radius.circular(16),
),
child: CachedNetworkImage(
imageUrl: car['image'],
height: 200,
width: double.infinity,
fit: BoxFit.cover,
placeholder: (context, url) => Shimmer.fromColors(
baseColor: Colors.grey[300]!,
highlightColor: Colors.grey[100]!,
child: Container(
height: 200,
color: Colors.white,
),
),
errorWidget: (context, url, error) => Container(
height: 200,
color: Colors.grey[100],
child: Icon(
Icons.car_rental,
size: 80,
color: navyBlue,
),
),
),
),
Positioned(
top: 12,
right: 12,
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 6,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
),
child: Row(
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
],
),
),
),
],
),
Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
car['name'],
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
Text(
car['type'],
style: TextStyle(
color: Colors.grey[600],
),
),
],
),
Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text(
'\$${car['price']}/day',
style: TextStyle(
color: navyBlue,
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
Text(
'${car['reviews']} reviews',
style: TextStyle(
color: Colors.grey[600],
fontSize: 12,
),
),
],
),
],
),
const SizedBox(height: 16),
Row(
children: [
Icon(
Icons.location_on,
size: 16,
color: Colors.grey[600],
),
const SizedBox(width: 4),
Text(
'${car['location']} (${car['distance']})',
style: TextStyle(
color: Colors.grey[600],
),
),
],
),
const SizedBox(height: 12),
Wrap(
spacing: 8,
runSpacing: 8,
children: car['features'].map<Widget>((feature) {
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 6,
),
decoration: BoxDecoration(
color: navyBlue.withOpacity(0.1),
borderRadius: BorderRadius.circular(20),
),
child: Text(
feature,
style: TextStyle(
color: navyBlue,
fontSize: 12,
),
),
);
}).toList(),
),
],
),
),
],
),
),
);
},
),
],
  );
}

  Widget _buildMapView() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(40.7128, -74.0060), // New York coordinates
            zoom: 12,
          ),
          markers: cars.map((car) {
            return Marker(
              markerId: MarkerId(car['name']),
              position: LatLng(
                40.7128 + (cars.indexOf(car) * 0.01),
                -74.0060 + (cars.indexOf(car) * 0.01),
              ),
              infoWindow: InfoWindow(
                title: car['name'],
                snippet: '\$${car['price']}/day',
              ),
              onTap: () => _showCarDetails(car),
            );
          }).toSet(),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
        ),
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Container(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Container(
                  width: 300,
                  margin: EdgeInsets.only(
                    right: index == cars.length - 1 ? 0 : 16,
                  ),
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
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: car['image'],
                            width: 120,
                            height: 180,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 120,
                                height: 180,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 120,
                              height: 180,
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.car_rental,
                                size: 40,
                                color: navyBlue,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  car['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  car['type'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
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
                                      '${car['rating']} (${car['reviews']})',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
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
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${car['price']}/day',
                                  style: TextStyle(
                                    color: navyBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showCarDetails(Map<String, dynamic> car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
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
                                child: Icon(
                                  Icons.car_rental,
                                  size: 80,
                                  color: navyBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
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
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.favorite_border,
                                  color: navyBlue,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              car['type'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${car['price']}/day',
                              style: TextStyle(
                                color: navyBlue,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${car['reviews']} reviews',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Features',
                      style: TextStyle(
                        color: navyBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: car['features'].map<Widget>((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: navyBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            feature,
                            style: TextStyle(
                              color: navyBlue,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle booking
                          Navigator.pop(context);
                          _showBookingDialog(car);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navyBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> car) {
    // Implement booking dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Book ${car['name']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Add booking form here
            ],
          ),
        ),
      ),
    );
  }
}