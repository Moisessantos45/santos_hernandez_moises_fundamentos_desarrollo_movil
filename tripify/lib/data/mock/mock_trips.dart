import '../../domain/models/trip.dart';

final List<Trip> mockTrips = [
  const Trip(
    id: '1',
    title: 'Old Town, Cádiz',
    location: 'California',
    country: 'USA',
    price: 450.0,
    rating: 4.8,
    reviewsCount: 128,
    imageUrl:
        'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80',
    category: 'Ciudad',
    description:
        'Explora la historia viva, callejones pintorescos y una gastronomía costera inolvidable en una de las ciudades más cautivadoras del mundo.',
    highlights: [
      'Vistas panorámicas',
      'Guía bilingüe',
      'Desayuno buffet',
      'Transporte incluido',
    ],
    isFavorite: true,
  ),
  const Trip(
    id: '2',
    title: 'Pagoda',
    location: 'Chiang Mai',
    country: 'Thailand',
    price: 450.0,
    rating: 4.6,
    reviewsCount: 94,
    imageUrl:
        'https://images.unsplash.com/photo-1528181304800-259b08848526?auto=format&fit=crop&w=800&q=80',
    category: 'Montaña',
    description:
        'Descubre templos sagrados rodeados de exuberante vegetación y niebla mística en el corazón cultural del sudeste asiático.',
    highlights: [
      'Templos históricos',
      'Ceremonia budista',
      'Fotografía guiada',
      'Almuerzo tradicional',
    ],
    isFavorite: false,
  ),
  const Trip(
    id: '3',
    title: 'Maldive',
    location: 'Malé Atoll',
    country: 'Singapore',
    price: 450.0,
    rating: 4.9,
    reviewsCount: 215,
    imageUrl:
        'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?auto=format&fit=crop&w=800&q=80',
    category: 'Playa',
    description:
        'Aguas cristalinas turquesas, villas sobre el mar y atardeceres de ensueño te esperan para una experiencia de relajación total.',
    highlights: [
      'Buceo con tortugas',
      'Resort 5 estrellas',
      'Cena privada en playa',
      'Spa de lujo',
    ],
    isFavorite: false,
  ),
  const Trip(
    id: '4',
    title: 'Gyeongbokgung',
    location: 'Seoul',
    country: 'South Korea',
    price: 450.0,
    rating: 4.7,
    reviewsCount: 178,
    imageUrl:
        'https://images.unsplash.com/photo-1538485399081-7191377e8241?auto=format&fit=crop&w=800&q=80',
    category: 'Ciudad',
    description:
        'El palacio principal de la dinastía Joseon. Un viaje en el tiempo con arquitectura tradicional, jardines zen y trajes hanbok.',
    highlights: [
      'Alquiler de Hanbok',
      'Paseo nocturno',
      'Entrada preferencial',
      'Guía experto',
    ],
    isFavorite: false,
  ),
  const Trip(
    id: '5',
    title: 'Santorini Sunset',
    location: 'Oia',
    country: 'Greece',
    price: 590.0,
    rating: 4.9,
    reviewsCount: 312,
    imageUrl:
        'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?auto=format&fit=crop&w=800&q=80',
    category: 'Playa',
    description:
        'Icónicas casas blancas y cúpulas azules sobre los acantilados del Mar Egeo con las puestas de sol más hermosas del planeta.',
    highlights: [
      'Catamarán privado',
      'Degustación de vino',
      'Traslado en helicóptero',
      'Fotógrafo',
    ],
    isFavorite: true,
  ),
  const Trip(
    id: '6',
    title: 'Zermatt Matterhorn',
    location: 'Valais',
    country: 'Switzerland',
    price: 720.0,
    rating: 4.8,
    reviewsCount: 140,
    imageUrl:
        'https://images.unsplash.com/photo-1530122037265-a5f1f91d3b99?auto=format&fit=crop&w=800&q=80',
    category: 'Montaña',
    description:
        'Aventúrate en los Alpes suizos frente a la imponente cumbre del Matterhorn con rutas de senderismo y teleféricos alpinos.',
    highlights: [
      'Tren alpino Gornergrat',
      'Pase de esquí',
      'Hotel con spa nórdico',
      'Cena Fondue',
    ],
    isFavorite: false,
  ),
];
