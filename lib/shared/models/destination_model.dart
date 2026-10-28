class DestinationModel {
  final String id;
  final String name;
  final String country;
  final String description;
  final double latitude;
  final double longitude;
  final String continent;
  final String timezone;
  final String imageUrl;
  final List<String> imageUrls;
  final double rating;

  // ── Extended info ─────────────────────────────────────────────────────────
  final String language;
  final String currency;
  final String bestTime; // best months/season to visit
  final String weather; // typical climate description
  final List<String> highlights; // top 4–5 attractions / experiences
  final String travelTip; // a practical travel tip
  final String? panoramaUrl; // Google Street View embed URL for 360° view

  const DestinationModel({
    required this.id,
    required this.name,
    required this.country,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.continent,
    required this.timezone,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.rating,
    this.language = '',
    this.currency = '',
    this.bestTime = '',
    this.weather = '',
    this.highlights = const [],
    this.travelTip = '',
    this.panoramaUrl,
  });

  String get imagePath => imageUrl;
  List<String> get images => imageUrls.isNotEmpty ? imageUrls : [imageUrl];
}

const List<DestinationModel> allDestinations = [
  // ── EAST ASIA ──────────────────────────────────────────────────────────────
  DestinationModel(
    id: '1',
    name: 'Tokyo',
    country: 'Tokyo, Japan',
    description:
        'A dazzling metropolis where ultramodern skyscrapers stand alongside ancient temples and cherry-blossom gardens. Tokyo seamlessly blends tradition and innovation — from the serene Meiji Shrine to the neon-lit streets of Shibuya and Akihabara. The city boasts more Michelin-starred restaurants than any other on Earth, a hyper-efficient transit network, and a culture defined by extraordinary attention to detail and hospitality.',
    latitude: 35.6762,
    longitude: 139.6503,
    continent: 'East Asia',
    timezone: 'UTC+9 (JST)',
    imageUrl:
        'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1513407030348-c983a97b98d8?w=800',
      'https://images.unsplash.com/photo-1536098561742-ca998e48cbcc?w=800',
      'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800',
    ],
    rating: 4.9,
    language: 'Japanese',
    currency: 'Japanese Yen (¥)',
    bestTime: 'March–May (cherry blossom) · Oct–Nov (autumn foliage)',
    weather:
        'Temperate. Hot humid summers (30 °C+) and mild winters with occasional snow.',
    highlights: [
      'Shibuya Scramble Crossing — world\'s busiest pedestrian crossing',
      'Senso-ji Temple in Asakusa — Tokyo\'s oldest Buddhist temple',
      'Shinjuku Golden Gai — atmospheric maze of tiny bars',
      'TeamLab Borderless — immersive digital art museum',
      'Tsukiji Outer Market — fresh sushi at sunrise',
    ],
    travelTip:
        'Buy a Suica or Pasmo IC card on arrival — it covers almost every train, bus, and subway in Greater Tokyo and can even be used at convenience stores.',
  ),
  DestinationModel(
    id: '2',
    name: 'Kyoto',
    country: 'Kyoto, Japan',
    description:
        "Japan's cultural capital and the soul of traditional Japanese aesthetics. Home to over 1,600 Buddhist temples, 400 Shinto shrines, and 17 UNESCO World Heritage Sites, Kyoto preserves the Japan of geisha districts, wooden machiya townhouses, exquisite kaiseki cuisine, and meditative zen gardens. The city served as Japan's imperial capital for over a millennium and remains the best place to experience classical Japanese culture.",
    latitude: 35.0116,
    longitude: 135.7681,
    continent: 'East Asia',
    timezone: 'UTC+9 (JST)',
    imageUrl:
        'https://www.kevinandamanda.com/wp-content/uploads/2018/02/best-things-to-do-kyoto-japan-12.jpg',
    imageUrls: [
      'https://towel.japarcana.com/cdn/shop/articles/BEST_PLACES_TO_GO_IN_KYOTO.webp?v=1745903349',
      'https://images.unsplash.com/photo-1480796927426-f609979314bd?w=800',
      'https://images.unsplash.com/photo-1524413840807-0c3cb6fa808d?w=800',
    ],
    rating: 4.8,
    language: 'Japanese',
    currency: 'Japanese Yen (¥)',
    bestTime: 'March–May · November (peak autumn colours)',
    weather:
        'Four distinct seasons. Summers are hot and humid; winters are cold with occasional snow.',
    highlights: [
      'Fushimi Inari Taisha — thousands of vermilion torii gates winding up a mountain',
      'Arashiyama Bamboo Grove — ethereal towering bamboo forest',
      'Kinkaku-ji (Golden Pavilion) — Zen Buddhist temple covered in gold leaf',
      'Gion District — historic geisha quarter with wooden ochaya teahouses',
      'Kiyomizu-dera — wooden stage temple with panoramic city views',
    ],
    travelTip:
        'Visit Fushimi Inari at dawn or dusk — the thousands of torii gates glow in the golden light and crowds are minimal compared to midday.',
  ),
  DestinationModel(
    id: '3',
    name: 'Shanghai',
    country: 'Shanghai, China',
    description:
        "China's most cosmopolitan city, where the futuristic Pudong skyline — anchored by the Oriental Pearl Tower and Shanghai Tower — reflects across the Huangpu River opposite the colonial-era Bund waterfront. Shanghai is China's financial and fashion capital, a global hub for art, architecture, and gastronomy. Its labyrinthine shikumen alleyways, art-deco buildings, and cutting-edge skyscrapers coexist in spectacular contrast.",
    latitude: 31.2304,
    longitude: 121.4737,
    continent: 'East Asia',
    timezone: 'UTC+8 (CST)',
    imageUrl:
        'https://images.unsplash.com/photo-1474181487882-5abf3f0ba6c2?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=800',
      'https://vj-prod-website-cms.s3.ap-southeast-1.amazonaws.com/q3-1715758571558.jpg',
      'https://www.banyantree.com/assets/2025-01/2_0.png',
    ],
    rating: 4.7,
    language: 'Mandarin Chinese',
    currency: 'Chinese Yuan (¥)',
    bestTime: 'April–May · September–November',
    weather:
        'Subtropical humid. Mild spring and autumn; hot, rainy summers; cool winters.',
    highlights: [
      'The Bund — iconic 1.5 km waterfront promenade with colonial architecture',
      'Pudong Skyline — home to the 632 m Shanghai Tower',
      'Yu Garden — classical Ming dynasty garden in the old city',
      'French Concession — tree-lined boulevards, cafés, and boutiques',
      'Shanghai Museum — world-class collection of ancient Chinese art',
    ],
    travelTip:
        'Take the Maglev train from Pudong Airport — it reaches 431 km/h and is the fastest commercial train in the world, whisking you to the city in 8 minutes.',
  ),

  // ── SOUTHEAST ASIA ─────────────────────────────────────────────────────────
  DestinationModel(
    id: '4',
    name: 'Bali',
    country: 'Bali, Indonesia',
    description:
        'The Island of the Gods enchants visitors with emerald rice terraces cascading down volcanic slopes, sacred temples draped in frangipani blossoms, and surf-washed beaches of black and white sand. Bali\'s deeply spiritual Hindu-Balinese culture permeates every aspect of life — daily offerings, elaborate ceremonies, and a philosophy of harmony between people, nature, and the gods. From the artistic town of Ubud to the surf capital of Canggu, every corner offers discovery.',
    latitude: -8.3405,
    longitude: 115.0920,
    continent: 'Southeast Asia',
    timezone: 'UTC+8 (WITA)',
    imageUrl:
        'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1552733407-5d5c46c3bb3b?w=800',
      'https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=800',
      'https://images.unsplash.com/photo-1604999333679-b86d54738315?w=800',
    ],
    rating: 4.9,
    language: 'Balinese / Indonesian',
    currency: 'Indonesian Rupiah (Rp)',
    bestTime: 'April–October (dry season)',
    weather:
        'Tropical. Dry season April–Oct, wet season Nov–March. Year-round warm (25–32 °C).',
    highlights: [
      'Tegallalang Rice Terraces — iconic UNESCO-listed stepped rice paddies near Ubud',
      'Tanah Lot — sea temple perched on a rocky outcrop at sunset',
      'Ubud Monkey Forest — sacred sanctuary with hundreds of long-tailed macaques',
      'Mount Batur Sunrise Trek — active volcano hike with panoramic crater lake views',
      'Seminyak Beach — trendy beach clubs, world-class surfing, and stunning sunsets',
    ],
    travelTip:
        'Rent a scooter (≈ Rp 70,000/day) to explore villages off the tourist trail — but always wear a helmet and carry an international driving permit.',
  ),
  DestinationModel(
    id: '5',
    name: 'Bangkok',
    country: 'Bangkok, Thailand',
    description:
        "Thailand's dazzling capital blends ornate royal palaces, gilded temples, and a legendary street food scene with an electrifying modern nightlife, bustling floating markets, and world-class rooftop bars. The Chao Phraya River threads through the city carrying longtail boats past glittering spires and crumbling colonial shophouses. Bangkok is Asia's most-visited city for good reason — its sheer sensory intensity is utterly addictive.",
    latitude: 13.7563,
    longitude: 100.5018,
    continent: 'Southeast Asia',
    timezone: 'UTC+7 (ICT)',
    imageUrl:
        'https://www.shutterstock.com/shutterstock/videos/3726823619/thumb/1.jpg?ip=x480',
    imageUrls: [
      'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=800',
      'https://images.unsplash.com/photo-1559561853-08451507cbe7?w=800',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
    ],
    rating: 4.7,
    language: 'Thai',
    currency: 'Thai Baht (฿)',
    bestTime: 'November–February (cool dry season)',
    weather:
        'Tropical monsoon. Hot and humid year-round (28–38 °C); rainy season May–Oct.',
    highlights: [
      'Wat Phra Kaew (Temple of the Emerald Buddha) — holiest site in Thailand',
      'Grand Palace — opulent royal complex of gilded spires and mirrored halls',
      'Chatuchak Weekend Market — one of the world\'s largest markets with 15,000 stalls',
      'Khao San Road — legendary backpacker street with vibrant nightlife',
      'Damnoen Saduak Floating Market — colourful boats selling tropical fruits',
    ],
    travelTip:
        'Dress modestly (cover shoulders and knees) when visiting temples. Lightweight trousers and a scarf in your bag will save you from renting overpriced wrap-arounds at the entrance.',
  ),

  // ── SOUTH ASIA ─────────────────────────────────────────────────────────────
  DestinationModel(
    id: '6',
    name: 'Taj Mahal',
    country: 'Agra, India',
    description:
        'The world\'s greatest monument to love, this ivory-white marble mausoleum was commissioned in 1632 by Mughal emperor Shah Jahan in memory of his beloved wife Mumtaz Mahal, who died in childbirth. Flanked by four minarets and reflected in a long ornamental pool, the Taj Mahal is a masterpiece of Mughal architecture, blending Persian, Islamic, and Indian styles. A UNESCO World Heritage Site and one of the Seven Wonders of the Modern World, it draws millions who come to witness its ethereal beauty at sunrise.',
    latitude: 27.1751,
    longitude: 78.0421,
    continent: 'South Asia',
    timezone: 'UTC+5:30 (IST)',
    imageUrl:
        'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1548013146-72479768bada?w=800',
      'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800',
      'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?w=800',
    ],
    rating: 4.9,
    language: 'Hindi / Urdu',
    currency: 'Indian Rupee (₹)',
    bestTime: 'October–March (cool, clear skies)',
    weather:
        'Semi-arid. Very hot summers (45 °C+); mild winters (5–20 °C); monsoon July–September.',
    highlights: [
      'Main mausoleum — 73 m-high marble dome inlaid with 28 types of precious stones',
      'Mehtab Bagh — moonlight garden across the Yamuna with perfect mirror view of the Taj',
      'Agra Fort — UNESCO red sandstone fort housing royal palaces and audience halls',
      'Itimad-ud-Daulah — the "Baby Taj", a delicate Mughal tomb predating the Taj Mahal',
      'Sunrise visit — the marble glows pink then golden as the sun rises over the Yamuna',
    ],
    travelTip:
        'Buy tickets online in advance (foreigners pay ₹1,100). Arrive at the East or West Gate 30 minutes before opening to reach the main viewing pool before tour groups arrive.',
  ),
  DestinationModel(
    id: '7',
    name: 'Maldives',
    country: 'North Malé Atoll, Maldives',
    description:
        'A tropical paradise of 1,192 coral islands scattered across the Indian Ocean, the Maldives is the world\'s most dispersed country — and its most photogenic. Famous for overwater bungalows perched above impossibly clear turquoise lagoons, house reefs teeming with manta rays and whale sharks, and bioluminescent beaches that glow electric blue at night. This nation of atolls sits at an average elevation of just 1.5 m — making it one of the most climate-vulnerable places on Earth.',
    latitude: 3.2028,
    longitude: 73.2207,
    continent: 'South Asia',
    timezone: 'UTC+5 (MVT)',
    imageUrl:
        'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?w=800',
      'https://images.unsplash.com/photo-1540202403-b7abd6747a18?w=800',
      'https://images.unsplash.com/photo-1516815231560-8f41ec531527?w=800',
    ],
    rating: 4.9,
    language: 'Dhivehi',
    currency: 'Maldivian Rufiyaa (MVR) / USD widely accepted',
    bestTime: 'November–April (dry season, calm seas)',
    weather:
        'Tropical. Warm year-round (27–30 °C). Wet season May–October with afternoon squalls.',
    highlights: [
      'Overwater bungalow — wake up above a turquoise lagoon with marine life below',
      'Scuba diving & snorkelling — pristine reefs with sharks, rays, and sea turtles',
      'Whale shark encounters — snorkel with the world\'s largest fish near Ari Atoll',
      'Bioluminescent beach — neon blue plankton light up the shore after dark',
      'Local island hopping — visit traditional fishing villages away from resort islands',
    ],
    travelTip:
        'Budget resorts on local islands like Maafushi offer a fraction of the cost of private-island resorts and still provide access to stunning reefs and beaches.',
  ),

  // ── WEST ASIA / MIDDLE EAST ────────────────────────────────────────────────
  DestinationModel(
    id: '8',
    name: 'Dubai',
    country: 'Dubai, UAE',
    description:
        'A city of superlatives rising from the Arabian Desert in just five decades. Home to the world\'s tallest building (Burj Khalifa, 828 m), largest shopping mall, indoor ski slope in the desert, and a palm-shaped archipelago of man-made islands visible from space. Yet beneath the glitter lies a rich Emirati heritage of dhow-building, pearl diving, and spice trading — best explored in the atmospheric Al Fahidi Historic District and the Dubai Creek gold and spice souks.',
    latitude: 25.2048,
    longitude: 55.2708,
    continent: 'West Asia',
    timezone: 'UTC+4 (GST)',
    imageUrl:
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=800',
      'https://images.unsplash.com/photo-1546412414-e1885259563a?w=800',
      'https://images.unsplash.com/photo-1582672060674-bc2bd808a8b5?w=800',
    ],
    rating: 4.8,
    language: 'Arabic (English widely spoken)',
    currency: 'UAE Dirham (AED)',
    bestTime: 'November–March (pleasant 20–25 °C)',
    weather:
        'Desert climate. Extremely hot summers (45 °C+); warm, sunny winters. Almost no rain.',
    highlights: [
      'Burj Khalifa (At the Top) — elevator to 148th floor for jaw-dropping panoramas',
      'Dubai Mall & Dubai Fountain — world\'s largest shopping mall with an aquarium',
      'Desert Safari — dune bashing, camel rides, and Bedouin dinner under the stars',
      'Palm Jumeirah — man-made palm island with luxury hotels and Atlantis resort',
      'Old Dubai Creek — traditional abra (water taxi) crossing to gold and spice souks',
    ],
    travelTip:
        'Visit between November and March for comfortable outdoor temperatures. Dress modestly in public areas and note that alcohol is only served in licensed hotel venues.',
  ),
  DestinationModel(
    id: '9',
    name: 'Petra',
    country: "Ma'an, Jordan",
    description:
        'The Rose City, carved entirely into rose-red cliff faces by the Nabataean Arabs over 2,000 years ago, is one of the most extraordinary archaeological sites on Earth. Hidden within a maze of dramatic sandstone canyons in southern Jordan, Petra served as the capital of the Nabataean Kingdom and a vital crossroads of ancient spice and silk trade routes. Walking the 1.2 km Siq gorge — its towering walls narrowing to just a few metres — before the iconic Treasury (Al-Khazneh) suddenly appears is one of travel\'s most theatrical experiences.',
    latitude: 30.3285,
    longitude: 35.4444,
    continent: 'West Asia',
    timezone: 'UTC+3 (AST)',
    imageUrl:
        'https://images.unsplash.com/photo-1518638150340-f706e86654de?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1579606032821-4e6161c81bd3?w=800',
      'https://i0.wp.com/www.worldwanderista.com/wp-content/uploads/2018/04/best-views-in-Petra-Jordan-Treasury2.jpg?ssl=1',
      'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
    ],
    rating: 4.8,
    language: 'Arabic',
    currency: 'Jordanian Dinar (JOD)',
    bestTime: 'March–May · September–November',
    weather:
        'Desert/semi-arid. Hot summers (35 °C+), cool winters, occasional frost at altitude.',
    highlights: [
      'The Treasury (Al-Khazneh) — 40 m-high tomb façade, Petra\'s most iconic image',
      'The Monastery (Ad Deir) — larger than the Treasury, reached via 800 rock-cut steps',
      'The Siq — dramatic 1.2 km gorge with walls soaring 80 m overhead',
      'Petra by Night — candles light the Siq on Mon, Wed, Thu evenings for a magical walk',
      'High Place of Sacrifice — mountaintop altar with sweeping canyon views',
    ],
    travelTip:
        'Buy the Jordan Pass (from US\$70) before arriving — it includes your visa fee and Petra entrance ticket, saving significant money over buying separately.',
  ),

  // ── EUROPE ─────────────────────────────────────────────────────────────────
  DestinationModel(
    id: '10',
    name: 'Eiffel Tower',
    country: 'Paris, France',
    description:
        'An iconic iron lattice tower and the defining symbol of France, the Tour Eiffel was designed by Gustave Eiffel and built in 1889 as a temporary entrance arch for the World\'s Fair. Initially criticised by Parisian intellectuals as an eyesore, it became the most-visited paid monument on Earth. Rising 330 m above the Champ de Mars, the tower offers three observation levels with breathtaking panoramic views over Paris — and is most magical when its 20,000 light bulbs sparkle every evening on the hour.',
    latitude: 48.8584,
    longitude: 2.2945,
    continent: 'Europe',
    timezone: 'UTC+1 (CET)',
    imageUrl:
        'https://i.pinimg.com/736x/63/a4/48/63a44833f86b4532fcd88a7339add968.jpg',
    imageUrls: [
      'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
      'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800',
      'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800',
    ],
    rating: 4.9,
    language: 'French',
    currency: 'Euro (€)',
    bestTime: 'April–June · September–October',
    weather:
        'Temperate oceanic. Mild year-round; warm summers (20–25 °C); cool, rainy winters.',
    highlights: [
      'Summit viewing platform — 276 m elevation with views stretching 70 km on clear days',
      'Trocadéro Gardens — the classic spot for Eiffel Tower photographs across the Seine',
      'Seine River Cruise — see the tower from a Bateaux Mouches boat at golden hour',
      'Champagne Bar on the 1st floor — sip bubbles with the Parisian skyline as backdrop',
      'Light Show (nightfall) — 20,000 bulbs sparkle for 5 minutes every hour after dark',
    ],
    travelTip:
        'Book tickets online weeks in advance — summit tickets sell out fast. Visit at dusk so you can see Paris in daylight and catch the first sparkling light show after dark.',
  ),
  DestinationModel(
    id: '11',
    name: 'Santorini',
    country: 'Santorini, Greece',
    description:
        'Born from one of history\'s largest volcanic eruptions around 1600 BCE, Santorini\'s dramatic caldera — a 12 km-wide flooded volcanic crater — is arguably the most spectacular natural setting of any inhabited place on Earth. The island\'s signature whitewashed Cycladic architecture cascades down steep cliffsides to blue-domed churches perched above the deep cobalt Aegean. The sunset over Oia\'s windmills, watched from hundreds of clifftop terraces, is a moment that stops time.',
    latitude: 36.3932,
    longitude: 25.4615,
    continent: 'Europe',
    timezone: 'UTC+2 (EET)',
    imageUrl:
        'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1533105079780-92b9be482077?w=800',
      'https://images.unsplash.com/photo-1601581875039-e899893d520c?w=800',
      'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=800',
    ],
    rating: 4.9,
    language: 'Greek',
    currency: 'Euro (€)',
    bestTime: 'April–May · September–October (fewer crowds, mild weather)',
    weather:
        'Mediterranean. Hot dry summers (28–35 °C); mild, wetter winters. 300+ sunny days/year.',
    highlights: [
      'Oia sunset — clifftop village famous for the world\'s most photographed sunset',
      'Caldera boat tour — sail around the volcanic crater, hot springs, and Thirassia island',
      'Akrotiri ruins — Bronze Age city buried by the eruption, often called the "Minoan Pompeii"',
      'Red Beach & Black Beach — dramatic volcanic sand beaches unlike anywhere else',
      'Assyrtiko wine tasting — sample the island\'s unique volcanic-soil white wine',
    ],
    travelTip:
        'Stay in Imerovigli rather than overcrowded Oia for equally stunning caldera views, lower prices, and a quieter atmosphere while still being 20 minutes\' walk from Oia.',
  ),
  DestinationModel(
    id: '12',
    name: 'Colosseum',
    country: 'Rome, Italy',
    description:
        'The Flavian Amphitheatre — known to the world as the Colosseum — is the largest amphitheatre ever constructed and the most iconic symbol of ancient Rome\'s engineering genius. Completed in 80 CE, its elliptical arena once held between 50,000 and 80,000 spectators who gathered for gladiatorial contests, animal hunts, public executions, and mock sea battles. Its sophisticated system of ramps, lifts, and trapdoors allowed dramatic stagecraft. Two millennia later, it remains one of humanity\'s greatest architectural achievements.',
    latitude: 41.8902,
    longitude: 12.4922,
    continent: 'Europe',
    timezone: 'UTC+1 (CET)',
    imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=800',
      'https://images.unsplash.com/photo-1490642914619-7955a3fd483c?w=800',
      'https://img.freepik.com/premium-photo/coliseum-rome-beautiful-night-full-view-italy_400112-980.jpg',
    ],
    rating: 4.8,
    language: 'Italian',
    currency: 'Euro (€)',
    bestTime: 'April–June · September–October',
    weather:
        'Mediterranean. Hot dry summers (30–35 °C); mild rainy winters; glorious spring and autumn.',
    highlights: [
      'Arena Floor Access — walk where gladiators once fought in the reconstructed arena',
      'Underground hypogeum — explore the labyrinthine tunnels beneath the arena floor',
      'Roman Forum — adjacent ruins of temples, arches, and ancient Roman civic life',
      'Palatine Hill — the birthplace of Rome with palaces of emperors and sweeping views',
      'Night visit — the illuminated Colosseum under stars is profoundly atmospheric',
    ],
    travelTip:
        'Book the combined Colosseum + Roman Forum + Palatine Hill ticket online — queues at the door can exceed 2 hours. Arrive at opening time or 2 hours before closing.',
  ),
  DestinationModel(
    id: '13',
    name: 'Northern Lights',
    country: 'Tromsø, Norway',
    description:
        'Above the Arctic Circle in northern Norway, Tromsø is one of the world\'s most reliable destinations to witness the aurora borealis — nature\'s most breathtaking light show. Curtains of neon green, violet, and pink light dance across the sky on dark winter nights, reflected in snow-covered fjords. By day, explore Norwegian Arctic culture with dog sledding through spruce forests, reindeer feeding with Sami people, or whale watching in icy fjords. The experience of standing in absolute silence beneath the aurora is transformational.',
    latitude: 69.6492,
    longitude: 18.9553,
    continent: 'Europe',
    timezone: 'UTC+1 (CET)',
    imageUrl:
        'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1483347756197-71ef80e95f73?w=800',
      'https://journeywoman.com/wp-content/uploads/2021/06/APisani7082-scaled.jpg',
      'https://images.unsplash.com/photo-1520769945061-0a448c463865?w=800',
    ],
    rating: 4.9,
    language: 'Norwegian',
    currency: 'Norwegian Krone (NOK)',
    bestTime: 'September–March (polar night for auroras)',
    weather:
        'Subarctic. Cold dark winters (−5 to −15 °C); mild summers with Midnight Sun phenomenon.',
    highlights: [
      'Aurora borealis — best seen Sep–Mar from dark rural areas away from city lights',
      'Dog sledding — mush across snowy tundra through reindeer forests',
      'Whale watching — orcas and humpback whales feed in fjords Nov–Jan',
      'Midnight Sun (June) — sun stays above horizon for 2 months, enabling 24-hr hiking',
      'Tromsø Cathedral and Arctic Cathedral — striking modern and historic churches',
    ],
    travelTip:
        'Book an aurora chase tour with a local guide — they track cloud cover and drive to clearer skies outside the city. This dramatically increases your chance of a sighting.',
  ),

  // ── AFRICA ─────────────────────────────────────────────────────────────────
  DestinationModel(
    id: '14',
    name: 'Pyramids of Giza',
    country: 'Giza, Egypt',
    description:
        'The last surviving Wonder of the Ancient World, the Great Pyramid of Khufu was the tallest man-made structure on Earth for 3,800 years. Built around 2560 BCE using an estimated 2.3 million limestone blocks weighing up to 80 tonnes, the precision of its construction — with sides aligned to true north within 1/20th of a degree — continues to astonish engineers and archaeologists today. The adjacent Great Sphinx, at 73 m long and 20 m high, is the world\'s largest monolithic sculpture, guarding the plateau for over 4,500 years.',
    latitude: 29.9792,
    longitude: 31.1342,
    continent: 'Africa',
    timezone: 'UTC+2 (EET)',
    imageUrl:
        'https://images.unsplash.com/photo-1539650116574-8efeb43e2750?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=800',
      'https://images.unsplash.com/photo-1553913861-c0fddf2619ee?w=800',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRCaQgrZsifGcaMRwa3V5kpZQS4ItyfrYTs_Q&s',
    ],
    rating: 4.9,
    language: 'Arabic',
    currency: 'Egyptian Pound (EGP)',
    bestTime: 'October–April (cooler temperatures)',
    weather:
        'Hot desert. Extreme summers (40 °C+); mild, dry winters (10–20 °C). Minimal rainfall.',
    highlights: [
      'Great Pyramid of Khufu — enter the narrow passages leading to the king\'s burial chamber',
      'Great Sphinx — stand face-to-face with the mythical guardian of the Giza plateau',
      'Pyramid of Khafre — nearly as large as the Great Pyramid with intact limestone casing at the top',
      'Sound & Light Show — nightly narrated spectacle illuminating the plateau',
      'Solar Boat Museum — ancient cedarwood boat entombed beside the Great Pyramid for 4,500 years',
    ],
    travelTip:
        'Hire an official guide from inside the gate, not outside. They provide fascinating context and protect you from the many persistent unofficial vendors on the plateau.',
  ),
  DestinationModel(
    id: '15',
    name: 'Serengeti',
    country: 'Serengeti, Tanzania',
    description:
        'Home to the greatest wildlife spectacle on Earth, the Serengeti ecosystem stretches across 30,000 km² of endless golden savannah in northern Tanzania. Every year, over 1.5 million wildebeest and 250,000 zebra undertake the Great Migration — a circular 2,900 km journey following rainfall and grass — battling crocodile-infested river crossings that are among nature\'s most dramatic events. Beyond the migration, the Serengeti harbours Africa\'s densest population of lions and offers virtually guaranteed big-five sightings year-round.',
    latitude: -2.3333,
    longitude: 34.8333,
    continent: 'Africa',
    timezone: 'UTC+3 (EAT)',
    imageUrl: 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
    imageUrls: [
      'https://www.beautifulworld.com/wp-content/uploads/2016/10/zebras-serengeti-national-park.jpg.webp',
      'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/06/b4/80/99/serengeti.jpg?w=500&h=400&s=1',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwS_mJciyla8VG79oNCihJcCAgvvYOiKGbhQ&s',
    ],
    rating: 4.9,
    language: 'Swahili / English',
    currency: 'Tanzanian Shilling (TZS) / USD accepted',
    bestTime:
        'July–September (river crossings) · Dec–March (calving season, predator action)',
    weather:
        'Tropical savannah. Dry season June–Oct; short rains Nov; long rains March–May.',
    highlights: [
      'Great Migration — witness the thundering wildebeest river crossings at Mara River',
      'Hot air balloon safari — drift over the plains at sunrise watching predators hunt',
      'Big Five game drives — lion, leopard, elephant, buffalo, and rhino',
      'Ngorongoro Crater — a collapsed volcanic caldera with 25,000 wild animals inside',
      'Maasai village visit — experience the culture of East Africa\'s most iconic people',
    ],
    travelTip:
        'Travel in a smaller 4x4 vehicle rather than a large van — you\'ll be quieter, more manoeuvrable, and able to approach wildlife closer without disturbing them.',
  ),
  DestinationModel(
    id: '16',
    name: 'Cape Town',
    country: 'Cape Town, South Africa',
    description:
        'Draped between the iconic flat-topped Table Mountain and the meeting of the Atlantic and Indian Oceans, Cape Town is consistently ranked among the world\'s most beautiful cities. Its extraordinary natural setting — dramatic cliffs, pristine beaches, verdant wine valleys, and the flower-covered Cape Peninsula — is matched by a vibrant cultural scene born from the collision of African, European, Malay, and Asian influences. The city\'s complex history, from Dutch colonial rule to apartheid and freedom, adds profound depth to every visit.',
    latitude: -33.9249,
    longitude: 18.4241,
    continent: 'Africa',
    timezone: 'UTC+2 (SAST)',
    imageUrl:
        'https://images.unsplash.com/photo-1580060839134-75a5edca2e99?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1576485375217-d6a95e34d043?w=800',
      'https://www.goodthingsguy.com/wp-content/uploads/2018/07/bay-boats-cape-town-pexels.jpg',
      'https://urbansafaris.co.za/wp-content/uploads/2025/07/capetown-waterfront-500x500.png',
    ],
    rating: 4.8,
    language: 'Afrikaans / English / Xhosa',
    currency: 'South African Rand (ZAR)',
    bestTime: 'November–March (warm, dry Southern Hemisphere summer)',
    weather:
        'Mediterranean. Dry sunny summers (25–30 °C); cool rainy winters. Wind can be strong.',
    highlights: [
      'Table Mountain — cable car or 3-hour hike to a 1,086 m flat-topped plateau with 360° views',
      'Cape of Good Hope — dramatic cliffs at the southwestern tip of Africa',
      'Boulders Beach — swim alongside a colony of 3,000 endangered African penguins',
      'Robben Island — UNESCO site where Nelson Mandela was imprisoned for 18 years',
      'Franschhoek Wine Valley — world-class Pinot Noir and Cape Malay cuisine',
    ],
    travelTip:
        'Book Table Mountain cable car tickets online first thing in the morning — the mountain is famously cloud-covered ("tablecloth") in the afternoon and the car closes in strong winds.',
  ),

  // ── NORTH AMERICA ──────────────────────────────────────────────────────────
  DestinationModel(
    id: '17',
    name: 'Grand Canyon',
    country: 'Arizona, USA',
    description:
        'Carved over 5 to 6 million years by the Colorado River through the Colorado Plateau, the Grand Canyon stretches 446 km long, up to 29 km wide, and plunges 1,857 m deep. Its layered bands of red, orange, and purple rock — revealed in horizontal bands of limestone, sandstone, and shale — represent almost two billion years of geological history, exposing some of the oldest exposed rock on Earth\'s surface. Standing at the rim and looking into its incomprehensible immensity triggers a profoundly humbling sense of geological time and scale.',
    latitude: 36.1069,
    longitude: -112.1129,
    continent: 'North America',
    timezone: 'UTC-7 (MST)',
    imageUrl:
        'https://images.unsplash.com/photo-1474044159687-1ee9f3a51722?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1615551043360-33de8b5f410c?w=800',
      'https://graylinelasvegas.com/wp-content/uploads/2023/02/havasu-falls-in-arizona.jpg',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTuvH32JQ65XfoQd2cFPrAlruP3Bjp_iA5Ulw&s',
    ],
    rating: 4.9,
    language: 'English',
    currency: 'US Dollar (USD)',
    bestTime:
        'March–May · September–November (avoid summer heat at the bottom)',
    weather:
        'Varies dramatically by altitude. Rim: mild summers (25 °C), cold winters with snow. Inner canyon: extreme heat (over 40 °C) in summer.',
    highlights: [
      'South Rim viewpoints — Mather Point, Yavapai Point for iconic panoramic views',
      'Bright Angel Trail — most popular rim-to-river hike descending 1,400 m',
      'Colorado River rafting — multi-day expeditions through the canyon\'s white-water rapids',
      'Skywalk (West Rim) — glass-bottomed bridge extending 21 m over the canyon',
      'Phantom Ranch — historic lodge at the canyon bottom, accessible only by mule or foot',
    ],
    travelTip:
        'Never hike to the river and back in one day in summer — the combination of extreme heat, steep ascent, and limited water sources has led to many rescues and fatalities. Start before dawn, turn around by midday.',
  ),
  DestinationModel(
    id: '18',
    name: 'New York City',
    country: 'New York, USA',
    description:
        'The city that never sleeps is the world\'s most iconic metropolis — a global capital of finance, fashion, culture, media, food, and art that has set the template for urban life worldwide. From the neon overload of Times Square and the meditative calm of Central Park to the world-class collections of the MET and MoMA, the immigrant-forged neighbourhoods of Brooklyn and Queens, and the Statue of Liberty watching over the harbour, New York rewards infinite exploration. Few cities deliver the same electric charge of feeling alive at the centre of the world.',
    latitude: 40.7128,
    longitude: -74.0060,
    continent: 'North America',
    timezone: 'UTC-5 (EST)',
    imageUrl:
        'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=800',
      'https://images.unsplash.com/photo-1522083165195-3424ed129620?w=800',
      'https://images.unsplash.com/photo-1485871981521-5b1fd3805eee?w=800',
    ],
    rating: 4.8,
    language: 'English (100+ languages spoken)',
    currency: 'US Dollar (USD)',
    bestTime: 'April–June · September–November',
    weather:
        'Humid continental. Hot humid summers (30 °C+); cold winters with snowfall; beautiful spring and autumn.',
    highlights: [
      'Central Park — 340-hectare green oasis at the heart of Manhattan',
      'Empire State Building — 443 m art-deco tower with observation decks on floors 86 and 102',
      'Metropolitan Museum of Art — 5,000 years of art across 17 departments',
      'Brooklyn Bridge Walk — 1.8 km pedestrian crossing with sweeping Manhattan skyline views',
      'Statue of Liberty & Ellis Island — the gateway to America and monument to freedom',
    ],
    travelTip:
        'The NYC Subway runs 24/7 — it\'s the fastest and cheapest way to get around. Buy a 7-day unlimited MetroCard (\$34) if you\'re staying a week. Avoid yellow cabs in midday Manhattan gridlock.',
  ),
  DestinationModel(
    id: '19',
    name: 'Banff National Park',
    country: 'Alberta, Canada',
    description:
        'Established in 1885 as Canada\'s first national park, Banff is a crown jewel of the Canadian Rocky Mountains — a UNESCO World Heritage wilderness of glaciated peaks, ancient icefields, and some of the world\'s most photogenic lakes. Glacier-fed Lake Louise shimmers an impossibly vivid turquoise beneath Victoria Glacier, while Moraine Lake\'s Valley of the Ten Peaks appears so stunning it once graced Canada\'s \$20 banknote. The Icefields Parkway — a 230 km drive through the Rockies — is widely considered the world\'s most scenic road.',
    latitude: 51.4968,
    longitude: -115.9281,
    continent: 'North America',
    timezone: 'UTC-7 (MST)',
    imageUrl: 'https://images.unsplash.com/photo-1503614472-8c93d56e92ce?w=800',
    imageUrls: [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSF5SD9HNb0bvlwotOzZYGdxKzy-agj-tEe6g&s',
      'https://images.unsplash.com/photo-1561134643-668f9057cce4?w=800',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ8nHQTEPxp8E4Juj5EcsZmeycsyME4jrq11w&s',
    ],
    rating: 4.9,
    language: 'English / French',
    currency: 'Canadian Dollar (CAD)',
    bestTime: 'June–August (hiking) · December–March (skiing)',
    weather:
        'Mountain climate. Warm short summers (15–25 °C); cold, snowy winters (−20 °C or lower).',
    highlights: [
      'Lake Louise — turquoise glacier lake framed by peaks; canoe hire available',
      'Moraine Lake — Valley of the Ten Peaks, one of the world\'s most photographed landscapes',
      'Icefields Parkway — 230 km drive past glaciers, waterfalls, and wildlife',
      'Athabasca Glacier — walk or ride a snowcoach onto the Columbia Icefield',
      'Banff Upper Hot Springs — natural thermal pools at 1,585 m elevation',
    ],
    travelTip:
        'Moraine Lake Road opens mid-June and closes mid-October. A reservation system now controls car access — book your parking pass months in advance or take the shuttle from Lake Louise Park-and-Ride.',
  ),

  // ── SOUTH AMERICA ──────────────────────────────────────────────────────────
  DestinationModel(
    id: '20',
    name: 'Machu Picchu',
    country: 'Cusco, Peru',
    description:
        'An ancient Incan citadel perched 2,430 m above sea level on a ridge above the Sacred Valley of the Urubamba River in the Peruvian Andes. Built around 1450 CE and abandoned less than a century later during the Spanish conquest, Machu Picchu lay forgotten by the outside world until 1911, when American historian Hiram Bingham brought it to international attention. Its precisely fitted dry-stone walls, agricultural terraces, temples, and plazas demonstrate the Inca Empire\'s extraordinary engineering, astronomical knowledge, and reverence for their mountain environment.',
    latitude: -13.1631,
    longitude: -72.5450,
    continent: 'South America',
    timezone: 'UTC-5 (PET)',
    imageUrl:
        'https://images.unsplash.com/photo-1526392060635-9d6019884377?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1587595431973-160d0d94add1?w=800',
      'https://images.unsplash.com/photo-1580619305218-8423a7ef79b4?w=800',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1UAxk-bhAJ3cHo21ixyFyYLyYvUWNXb4_Gw&s',
    ],
    rating: 4.9,
    language: 'Spanish / Quechua',
    currency: 'Peruvian Sol (PEN)',
    bestTime: 'April–October (dry season)',
    weather:
        'Highland subtropical. Dry season May–Oct (cool, clear); wet season Nov–Apr (mist adds atmosphere but trails can be slippery).',
    highlights: [
      'Sun Gate (Inti Punku) — ancient entrance to Machu Picchu on the Inca Trail with sweeping first views',
      'Temple of the Sun — semicircular tower aligned with the June solstice sunrise',
      'Huayna Picchu Mountain — steep 45-minute climb to the peak towering above the citadel',
      'Inca Trail — 4-day, 43 km classic trek through cloud forest and mountain passes',
      'Llamas at the ruins — resident llamas graze freely among the ancient stones',
    ],
    travelTip:
        'Daily visitor numbers are strictly capped. Book tickets through the official Peruvian Ministry of Culture website weeks or even months in advance — third-party resellers charge 2–3× the price.',
  ),
  DestinationModel(
    id: '21',
    name: 'Rio de Janeiro',
    country: 'Rio de Janeiro, Brazil',
    description:
        'Blessed with one of the world\'s most dramatic natural settings, Rio de Janeiro — the Marvellous City — sprawls between Atlantic beaches and jungle-covered granite mountains. The 38 m Christ the Redeemer statue atop Corcovado Mountain watches over Guanabara Bay with arms outstretched in the most iconic image in South America. Rio\'s Carnival — 5 days of the world\'s greatest street party — draws millions, but the city rewards year-round with its legendary beaches, vibrant samba culture, world-class street food, and a joyful, music-soaked way of life.',
    latitude: -22.9068,
    longitude: -43.1729,
    continent: 'South America',
    timezone: 'UTC-3 (BRT)',
    imageUrl:
        'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?w=800',
    imageUrls: [
      'https://i0.wp.com/www.rioculturalsecrets.com/wp-content/uploads/2025/05/davi-costa-VtecdSFlXsI-unsplash-most-romantic-places-rio-de-janeiro.jpg',
      'https://images.unsplash.com/photo-1516306580123-e6e52b1b7b5f?w=800',
      'https://a.travel-assets.com/findyours-php/viewfinder/images/res40/110000/110748.jpg',
    ],
    rating: 4.8,
    language: 'Portuguese',
    currency: 'Brazilian Real (BRL)',
    bestTime:
        'December–March (Carnival season) · June–September (cooler, less humid)',
    weather:
        'Tropical. Hot humid summers (28–40 °C) with heavy afternoon rain; mild, drier winters (20–25 °C).',
    highlights: [
      'Christ the Redeemer — cog-railway ascent to the 38 m Art Deco statue atop Corcovado',
      'Sugarloaf Mountain (Pão de Açúcar) — cable car ride to 396 m peak over Guanabara Bay',
      'Copacabana & Ipanema Beaches — iconic 6 km of golden sand with legendary beach culture',
      'Santa Teresa neighbourhood — bohemian hilltop enclave of colonial architecture and art studios',
      'Carnival (February/March) — world\'s largest street party with 2 million people daily',
    ],
    travelTip:
        'Leave expensive jewellery and watches at the hotel. Use hotel safes for passports and valuables. Be aware of your surroundings in tourist areas and prefer app-based taxis like Uber over street taxis.',
  ),
  DestinationModel(
    id: '22',
    name: 'Patagonia',
    country: 'Santa Cruz, Argentina',
    description:
        'At the southern tip of South America, Patagonia is one of the last great wildernesses on Earth — a region of staggering scale where Andean glaciers calve into milky lakes, condors soar over wind-sculpted steppes, and the jagged granite towers of the Fitz Roy and Torres del Paine massifs pierce the sky. Covering over a million square kilometres across Argentina and Chile, it is a paradise for trekkers, mountaineers, and photographers. The iconic "W Trek" in Torres del Paine National Park is consistently rated among the world\'s finest multi-day trails.',
    latitude: -50.9423,
    longitude: -73.4068,
    continent: 'South America',
    timezone: 'UTC-3 (ART)',
    imageUrl:
        'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800',
    imageUrls: [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRy0aUKAr5CjRQxiCYBx4KvrLHhn5TFTOH85g&s',
      'https://images.unsplash.com/photo-1531761535209-180857e963b9?w=800',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbAJgjRxt6oZcjse8319gUQJuIE-XW-pWbOQ&s',
    ],
    rating: 4.8,
    language: 'Spanish',
    currency: 'Argentine Peso (ARS) / Chilean Peso (CLP)',
    bestTime: 'November–March (Southern Hemisphere summer)',
    weather:
        'Cold, windy, and unpredictable year-round. Strong winds are constant. Expect all four seasons in one day.',
    highlights: [
      'Torres del Paine "W Trek" — 4–5 day iconic trail beneath the granite towers',
      'Perito Moreno Glacier — massive advancing glacier with constant thundering calving events',
      'Fitz Roy massif — photographer\'s dream mountain near El Chaltén village',
      'Kayaking among glaciers — paddle between icebergs in Lake Grey or Lago del Toro',
      'Pumas and guanacos — one of the best places on Earth to observe wild pumas',
    ],
    travelTip:
        'Book campsites and refugios in Torres del Paine National Park months in advance — the "W Trek" campsites sell out completely. Carry waterproof layers whatever the forecast.',
  ),

  // ── OCEANIA ────────────────────────────────────────────────────────────────
  DestinationModel(
    id: '23',
    name: 'Sydney Opera House',
    country: 'Sydney, Australia',
    description:
        'Jørn Utzon\'s masterpiece of 20th-century architecture is the defining symbol of Australia. Its soaring white precast-concrete shells — inspired by the interlocking geometry of an orange — rise from Bennelong Point as if unfurling into Sydney Harbour\'s sparkling waters, framed by the Harbour Bridge\'s steel arch. Completed in 1973 after 14 years of construction, the Opera House is now a UNESCO World Heritage Site. Beyond its iconic exterior, it is a world-class performing arts venue hosting over 1,700 events and 1.2 million attendees annually.',
    latitude: -33.8568,
    longitude: 151.2153,
    continent: 'Oceania',
    timezone: 'UTC+11 (AEDT)',
    imageUrl:
        'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1524293581917-878a6d017c71?w=800',
      'https://images.unsplash.com/photo-1545044846-351ba102b6d5?w=800',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLKLA-wiji0KE-vI9OEBMkoGvbKbc8i63Nyg&s',
    ],
    rating: 4.8,
    language: 'English',
    currency: 'Australian Dollar (AUD)',
    bestTime: 'September–November · March–May (mild, less crowded)',
    weather:
        'Oceanic. Warm summers (28 °C); mild winters (12–18 °C). Rain spread through the year.',
    highlights: [
      'Guided backstage tour — go behind the shells and into the concert halls',
      'Opera or concert performance — experience the building as it was intended',
      'Circular Quay — harbour promenade walk between the Opera House and Harbour Bridge',
      'BridgeClimb — 3.5 hour climb to the top of the Sydney Harbour Bridge arch',
      'Bondi Beach — Sydney\'s legendary surfing beach 8 km from the city',
    ],
    travelTip:
        'Walk across the Harbour Bridge and climb to the pylon lookout (free on the southeastern pylon) for an unbeatable view of the Opera House against the harbour — a better angle than any ground-level photo.',
  ),
  DestinationModel(
    id: '24',
    name: 'Great Barrier Reef',
    country: 'Queensland, Australia',
    description:
        'The world\'s largest coral reef system, the Great Barrier Reef stretches 2,300 km along the northeastern coast of Australia and is large enough to be seen from space. This UNESCO World Heritage Site and one of the Seven Natural Wonders of the World comprises over 2,900 individual reefs and 900 islands, sheltering extraordinary marine biodiversity: 1,500 species of fish, 4,000 types of mollusk, 240 species of birds, and six of the world\'s seven marine turtle species. It is both one of the most spectacular places on Earth and one of the most urgently threatened.',
    latitude: -18.2871,
    longitude: 147.6992,
    continent: 'Oceania',
    timezone: 'UTC+10 (AEST)',
    imageUrl:
        'https://cdn.sightseeingtoursaustralia.com.au/wp-content/uploads/2019/10/best-places-to-see-the-reef-Whitsundays.png',
    imageUrls: [
      'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSjjRjUM7mcYXpcA5yR-vuwmUjdLNmLhXMM4Q&s',
      'https://preview.redd.it/the-great-barrier-reef-really-is-1-of-the-most-beautiful-v0-m6ti3ieby7b41.jpg?width=640&crop=smart&auto=webp&s=e96c98da7f6788c32d1f21cf7435249e9d985625',
    ],
    rating: 4.9,
    language: 'English',
    currency: 'Australian Dollar (AUD)',
    bestTime: 'June–October (cooler, clearer water; reduced jellyfish)',
    weather:
        'Tropical. Warm (24–30 °C) year-round. Stinger (jellyfish) season Nov–May in shallow water.',
    highlights: [
      'Scuba diving & snorkelling — swim among colourful coral gardens and marine life',
      'Outer Reef day trips from Cairns — fastest access to pristine reef sections',
      'Whitsunday Islands — 74 islands with Whitehaven Beach, one of the world\'s finest',
      'Lady Elliot Island — eco-resort on a coral cay with manta ray cleaning stations',
      'Coral Sea flyover — scenic helicopter flight showing the reef\'s full breathtaking scale',
    ],
    travelTip:
        'Choose reef operators certified by "High Standard Tourism Operators" — they invest in reef protection. Wear reef-safe sunscreen (no oxybenzone or octinoxate) to protect the corals.',
  ),
  DestinationModel(
    id: '25',
    name: 'Milford Sound',
    country: 'Southland, New Zealand',
    description:
        'Rudyard Kipling famously called Milford Sound the eighth wonder of the world — a hyperbole that visitors consistently find entirely justified. This dramatic fiord in Fiordland National Park was carved during the last ice age by glaciers that gouged deep U-shaped valleys, now flooded by the Tasman Sea. Sheer rock walls rise 1,200 m from jet-black mirror waters; waterfalls cascade year-round from hanging valleys overhead; bottlenose dolphins, fur seals, and penguins inhabit its sheltered waters. Mitre Peak — a perfect pyramidal mountain rising 1,692 m straight from the fiord — is New Zealand\'s most photographed landmark.',
    latitude: -44.6414,
    longitude: 167.8974,
    continent: 'Oceania',
    timezone: 'UTC+13 (NZDT)',
    imageUrl:
        'https://www.luxurygold.com/lg/wp-content/uploads/2022/05/Large-The-Milford-Sound-fiord-Fiordland-national-park-New-Zealand-991837920.jpg',
    imageUrls: [
      'https://images.unsplash.com/photo-1469521669194-babb45599def?w=800',
      'https://images.unsplash.com/photo-1508193638397-1c4234db14d8?w=800',
      'https://images.unsplash.com/photo-1519659528534-7fd733a832a0?w=800',
    ],
    rating: 4.9,
    language: 'English / Māori',
    currency: 'New Zealand Dollar (NZD)',
    bestTime:
        'October–April (accessible roads; waterfalls most dramatic Dec–March after rain)',
    weather:
        'One of the world\'s wettest places — 6,000–8,000 mm/year. Rain creates hundreds of temporary waterfalls. Bring waterproofs regardless of season.',
    highlights: [
      'Scenic cruise — 2-hour boat journey beneath sheer cliffs and cascading waterfalls',
      'Kayaking the fiord — paddle at water level surrounded by towering rock faces',
      'Mitre Peak — the iconic pyramid rising 1,692 m directly from the water',
      'Stirling and Lady Bowen Falls — permanent waterfalls plunging 155 m and 162 m',
      'Overnight cruise — stay aboard a small vessel to experience the fiord at dawn',
    ],
    travelTip:
        'Rainy days at Milford Sound are often the most dramatic — rain triggers hundreds of extra waterfalls cascading down every cliff face, creating a truly otherworldly scene.',
  ),

  // ── ADDITIONAL HIGHLIGHTS ──────────────────────────────────────────────────
  DestinationModel(
    id: '26',
    name: 'Amalfi Coast',
    country: 'Campania, Italy',
    description:
        'A 50 km stretch of UNESCO-listed coastline where pastel-coloured fishing villages cling precariously to near-vertical cliffs above the turquoise Tyrrhenian Sea. Positano\'s cascade of pink and white houses, Ravello\'s clifftop gardens, and the ancient republic town of Amalfi define one of the most visually arresting landscapes in Europe. Lemon groves scent the air; handmade limoncello fills shop shelves; and the winding SS163 corniche road offers jaw-dropping views at every blind corner.',
    latitude: 40.6333,
    longitude: 14.6029,
    continent: 'Europe',
    timezone: 'UTC+1 (CET)',
    imageUrl:
        'https://ucarecdn.com/cf289f72-3f35-47c8-ac93-190132947f25~5/nth/1/-/stretch/off/-/resize/1110x/',
    imageUrls: [
      'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=800',
      'https://images.unsplash.com/photo-1523906834658-6e24ef2386f9?w=800',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfNGmY2tKzZSOIndAkSKvxAL54o-K07CbzTQ&s',
    ],
    rating: 4.8,
    language: 'Italian',
    currency: 'Euro (€)',
    bestTime: 'May–June · September–October (cooler, quieter)',
    weather:
        'Mediterranean. Hot, dry summers (30 °C+); mild, wetter winters. Spring and autumn are ideal.',
    highlights: [
      'Positano — pastel-hued vertical village spilling down a cliff to a small pebble beach',
      'Path of the Gods — cliff-edge hiking trail connecting Agerola to Nocelle with breathtaking views',
      'Ravello — mountaintop town with Villa Rufolo gardens and world-class classical music festival',
      'Amalfi town — 9th-century Republic with a magnificent Arab-Norman cathedral',
      'Boat trip along the coast — the only way to appreciate the sheer scale of the cliffs',
    ],
    travelTip:
        'Avoid driving the Amalfi Coast road in July–August — traffic jams can last hours on the narrow corniche. Use the ferry service between villages or take the SITA bus for a more relaxing (and equally scenic) experience.',
  ),
  DestinationModel(
    id: '27',
    name: 'Angkor Wat',
    country: 'Siem Reap, Cambodia',
    description:
        'The world\'s largest religious monument, Angkor Wat was built in the early 12th century by King Suryavarman II as a Hindu state temple and eventual mausoleum, before being converted to Buddhism in the late 13th century. At its peak, the Khmer Empire\'s capital of Angkor was the world\'s largest pre-industrial city, home to nearly 1 million people — and the temple complex required 300,000 workers and 6,000 elephants to construct. The 72 km² Angkor Archaeological Park now encompasses dozens of temple complexes, from the iconic five-towered Angkor Wat to the enigmatic face-towers of Bayon and the jungle-swallowed splendour of Ta Prohm.',
    latitude: 13.4125,
    longitude: 103.8670,
    continent: 'Southeast Asia',
    timezone: 'UTC+7 (ICT)',
    imageUrl:
        'https://www.expeditions.com/_next/image?url=https%3A%2F%2Fimages.ctfassets.net%2Fb4bpxrz16gb9%2Fcbff8d609d48420c94b9065204287d09%2F5320b8a808437aebbd0e52d755640a7c%2Fangkor-wat-main.jpg&w=3840&q=75',
    imageUrls: [
      'https://vj-prod-website-cms.s3.ap-southeast-1.amazonaws.com/depositphotos145162307xl-1714098248574.jpg',
      'https://res.klook.com/images/fl_lossy.progressive,q_65/c_fill,w_1295,h_971/w_80,x_15,y_15,g_south_west,l_Klook_water_br_trans_yhcmh3/activities/vyfecl6vuxmvlrrlirog/SiemReap:Tour2Ng%C3%A0yAngkorWatNg%E1%BA%AFmB%C3%ACnhMinhv%C3%A0Ho%C3%A0ngH%C3%B4n.jpg',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzkYrN-w0NfnteH2sZK7uLhkPAAqOGvEHgig&s',
    ],
    rating: 4.8,
    language: 'Khmer',
    currency: 'US Dollar (USD) / Cambodian Riel (KHR)',
    bestTime: 'November–February (cool dry season)',
    weather:
        'Tropical monsoon. Hot and dry Nov–April (25–35 °C); rainy season May–October (lush and greener).',
    highlights: [
      'Angkor Wat sunrise — watch the towers turn gold as the sun rises behind them over the reflection pool',
      'Bayon Temple — 54 towers adorned with 216 serene stone faces of Avalokitesvara',
      'Ta Prohm — ancient temple embraced by enormous strangler figs and silk-cotton trees',
      'Elephant Terrace — 350 m bas-relief wall depicting royal ceremonies and epic battles',
      'Hot air balloon at sunset — drift over the canopy for panoramic views of the entire complex',
    ],
    travelTip:
        'Buy a 3-day pass (\$62) rather than a 1-day pass (\$37) — the complex is vast and you\'ll only scratch the surface in one day. Start at different temples each day to beat the tour groups.',
  ),
  DestinationModel(
    id: '28',
    name: 'Sahara Desert',
    country: 'Merzouga, Morocco',
    description:
        'The world\'s largest hot desert covers 9.2 million km² across 11 countries — roughly the same size as the contiguous United States. The Erg Chebbi dunes near Merzouga in southeastern Morocco rise to 150 m and represent the archetypal Sahara landscape of rolling golden sea-sand sculpted by wind. Riding camels to a Berber camp at sunset, watching the stars in the world\'s darkest skies, and waking to the silence of a sunrise over an ocean of sand is an experience that strips away the noise of modern life and connects you to something ancient and elemental.',
    latitude: 31.0981,
    longitude: -4.0134,
    continent: 'Africa',
    timezone: 'UTC+1 (WET)',
    imageUrl:
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800',
    imageUrls: [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQ8YHj2qckzjNUUvF4Tojc5y2wcgrhwgKjaw&s',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQP9d12vjbjkLqI6VpK7L_0Zn5G2NoAWjazCA&s',
      'https://i0.wp.com/findingerlebnisse.com/wp-content/uploads/2022/10/IMG_9946-2.jpg?fit=1024%2C683&ssl=1',
    ],
    rating: 4.7,
    language: 'Arabic / Berber (Tamazight)',
    currency: 'Moroccan Dirham (MAD)',
    bestTime: 'October–April (bearable temperatures; summers exceed 50 °C)',
    weather:
        'Hot desert. Extreme heat in summer (45–55 °C); cold desert nights in winter (near 0 °C).',
    highlights: [
      'Camel trek at sunset — ride to a Berber desert camp as the dunes glow orange and red',
      'Overnight in Berber camp — sleep in a traditional haima tent under billions of stars',
      'Erg Chebbi dunes — climb 150 m sand dunes for panoramic desert views at sunrise',
      'Draa Valley — ancient caravan route lined with palmeries, kasbahs, and mud-brick villages',
      'Stargazing — among the world\'s darkest night skies, the Milky Way is visible to the naked eye',
    ],
    travelTip:
        'Wear a light-coloured, long-sleeved robe (available cheaply in Merzouga) — it protects from sun and blowing sand far better than Western clothing. Accept the tea; refusing Berber hospitality is considered rude.',
  ),
  DestinationModel(
    id: '29',
    name: 'Ha Long Bay',
    country: 'Quảng Ninh, Vietnam',
    description:
        'A UNESCO World Heritage Site of extraordinary mythological and geological significance, Ha Long Bay encompasses nearly 2,000 limestone karst islands and islets rising dramatically from the emerald Gulf of Tonkin in northeastern Vietnam. According to Vietnamese legend, the islands were formed when a dragon ("Ha Long" means Descending Dragon) lashed the waters with its tail, creating the karst peaks. In reality, they were shaped over millions of years by rainwater dissolving limestone — creating caves, arches, and floating fishing villages that exist nowhere else on Earth quite like this.',
    latitude: 20.9101,
    longitude: 107.1839,
    continent: 'Southeast Asia',
    timezone: 'UTC+7 (ICT)',
    imageUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_RUUEj17G1kinKcbXpVwFAtyRsAXI_TvzAw&s',
    imageUrls: [
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5ffBWrdBbOLO_EEut1pI7NIfjN6PwcGxdOQ&s',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQixw3BcQFpr2xYdQamQGyjSNpfDMa-EEUFDg&s',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQVMLsnzB0VENPzFsJ5poRK8iXPrIjbIhQMQA&s',
    ],
    rating: 4.8,
    language: 'Vietnamese',
    currency: 'Vietnamese Dong (VND)',
    bestTime: 'October–April (dry season with clearer skies)',
    weather:
        'Subtropical. Warm (15–25 °C) Oct–April; hot and humid (30 °C+) with possible typhoons May–Sept.',
    highlights: [
      'Overnight junk cruise — spend 2 nights aboard a traditional wooden junk boat at anchor',
      'Hang Sửng Sốt (Surprise Cave) — spectacular 10,000 m² cavern with dramatic stalactites',
      'Kayaking through sea caves — paddle through water caves into secluded hidden lagoons',
      'Floating fishing villages — visit communities that have lived on the water for generations',
      'Titov Island — climb to the summit for a panoramic view over thousands of karst islands',
    ],
    travelTip:
        'Choose a 2-night cruise rather than a day trip — the bay is enormous and you need time overnight when the tour boats have left to experience the silence and eerie mist at dawn.',
  ),
  DestinationModel(
    id: '30',
    name: 'Iceland',
    country: 'Reykjavik, Iceland',
    description:
        'The land of fire and ice sits astride the Mid-Atlantic Ridge where the Eurasian and North American tectonic plates meet and pull apart — making Iceland one of the most geologically active places on Earth. Erupting volcanoes, steaming geysers, boiling mud pools, black lava fields, ancient glaciers calving into icebergs, and thundering waterfalls coexist in a raw, otherworldly landscape that feels like the beginning of the world. In winter, the aurora borealis dances above; in summer, the Midnight Sun keeps the sky bright at midnight. No other country on Earth offers such concentrated geological drama.',
    latitude: 64.9631,
    longitude: -19.0208,
    continent: 'Europe',
    timezone: 'UTC+0 (GMT)',
    imageUrl:
        'https://images.unsplash.com/photo-1520769945061-0a448c463865?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1476610182048-b716b8518aae?w=800',
      'https://images.unsplash.com/photo-1548777123-e216912df7d8?w=800',
      'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
    ],
    rating: 4.9,
    language: 'Icelandic',
    currency: 'Icelandic Króna (ISK)',
    bestTime:
        'June–August (Midnight Sun, accessible highlands) · Sep–March (Northern Lights)',
    weather:
        'Subarctic oceanic. Cool summers (10–15 °C); cold, windy winters (−5 to 5 °C). Rapidly changeable — pack for all seasons.',
    highlights: [
      'Golden Circle — Þingvellir National Park, Geysir hot spring area, and Gullfoss waterfall',
      'Blue Lagoon — world-famous geothermal spa in a black lava field near Reykjavik',
      'Jökulsárlón Glacier Lagoon — float among icebergs calved from Vatnajökull glacier',
      'Landmannalaugar — otherworldly multicoloured rhyolite mountains and natural hot springs',
      'Northern Lights — Sep–Mar aurora hunting in countryside away from city light pollution',
    ],
    travelTip:
        'Rent a 4WD vehicle to explore Iceland\'s F-roads (highland interior tracks) — they are strictly off-limits to regular 2WD cars, and the interior holds the country\'s most dramatic scenery.',
  ),
];

/// Returns 7 random destinations for the home carousel (stable per session).
List<DestinationModel> get popularDestinations {
  final list = List<DestinationModel>.from(allDestinations)..shuffle();
  return list.take(7).toList();
}
