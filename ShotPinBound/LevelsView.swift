import SwiftUI

struct LevelsView: View {
    // Имена файлов изображений
    private let backgroundImageName = "MainBackground"
    private let backButtonName = "BackButton"
    private let levelButtonName = "LevelButton"
    private let lockedLevelButtonName = "LockedLevelButton"
    private let nextButtonName = "NextButton"
    
    // Количество уровней
    private let levelsCount = 12
    // Доступно для игры только 3 уровня, остальные - макеты
    private let playableLevelsCount = 3
    
    // Последний открытый уровень
    @State private var lastUnlockedLevel = 3
    
    // Колбэк для возврата назад
    var onBack: () -> Void
    // Колбэк для старта игры с выбранным уровнем
    var onStartLevel: (Int) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Фон
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Верхняя панель с кнопкой возврата и заголовком
                    HStack {
                        Button(action: onBack) {
                            Image(backButtonName)
                                .resizable()
                                .frame(width: 80, height: 80)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text("Выберите уровень")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Пустое пространство для выравнивания
                        Rectangle()
                            .opacity(0)
                            .frame(width: 80, height: 80)
                            .padding(.trailing, 20)
                    }
                    .padding(.top, 50)
                    
                    // Сетка с уровнями
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 40) {
                        ForEach(1...levelsCount, id: \.self) { level in
                            Button(action: {
                                // Позволяем запускать только первые playableLevelsCount уровней
                                if level <= playableLevelsCount {
                                    onStartLevel(level)
                                } else if level <= lastUnlockedLevel {
                                    // Показать уведомление, что уровень в разработке
                                    // (в реальном приложении здесь мог бы быть Alert или другое уведомление)
                                    print("Уровень \(level) в разработке")
                                }
                            }) {
                                Image(level <= lastUnlockedLevel ? levelButtonName : lockedLevelButtonName)
                                    .resizable()
                                    .frame(width: 180, height: 180)
                                    .overlay(
                                        ZStack {
                                            Text("\(level)")
                                                .foregroundColor(.white)
                                                .font(.system(size: 60, weight: .bold))
                                            
                                            // Для уровней больше 2, но открытых - показываем индикатор "в разработке"
                                            if level > playableLevelsCount && level <= lastUnlockedLevel {
                                                Text("Soon")
                                                    .foregroundColor(.yellow)
                                                    .font(.system(size: 24, weight: .bold))
                                                    .offset(y: 40)
                                            }
                                        }
                                    )
                                    // Уменьшаем непрозрачность для уровней, которые еще в разработке
                                    .opacity(level > playableLevelsCount && level <= lastUnlockedLevel ? 0.7 : 1)
                            }
                            .disabled(level > lastUnlockedLevel)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Нижняя панель с кнопкой next
                    HStack {
                        Spacer()
                        Button(action: {
                            // Действие для кнопки next
                        }) {
                            Image(nextButtonName)
                                .resizable()
                                .frame(width: 250, height: 80)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
} 
