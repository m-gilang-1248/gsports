// Data Hierarki: Provinsi -> Kota/Kabupaten -> List Kecamatan
// Catatan: Ini adalah dataset parsial untuk keperluan UI/UX.
// Data kecamatan difokuskan pada area Jabodetabek dan kota besar.

const Map<String, Map<String, List<String>>> kIndonesianLocations = {
  "DKI Jakarta": {
    "Jakarta Selatan": [
      "Cilandak",
      "Jagakarsa",
      "Kebayoran Baru",
      "Kebayoran Lama",
      "Mampang Prapatan",
      "Pancoran",
      "Pasar Minggu",
      "Pesanggrahan",
      "Setiabudi",
      "Tebet"
    ],
    "Jakarta Pusat": [
      "Cempaka Putih",
      "Gambir",
      "Johar Baru",
      "Kemayoran",
      "Menteng",
      "Sawah Besar",
      "Senen",
      "Tanah Abang"
    ],
    "Jakarta Barat": [
      "Cengkareng",
      "Grogol Petamburan",
      "Taman Sari",
      "Tambora",
      "Kebon Jeruk",
      "Kalideres",
      "Palmerah",
      "Kembangan"
    ],
    "Jakarta Timur": [
      "Matraman",
      "Pulo Gadung",
      "Jatinegara",
      "Duren Sawit",
      "Kramat Jati",
      "Makasar",
      "Pasar Rebo",
      "Ciracas",
      "Cipayung",
      "Cakung"
    ],
    "Jakarta Utara": [
      "Cilincing",
      "Kelapa Gading",
      "Koja",
      "Pademangan",
      "Penjaringan",
      "Tanjung Priok"
    ],
  },
  "Jawa Barat": {
    "Kota Bandung": [
      "Andir",
      "Astana Anyar",
      "Antapani",
      "Arcamanik",
      "Babakan Ciparay",
      "Bandung Kidul",
      "Bandung Kulon",
      "Bandung Wetan",
      "Batununggal",
      "Bojongloa Kaler",
      "Buahbatu",
      "Cibeunying Kaler",
      "Cicendo",
      "Cidadap",
      "Cinambo",
      "Coblong",
      "Gedebage",
      "Kiaracondong",
      "Lengkong",
      "Mandalajati",
      "Panyileukan",
      "Rancasari",
      "Regol",
      "Sukajadi",
      "Sukasari",
      "Sumur Bandung",
      "Ujung Berung"
    ],
    "Kota Depok": [
      "Beji",
      "Bojongsari",
      "Cilodong",
      "Cimanggis",
      "Cinere",
      "Cipayung",
      "Limo",
      "Pancoran Mas",
      "Sawangan",
      "Sukmajaya",
      "Tapos"
    ],
    "Kota Bekasi": [
      "Bantar Gebang",
      "Bekasi Barat",
      "Bekasi Selatan",
      "Bekasi Timur",
      "Bekasi Utara",
      "Jatiasih",
      "Jatisampurna",
      "Medan Satria",
      "Mustika Jaya",
      "Pondok Gede",
      "Pondok Melati",
      "Rawalumbu"
    ],
    "Kota Bogor": [
      "Bogor Barat",
      "Bogor Selatan",
      "Bogor Tengah",
      "Bogor Timur",
      "Bogor Utara",
      "Tanah Sareal"
    ],
    "Kab. Bogor": [
      "Babakan Madang",
      "Bojonggede",
      "Ciawi",
      "Cibinong",
      "Cileungsi",
      "Ciomas",
      "Cisarua",
      "Citeureup",
      "Gunung Putri",
      "Jonggol",
      "Parung",
      "Sentul"
    ],
    "Kota Cimahi": ["Cimahi Selatan", "Cimahi Tengah", "Cimahi Utara"],
    "Kab. Bandung": ["Balleendah", "Banjaran", "Boongsoang", "Cileunyi", "Dayeuhkolot", "Margahayu", "Soreang"],
  },
  "Banten": {
    "Kota Tangerang Selatan": [
      "Ciputat",
      "Ciputat Timur",
      "Pamulang",
      "Pondok Aren",
      "Serpong",
      "Serpong Utara",
      "Setu"
    ],
    "Kota Tangerang": [
      "Batuceper",
      "Benda",
      "Cibodas",
      "Ciledug",
      "Condet",
      "Jatiuwung",
      "Karangtengah",
      "Karawaci",
      "Larangan",
      "Neglasari",
      "Periuk",
      "Pinang",
      "Tangerang"
    ],
    "Kab. Tangerang": [
      "Balaraja",
      "Cikupa",
      "Cisauk",
      "Kelapa Dua",
      "Kosambi",
      "Pasar Kemis",
      "Sepatan"
    ],
  },
  "Jawa Tengah": {
    "Kota Semarang": [
      "Banyumanik",
      "Candisari",
      "Gajahmungkur",
      "Gayamsari",
      "Genuk",
      "Gunungpati",
      "Mijen",
      "Ngaliyan",
      "Pedurungan",
      "Semarang Barat",
      "Semarang Selatan",
      "Semarang Tengah",
      "Semarang Timur",
      "Semarang Utara",
      "Tembalang",
      "Tugu"
    ],
    "Kota Surakarta (Solo)": [
      "Banjarsari",
      "Jebres",
      "Laweyan",
      "Pasar Kliwon",
      "Serengan"
    ],
    "Kota Yogyakarta": [
      "Danurejan",
      "Gedongtengen",
      "Gondokusuman",
      "Gondomanan",
      "Jetis",
      "Kotagede",
      "Kraton",
      "Mantrijeron",
      "Mergangsan",
      "Ngampilan",
      "Pakualaman",
      "Tegalrejo",
      "Umbulharjo",
      "Wirobrajan"
    ],
     "Kab. Sleman": [
      "Depok", "Gamping", "Godean", "Kalasan", "Mlati", "Ngaglik", "Prambanan"
    ],
  },
  "Jawa Timur": {
    "Kota Surabaya": [
      "Asemrowo",
      "Benowo",
      "Bubutan",
      "Bulak",
      "Dukuh Pakis",
      "Gayungan",
      "Genteng",
      "Gubeng",
      "Gunung Anyar",
      "Jambangan",
      "Karang Pilang",
      "Kenjeran",
      "Krembangan",
      "Lakar Santri",
      "Mulyorejo",
      "Pabean Cantian",
      "Pakal",
      "Rungkut",
      "Sambikerep",
      "Sawahan",
      "Semampir",
      "Simokerto",
      "Sukolilo",
      "Sukomanunggal",
      "Tambaksari",
      "Tandes",
      "Tegalsari",
      "Tenggilis Mejoyo",
      "Wiyung",
      "Wonocolo",
      "Wonokromo"
    ],
    "Kota Malang": [
      "Blimbing",
      "Kedungkandang",
      "Klojen",
      "Lowokwaru",
      "Sukun"
    ],
    "Kab. Sidoarjo": ["Waru", "Sedati", "Taman", "Krian", "Sidoarjo"],
  },
  "Bali": {
    "Kota Denpasar": [
      "Denpasar Barat",
      "Denpasar Selatan",
      "Denpasar Timur",
      "Denpasar Utara"
    ],
    "Kab. Badung": [
      "Abiansemal",
      "Kuta",
      "Kuta Selatan",
      "Kuta Utara",
      "Mengwi",
      "Petang"
    ],
     "Kab. Gianyar": ["Ubud", "Gianyar", "Sukawati"],
  },
  "Sumatera Utara": {
    "Kota Medan": [
      "Medan Amplas", "Medan Area", "Medan Barat", "Medan Baru", "Medan Belawan", "Medan Deli", "Medan Denai", "Medan Helvetia", "Medan Johor", "Medan Kota", "Medan Labuhan", "Medan Maimun", "Medan Marelan", "Medan Perjuangan", "Medan Petisah", "Medan Polonia", "Medan Selayang", "Medan Sunggal", "Medan Tembung", "Medan Timur", "Medan Tuntungan"
    ]
  },
  "Sulawesi Selatan": {
    "Kota Makassar": [
      "Biringkanaya", "Bontoala", "Makassar", "Mamajang", "Manggala", "Mariso", "Panakkukang", "Rappocini", "Tallo", "Tamalanrea", "Tamalate", "Ujung Pandang", "Ujung Tanah", "Wajo"
    ]
  }
};
