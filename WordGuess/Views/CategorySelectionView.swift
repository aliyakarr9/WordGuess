import SwiftUI

// MARK: - 1. Kategori Durum Modeli
enum CategoryStatus {
    case active      // Ücretsiz ve oynanabilir
    case premium     // Hazır ama kilitli (Satın al ve Oyna)
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
        CategoryItem(title: "Klasik", icon: "star.fill", color: .purple, desc: "Genel kültür, karışık eğlence.", status: .active, jsonFileName: "words"),
        CategoryItem(title: "Sinema", icon: "popcorn.fill", color: .red, desc: "Kült filmler ve dünya sineması.", status: .active, jsonFileName: "sinema"),
        CategoryItem(title: "Tarih", icon: "scroll.fill", color: .brown, desc: "Zaferler ve tarihi olaylar.", status: .active, jsonFileName: "tarih"),
        
        // YEŞİLÇAM -> PREMIUM
        CategoryItem(title: "Yeşilçam", icon: "film.fill", color: .orange, desc: "Eski Türk filmleri nostaljisi.", status: .premium, jsonFileName: "yesilcam"),
        
        CategoryItem(title: "Bilim Kurgu", icon: "airplane", color: .blue, desc: "Uzay, gelecek ve teknoloji.", status: .premium, jsonFileName: "bilimkurgu"),
        CategoryItem(title: "Spor", icon: "figure.soccer", color: .green, desc: "Futbol, basketbol ve efsaneler.", status: .premium, jsonFileName: "spor"),
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
                                case .active:
                                    withAnimation {
                                        viewModel.selectCategory(
                                            fileName: category.jsonFileName,
                                            categoryTitle: category.title
                                        )
                                    }
                                case .premium:
                                    print("Premium satın alma ekranı tetiklendi: \(category.title)")
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

// MARK: - 2. PremiumCategoryCard (Hata Düzeltildi)
struct PremiumCategoryCard: View {
    let item: CategorySelectionView.CategoryItem
    
    // Altın Efekti için Gradient
    var premiumGradient: LinearGradient {
        LinearGradient(
            colors: [Color.yellow, Color.orange, Color.yellow],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            // MARK: - KART ARKA PLANI
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: item.status == .comingSoon
                            ? [Color.gray.opacity(0.15), Color.gray.opacity(0.05)] // Yakında (Soluk)
                            : [item.color.opacity(0.8), item.color.opacity(0.4)],  // Aktif ve Premium (Canlı)
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
               
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            item.status == .premium
                                ? AnyShapeStyle(premiumGradient) // Gradient
                                : AnyShapeStyle(item.status == .comingSoon ? Color.white.opacity(0.05) : item.color.opacity(0.8)), // Color
                            lineWidth: item.status == .premium ? 3 : (item.status == .active ? 2 : 1)
                        )
                )
                // Premium ise Altın Gölge
                .shadow(
                    color: item.status == .premium ? Color.orange.opacity(0.5) : (item.status == .active ? item.color.opacity(0.4) : .clear),
                    radius: item.status == .premium ? 20 : 15,
                    x: 0,
                    y: 10
                )
            
            // MARK: - İÇERİK (Yazılar ve İkon)
            VStack(spacing: 0) {
                // ÜST BİLGİ ALANI
                HStack {
                    Spacer()
                    
                    if item.title == "Klasik" {
                        // Klasik Paket Etiketi
                        Text("1500+ KELİME")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow)
                            .cornerRadius(8)
                    } else if item.status == .premium {
                        // Premium Tacı
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .padding(.top, 15)
                .padding(.trailing, 15)
                
                Spacer()
                
                // ORTALANMIŞ İKON
                ZStack {
                    Circle()
                        .fill(item.status == .active || item.status == .premium ? Color.black.opacity(0.3) : Color.white.opacity(0.05))
                        .frame(width: 65, height: 65)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(item.status == .comingSoon ? .gray : .white)
                }
                
                Spacer()
                
                // BAŞLIK VE AÇIKLAMA
                VStack(spacing: 6) {
                    Text(item.title.uppercased())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(item.status == .comingSoon ? .gray : .white)
                        .multilineTextAlignment(.center)
                        // Premium ise yazıya hafif gölge ekle
                        .shadow(color: item.status == .premium ? .orange.opacity(0.8) : .clear, radius: 5)
                    
                    Text(item.desc)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(item.status == .comingSoon ? .gray.opacity(0.5) : .white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 10)
                }
                .padding(.bottom, 25)
            }
            
            // MARK: - SADECE YAKINDA OLANLAR İÇİN KATMAN (Premium Artık Açık)
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
            
            // Premium için alt etiket
            if item.status == .premium {
                VStack {
                    Spacer()
                    Text("PREMIUM")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(premiumGradient)
                        .cornerRadius(20)
                        .offset(y: 10)
                        .shadow(radius: 5)
                }
                .padding(.bottom, -10)
            }
        }
        .frame(height: 240)
    }
}

// Buton Tıklama Animasyonu
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
