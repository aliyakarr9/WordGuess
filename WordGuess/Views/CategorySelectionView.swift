import SwiftUI

// MARK: - 1. Kategori Durum Modeli
enum CategoryStatus {
    case active      // Ücretsiz ve oynanabilir
    case premium     // Hazır ama kilitli (Satın al ve Oyna)
    case event       // 🌙 SÜRELİ ETKİNLİK (Özel Tasarım + Oynanabilir)
    case comingSoon  // Henüz yapım aşamasında (Gri ve Pasif)
}

struct CategorySelectionView: View {
    @ObservedObject var viewModel: GameViewModel
    
    struct CategoryItem: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let color: Color
        let desc: String
        let status: CategoryStatus
        let jsonFileName: String
    }
    
    // Kategoriler Listesi
    let categories = [
        // 🌙 RAMAZAN -> EVENT (En Üstte)
        CategoryItem(title: "Ramazan", icon: "moon.stars.fill", color: .indigo, desc: "İftar, sahur ve manevi değerler.", status: .event, jsonFileName: "ramadan_pack"),

        CategoryItem(title: "Klasik", icon: "star.fill", color: .purple, desc: "Genel kültür, karışık eğlence.", status: .active, jsonFileName: "words"),
        
        CategoryItem(title: "Sinema", icon: "popcorn.fill", color: .red, desc: "Kült filmler ve dünya sineması.", status: .active, jsonFileName: "sinema"),
        
        CategoryItem(title: "Yeşilçam", icon: "film.fill", color: .orange, desc: "Eski Türk filmleri nostaljisi.", status: .premium, jsonFileName: "yesilcam"),
        
        CategoryItem(title: "Tarih", icon: "scroll.fill", color: .brown, desc: "Zaferler ve tarihi olaylar.", status: .active, jsonFileName: "tarih"),
        CategoryItem(title: "İngilizce", icon: "book.fill", color: .teal, desc: "Yasaklı kelimelerle dil pratiği.", status: .active, jsonFileName: "english_pack"),
        

        
        CategoryItem(title: "Bilim Kurgu", icon: "airplane", color: .blue, desc: "Uzay, gelecek ve teknoloji.", status: .comingSoon, jsonFileName: "bilimkurgu"),
        CategoryItem(title: "Spor", icon: "figure.soccer", color: .green, desc: "Futbol, basketbol ve efsaneler.", status: .comingSoon, jsonFileName: "spor"),
        CategoryItem(title: "Müzik", icon: "music.note", color: .pink, desc: "Şarkılar ve sanatçılar.", status: .comingSoon, jsonFileName: "muzik")
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Arka plan ışık efekti
            VStack {
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -100, y: -100)
                Spacer()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    // Başlık Alanı
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PAKET SEÇ")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.purple)
                            .tracking(2)
                        
                        Text("Hangi modda\noynayacaksın?")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 25)
                    
                    // Izgara Yapısı
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(categories) { category in
                            Button(action: {
                                switch category.status {
                                case .active, .event:
                                    withAnimation {
                                        viewModel.selectCategory(
                                            fileName: category.jsonFileName,
                                            categoryTitle: category.title
                                        )
                                    }
                                case .premium:
                                    print("Premium satın alma: \(category.title)")
                                case .comingSoon:
                                    break
                                }
                            }) {
                                PremiumCategoryCard(item: category)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .disabled(category.status == .comingSoon)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

// MARK: - 2. PremiumCategoryCard (GELİŞMİŞ TASARIM)
struct PremiumCategoryCard: View {
    let item: CategorySelectionView.CategoryItem
    
    // Altın Efekti (Premium)
    var premiumGradient: LinearGradient {
        LinearGradient(colors: [.yellow, .orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // 🌙 Etkinlik Arka Planı (Mistik Gece)
    var eventBackground: LinearGradient {
        LinearGradient(colors: [Color(hex: "1a0b2e"), Color(hex: "2d1b4e")], startPoint: .top, endPoint: .bottom)
    }
    
    // ✨ Etkinlik Çerçevesi (Altın ve Mor Karışımı - Parlak)
    var eventBorder: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [.orange, .purple, .yellow, .indigo, .orange]),
            center: .center
        )
    }
    
    var body: some View {
        ZStack {
            // MARK: - KART ARKA PLANI
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    item.status == .event
                    ? eventBackground // Özel Event Arka Planı
                    : LinearGradient(
                        colors: cardBackgroundColors(),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                // Event için ekstra iç desen (Yıldızlar)
                .overlay(
                    Group {
                        if item.status == .event {
                            StarryPattern() // Aşağıdaki özel görünüm
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            strokeStyle(),
                            lineWidth: (item.status == .premium || item.status == .event) ? 3 : 2
                        )
                )
                // Gölge Efektleri
                .shadow(
                    color: shadowColor(),
                    radius: (item.status == .premium || item.status == .event) ? 20 : 10,
                    x: 0,
                    y: 10
                )
            
            // MARK: - İÇERİK
            VStack(spacing: 0) {
                // ÜST BİLGİ ALANI
                HStack {
                    Spacer()
                    if item.title == "Klasik" {
                        Text("1500+ KELİME")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow)
                            .cornerRadius(8)
                    } else if item.status == .premium {
                        ZStack {
                            Circle().fill(Color.black.opacity(0.4)).frame(width: 32, height: 32)
                            Image(systemName: "crown.fill").font(.system(size: 14)).foregroundColor(.yellow)
                        }
                    } else if item.status == .event {
                        // Event İkonu
                        ZStack {
                            Circle().fill(Color.white.opacity(0.15)).frame(width: 32, height: 32)
                            Image(systemName: "sparkles").font(.system(size: 14)).foregroundColor(.yellow)
                        }
                    }
                }
                .padding(.top, 15)
                .padding(.trailing, 15)
                
                Spacer()
                
                // ORTALANMIŞ İKON
                ZStack {
                    Circle()
                        .fill(item.status == .active || item.status == .premium || item.status == .event ? Color.black.opacity(0.3) : Color.white.opacity(0.05))
                        .frame(width: 65, height: 65)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(item.status == .comingSoon ? .gray : .white)
                        // Event ise ikon parlasın
                        .shadow(color: item.status == .event ? .white.opacity(0.5) : .clear, radius: 10)
                }
                
                Spacer()
                
                // BAŞLIK VE AÇIKLAMA
                VStack(spacing: 6) {
                    Text(item.title.uppercased())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(item.status == .comingSoon ? .gray : .white)
                        .multilineTextAlignment(.center)
                        .shadow(color: (item.status == .premium || item.status == .event) ? item.color.opacity(0.8) : .clear, radius: 5)
                    
                    Text(item.desc)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(item.status == .comingSoon ? .gray.opacity(0.5) : .white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 10)
                }
                .padding(.bottom, 25)
            }
            
            // MARK: - YAKINDA KATMANI
            if item.status == .comingSoon {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                    .opacity(0.9)
                VStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                    Text("YAKINDA")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                }
            }
            
            // MARK: - ALT ETİKETLER
            if item.status == .premium {
                BadgeView(text: "PREMIUM", background: premiumGradient, textColor: .black)
            } else if item.status == .event {
                // Etkinlik Rozeti (Daha havalı renkler)
                BadgeView(
                    text: "ÖZEL ETKİNLİK",
                    background: LinearGradient(colors: [Color(hex: "ff00cc"), Color(hex: "333399")], startPoint: .leading, endPoint: .trailing),
                    textColor: .white
                )
            }
        }
        .frame(height: 240)
    }
    
    // Renk Yardımcıları
    func cardBackgroundColors() -> [Color] {
        switch item.status {
        case .comingSoon: return [Color.gray.opacity(0.15), Color.gray.opacity(0.05)]
        case .premium: return [item.color.opacity(0.8), item.color.opacity(0.4)]
        case .event: return [] // Event için yukarıda özel gradient kullandık
        case .active: return [item.color.opacity(0.8), item.color.opacity(0.4)]
        }
    }
    
    func strokeStyle() -> AnyShapeStyle {
        switch item.status {
        case .premium: return AnyShapeStyle(premiumGradient)
        case .event: return AnyShapeStyle(eventBorder) // ✨ Angular Gradient Çerçeve
        case .comingSoon: return AnyShapeStyle(Color.white.opacity(0.05))
        case .active: return AnyShapeStyle(item.color.opacity(0.8))
        }
    }
    
    func shadowColor() -> Color {
        switch item.status {
        case .premium: return Color.orange.opacity(0.5)
        case .event: return Color.purple.opacity(0.7) // Mor neon gölge
        case .active: return item.color.opacity(0.4)
        default: return .clear
        }
    }
}

// MARK: - Yıldız Deseni (Event İçin Süsleme)
struct StarryPattern: View {
    var body: some View {
        GeometryReader { _ in
            ZStack {
                ForEach(0..<10) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: CGFloat.random(in: 4...10)))
                        .foregroundColor(.white.opacity(Double.random(in: 0.1...0.3)))
                        .offset(
                            x: CGFloat.random(in: 0...150),
                            y: CGFloat.random(in: 0...200)
                        )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}

// Alt Rozet Bileşeni
struct BadgeView: View {
    let text: String
    let background: LinearGradient
    let textColor: Color
    
    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(textColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(background)
                .cornerRadius(20)
                .offset(y: 10)
                .shadow(radius: 5)
        }
        .padding(.bottom, -10)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Hex Renk Desteği için Eklenti (Bunu dosyanın en altına ekle)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
