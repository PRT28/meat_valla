import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;

  final sampleProducts = [
    {
      "name": "Fresh Chicken Breast",
      "description": "Boneless, skinless chicken breast, perfect for grilling or baking.",
      "price": 299.0,
      "imageUrl": "https://example.com/images/chicken-breast.jpg",
      "category": "Chicken",
      "isAvailable": true,
      "isFeatured": true,
      "stockQuantity": 50,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Premium Mutton Curry Cut",
      "description": "Tender mutton pieces ideal for curries and slow cooking.",
      "price": 649.0,
      "imageUrl": "https://example.com/images/mutton-curry-cut.jpg",
      "category": "Mutton",
      "isAvailable": true,
      "isFeatured": false,
      "stockQuantity": 30,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Fresh Rohu Fish",
      "description": "Whole Rohu fish cleaned and ready to cook.",
      "price": 399.0,
      "imageUrl": "https://example.com/images/rohu-fish.jpg",
      "category": "Fish",
      "isAvailable": true,
      "isFeatured": true,
      "stockQuantity": 40,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Farm Fresh Eggs (Pack of 12)",
      "description": "Organic free-range eggs from local farms.",
      "price": 149.0,
      "imageUrl": "https://example.com/images/eggs-pack.jpg",
      "category": "Eggs",
      "isAvailable": true,
      "isFeatured": false,
      "stockQuantity": 100,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Chicken Drumsticks",
      "description": "Juicy chicken drumsticks, great for frying and grilling.",
      "price": 259.0,
      "imageUrl": "https://example.com/images/chicken-drumsticks.jpg",
      "category": "Chicken",
      "isAvailable": true,
      "isFeatured": false,
      "stockQuantity": 60,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Mutton Biryani Cut",
      "description": "Perfectly cut mutton pieces for biryani lovers.",
      "price": 699.0,
      "imageUrl": "https://example.com/images/mutton-biryani.jpg",
      "category": "Mutton",
      "isAvailable": true,
      "isFeatured": true,
      "stockQuantity": 25,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Salmon Fillet",
      "description": "Fresh Norwegian salmon fillet, rich in Omega-3.",
      "price": 1299.0,
      "imageUrl": "https://example.com/images/salmon-fillet.jpg",
      "category": "Fish",
      "isAvailable": true,
      "isFeatured": true,
      "stockQuantity": 20,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Prawns (Large)",
      "description": "Fresh, deveined large prawns for curries and grills.",
      "price": 899.0,
      "imageUrl": "https://example.com/images/prawns-large.jpg",
      "category": "Seafood",
      "isAvailable": true,
      "isFeatured": false,
      "stockQuantity": 35,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Crab Meat",
      "description": "Fresh crab meat, cleaned and ready to cook.",
      "price": 999.0,
      "imageUrl": "https://example.com/images/crab-meat.jpg",
      "category": "Seafood",
      "isAvailable": true,
      "isFeatured": true,
      "stockQuantity": 15,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Quail Meat",
      "description": "Delicately flavored quail meat for special recipes.",
      "price": 499.0,
      "imageUrl": "https://example.com/images/quail-meat.jpg",
      "category": "Specialty",
      "isAvailable": true,
      "isFeatured": false,
      "stockQuantity": 10,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Duck Breast",
      "description": "Tender duck breast with rich flavor.",
      "price": 799.0,
      "imageUrl": "https://example.com/images/duck-breast.jpg",
      "category": "Specialty",
      "isAvailable": true,
      "isFeatured": true,
      "stockQuantity": 12,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Turkey Mince",
      "description": "Lean turkey mince for healthy dishes.",
      "price": 399.0,
      "imageUrl": "https://example.com/images/turkey-mince.jpg",
      "category": "Specialty",
      "isAvailable": true,
      "isFeatured": false,
      "stockQuantity": 18,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Boiled Eggs (Pack of 6)",
      "description": "Perfectly boiled eggs, ready to eat.",
      "price": 89.0,
      "imageUrl": "https://example.com/images/boiled-eggs.jpg",
      "category": "Eggs",
      "isAvailable": true,
      "isFeatured": false,
      "stockQuantity": 70,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    },
    {
      "name": "Brown Eggs (Pack of 12)",
      "description": "Nutritious brown eggs from free-range hens.",
      "price": 169.0,
      "imageUrl": "https://example.com/images/brown-eggs.jpg",
      "category": "Eggs",
      "isAvailable": true,
      "isFeatured": true,
      "stockQuantity": 90,
      "createdAt": { "_seconds": 1733952000, "_nanoseconds": 0 }
    }
  ];

  for (var product in sampleProducts) {
    await firestore.collection('products').add(product);
  }

  print("Sample products added to Firestore.");
}
