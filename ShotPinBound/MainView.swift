import SwiftUI

// SwiftUI представление для главного меню
struct MainView: View {
    // Имя файла изображения фона
    private let backgroundImageName = "LoadingBackground"
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image(backgroundImageName)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Название игры
                Text("ShotPinBound")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 5, x: 0, y: 0)
                
                Spacer()
                Spacer()
                
                // Кнопки меню
                VStack(spacing: 20) {
                    MenuButton(title: "Играть") {
                        // Здесь логика запуска игры
                        NotificationCenter.default.post(name: NSNotification.Name("StartGame"), object: nil)
                    }
                    
                    MenuButton(title: "Настройки") {
                        // Здесь логика открытия настроек
                    }
                    
                    MenuButton(title: "Об игре") {
                        // Здесь логика открытия информации об игре
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
    }
}

// Компонент кнопки для меню
struct MenuButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                )
        }
    }
}

// Для предварительного просмотра в Xcode
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
} 