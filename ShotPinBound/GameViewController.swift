//
//  GameViewController.swift
//  ShotPinBound iOS
//
//  Created by Рома Котов on 07.04.2025.
//

import UIKit
import SpriteKit
import GameplayKit
import SwiftUI
import AVFoundation

// Представление для экрана уровней
struct LevelsView: View {
    // Имена файлов изображений
    private let backgroundImageName = "LevelsBG"
    private let levelsContainerName = "LevelsPanel"
    private let backButtonName = "BackButton"
    private let coinIconName = "CoinIcon"
    
    // Кнопки уровней
    private let completedLevelBgName = "CompletedLevelButton" // Фон для пройденного уровня
    private let activeLevelBgName = "ActiveLevelButton" // Фон для активного уровня
    private let lockedLevelBgName = "LockedLevelButton" // Фон для недоступного уровня
    
    // Иконки для кнопок
    private let medalIconName = "MedalIcon" // Медаль для пройденного уровня
    private let planetIconName = "PlanetIcon" // Планета для активного уровня
    private let lockIconName = "LockIcon" // Замок для недоступного уровня
    
    // Звездочки
    private let starFilledName = "StarFilled" // Заполненная звезда
    private let starEmptyName = "StarEmpty" // Пустая звезда
    
    private let levelsCount = 15
    // Доступно для игры только 3 уровня, остальные - макеты
    private let playableLevelsCount = 3
    @State private var lastUnlockedLevel = 1
    @State private var completedLevels = [Int]() // Пустой массив
    @State private var starsPerLevel = [Int: Int]() // Пустой словарь
    @State private var totalCoins = 0 // Добавляем состояние для хранения количества монет
    
    var onBack: () -> Void
    var onStartLevel: (Int) -> Void
    
    // Функция для определения состояния уровня
    private func getLevelState(level: Int) -> LevelState {
        if completedLevels.contains(level) {
            return .completed
        } else if level <= lastUnlockedLevel {
            return .active
        } else {
            return .locked
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom
            
            // Вычисляем оптимальные размеры на основе пропорций экрана
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let isLandscape = screenWidth > screenHeight
            let baseUnit = min(screenWidth, screenHeight) / (isIpad ? 10 : 7)
            
            // Размеры элементов адаптированы под разные устройства и ориентации
            let headerButtonSize = baseUnit * (isIpad ? 0.8 : 1.0)
            let coinWidth = baseUnit * (isIpad ? 1.4 : 1.7)
            let fontSize = baseUnit * (isIpad ? 0.25 : 0.3)
            let levelButtonSize = baseUnit * (isIpad ? 1.5 : 1.8) * (isLandscape ? 0.85 : 1.0)
            let containerWidth = screenWidth * (isLandscape ? 0.9 : 0.95)
            let starSize = levelButtonSize * (isIpad ? 0.12 : 0.15)
            let iconSize = levelButtonSize * (isIpad ? 0.25 : 0.3)
            let gridSpacing = baseUnit * (isIpad ? 0.15 : 0.2) * (isLandscape ? 1.0 : 0.8)
            
            ZStack {
                // Фон
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth, height: screenHeight)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Верхняя панель
                    HStack {
                        Button(action: onBack) {
                            Image(backButtonName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: headerButtonSize)
                        }
                        .padding(.leading, baseUnit * 0.4)
                        
                        Spacer()
                        
                        Image(coinIconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: coinWidth)
                            .overlay(
                                Text("\(totalCoins)")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: fontSize, weight: .bold))
                                    .padding(.leading, baseUnit * 0.4)
                                    .padding(.bottom, 5)
                                , alignment: .center
                            )
                            .padding(.trailing, baseUnit * 0.4)
                    }
                    .padding(.top, safeTop + baseUnit * 0.2)
                    
                    Spacer()
                    
                    // Панель с уровнями - адаптированная для разных размеров экрана
                    Image(levelsContainerName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: containerWidth)
                        .overlay(
                            VStack(spacing: 0) {
                                // Используем лаконичную и гибкую LazyVGrid
                                LazyVGrid(
                                    columns: Array(
                                        repeating: GridItem(.flexible(), spacing: gridSpacing),
                                        count: isLandscape ? 5 : 3
                                    ),
                                    spacing: gridSpacing
                                ) {
                                    ForEach(1...levelsCount, id: \.self) { level in
                                        Button(action: {
                                            if level <= lastUnlockedLevel {
                                                if level == 1 {
                                                    // Показываем туториал для первого уровня
                                                    onStartLevel(-1) // Используем -1 как сигнал для показа туториала
                                                } else {
                                                    onStartLevel(level)
                                                }
                                            }
                                        }) {
                                            let levelState = getLevelState(level: level)
                                            
                                            ZStack {
                                                // Фон кнопки в зависимости от состояния
                                                Image(levelState == .completed ? completedLevelBgName : 
                                                       levelState == .active ? activeLevelBgName : 
                                                       lockedLevelBgName)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: levelButtonSize)
                                                
                                                // Иконка в зависимости от состояния
                                                if levelState == .completed {
                                                    Image(medalIconName)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: iconSize)
                                                        .offset(y: -levelButtonSize * 0.1)
                                                } else if levelState == .active {
                                                    Image(planetIconName)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: iconSize)
                                                        .offset(y: -levelButtonSize * 0.1)
                                                } else {
                                                    Image(lockIconName)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: iconSize)
                                                        .offset(y: -levelButtonSize * 0.1)
                                                }
                                                
                                                // Звездочки
                                                if levelState == .completed {
                                                    HStack(spacing: levelButtonSize * 0.03) {
                                                        ForEach(1...3, id: \.self) { starIndex in
                                                            let starsEarned = starsPerLevel[level] ?? 0
                                                            Image(starIndex <= starsEarned ? starFilledName : starEmptyName)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .frame(width: starSize)
                                                        }
                                                    }
                                                    .offset(y: levelButtonSize * 0.2)
                                                } else if levelState == .active {
                                                    HStack(spacing: levelButtonSize * 0.03) {
                                                        ForEach(1...3, id: \.self) { _ in
                                                            Image(starEmptyName)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .frame(width: starSize)
                                                        }
                                                    }
                                                    .offset(y: levelButtonSize * 0.2)
                                                }
                                            }
                                        }
                                        .disabled(level > lastUnlockedLevel)
                                    }
                                }
                                .padding(.horizontal, baseUnit * 0.3)
                                .padding(.vertical, baseUnit * 0.3)
                            }
                        )
                        .padding(.bottom, safeBottom + baseUnit * 0.3)
                        .onAppear {
                            // Загрузка прогресса при отображении экрана уровней
                            loadProgress()
                        }
                    
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // Функция для загрузки прогресса игрока
    private func loadProgress() {
        // Загрузка текущего уровня
        let currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        
        // Если есть сохраненный уровень, обновляем lastUnlockedLevel
        if currentLevel > 0 {
            lastUnlockedLevel = currentLevel
            
            // Считаем, что все уровни до текущего уже пройдены
            completedLevels = Array(1..<currentLevel)
        }
        
        // Загрузка звезд для каждого уровня
        var stars = [Int: Int]()
        for level in 1...levelsCount {
            let key = "starsForLevel\(level)"
            let levelStars = UserDefaults.standard.integer(forKey: key)
            if levelStars > 0 {
                stars[level] = levelStars
            }
        }
        starsPerLevel = stars
        
        // Загрузка общего количества монет
        totalCoins = UserDefaults.standard.integer(forKey: "totalCoins")
    }
}

// Перечисление для состояний уровня
enum LevelState {
    case completed  // Пройденный уровень
    case active     // Активный (разблокированный) уровень
    case locked     // Заблокированный уровень
}

// Представление для экрана магазина
struct ShopView: View {
    // Имена файлов изображений
    private let backgroundImageName = "ShopBG"
    private let backButtonName = "BackButton"
    private let coinIconName = "CoinIcon"
    
    // Имена скинов
    private let skin1Name = "Skin1"
    private let skin2Name = "Skin2"
    private let skin3Name = "Skin3"
    private let skin4Name = "Skin4"
    private let skin5Name = "Skin5"
    
    // Имена активированных скинов
    private let activeSkin1Name = "ActiveSkin1"
    
    // Имена элементов
    private let element1Name = "Element1"
    private let element2Name = "Element2"
    private let element3Name = "Element3"
    private let element4Name = "Element4"
    private let element5Name = "Element5"
    
    // Имена активированных элементов
    private let activeElement1Name = "ActiveElement1"
    
    // Стоимость первого элемента
    private let element1Cost = 100
    
    // Состояние активации элементов
    @State private var isElement1Active = false
    @State private var isElement1Purchased = false
    @State private var totalCoins = 0
    
    var onBack: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom
            
            // Вычисляем оптимальные размеры на основе пропорций экрана
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let isLandscape = screenWidth > screenHeight
            let baseUnit = min(screenWidth, screenHeight) / (isIpad ? 10 : 7)
            
            // Размеры элементов, адаптированные для разных устройств
            let headerButtonSize = baseUnit * (isIpad ? 0.8 : 1.0)
            let coinWidth = baseUnit * (isIpad ? 1.8 : 2.2)
            let fontSize = baseUnit * (isIpad ? 0.3 : 0.35)
            let skinSize = baseUnit * (isIpad ? 1.0 : 1.2) * (isLandscape ? 0.9 : 1.0)
            let elementWidth = baseUnit * (isIpad ? 4.0 : 4.5) * (isLandscape ? 0.9 : 1.0)
            let elementHeight = baseUnit * (isIpad ? 1.0 : 1.2) * (isLandscape ? 0.9 : 1.0)
            let spacing = baseUnit * (isIpad ? 0.3 : 0.4) * (isLandscape ? 0.8 : 1.0)
            let horizontalSpacing = baseUnit * (isIpad ? 0.5 : 0.6) * (isLandscape ? 1.2 : 1.0)
            let verticalPadding = baseUnit * (isIpad ? 0.3 : 0.4)
            
            ZStack {
                // Фон
                Image(backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Верхняя панель
                    HStack {
                        Button(action: onBack) {
                            Image(backButtonName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: headerButtonSize)
                        }
                        .padding(.leading, baseUnit * 0.4)
                        
                        Spacer()
                        
                        Image(coinIconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: coinWidth)
                            .overlay(
                                Text("\(totalCoins)")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: fontSize, weight: .bold))
                                    .padding(.leading, baseUnit * 0.4)
                                    .padding(.bottom, 5)
                                , alignment: .center
                            )
                            .padding(.trailing, baseUnit * 0.4)
                    }
                    .padding(.top, safeTop + baseUnit * 0.2)
                    
                    Spacer()
                    
                    // ScrollView для контента магазина
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: spacing) {
                            // Скин 1 и Элемент 1
                            shopItemRow(
                                skinName: isElement1Active ? activeSkin1Name : skin1Name,
                                elementName: isElement1Active ? activeElement1Name : element1Name,
                                skinSize: skinSize,
                                elementWidth: elementWidth,
                                horizontalSpacing: horizontalSpacing,
                                isActive: isElement1Active,
                                isPurchased: isElement1Purchased,
                                cost: element1Cost,
                                onTap: {
                                    if !isElement1Purchased {
                                        // Проверяем, достаточно ли монет
                                        if totalCoins >= element1Cost {
                                            // Списываем монеты
                                            totalCoins -= element1Cost
                                            UserDefaults.standard.set(totalCoins, forKey: "totalCoins")
                                            
                                            // Активируем элемент
                                            isElement1Active = true
                                            isElement1Purchased = true
                                            UserDefaults.standard.set(true, forKey: "isElement1Purchased")
                                            UserDefaults.standard.set(true, forKey: "isElement1Active")
                                        }
                                    } else {
                                        // Если элемент уже куплен, просто переключаем его активность
                                        isElement1Active.toggle()
                                        UserDefaults.standard.set(isElement1Active, forKey: "isElement1Active")
                                    }
                                }
                            )
                            
                            // Скин 2 и Элемент 2
                            shopItemRow(
                                skinName: skin2Name,
                                elementName: element2Name,
                                skinSize: skinSize,
                                elementWidth: elementWidth,
                                horizontalSpacing: horizontalSpacing,
                                isActive: false,
                                isPurchased: false,
                                onTap: {}
                            )
                            
                            // Скин 3 и Элемент 3
                            shopItemRow(
                                skinName: skin3Name,
                                elementName: element3Name,
                                skinSize: skinSize,
                                elementWidth: elementWidth,
                                horizontalSpacing: horizontalSpacing,
                                isActive: false,
                                isPurchased: false,
                                onTap: {}
                            )
                            
                            // Скин 4 и Элемент 4
                            shopItemRow(
                                skinName: skin4Name,
                                elementName: element4Name,
                                skinSize: skinSize,
                                elementWidth: elementWidth,
                                horizontalSpacing: horizontalSpacing,
                                isActive: false,
                                isPurchased: false,
                                onTap: {}
                            )
                            
                            // Скин 5 и Элемент 5
                            shopItemRow(
                                skinName: skin5Name,
                                elementName: element5Name,
                                skinSize: skinSize,
                                elementWidth: elementWidth,
                                horizontalSpacing: horizontalSpacing,
                                isActive: false,
                                isPurchased: false,
                                onTap: {}
                            )
                        }
                        .padding(.vertical, verticalPadding)
                        .padding(.horizontal, baseUnit * 0.5)
                        .padding(.bottom, safeBottom + baseUnit * 2)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Загружаем количество монет и состояние элемента при появлении экрана
            totalCoins = UserDefaults.standard.integer(forKey: "totalCoins")
            isElement1Purchased = UserDefaults.standard.bool(forKey: "isElement1Purchased")
            isElement1Active = UserDefaults.standard.bool(forKey: "isElement1Active")
        }
    }
    
    // Обновленная вспомогательная функция для создания ряда элементов магазина
    private func shopItemRow(
        skinName: String,
        elementName: String,
        skinSize: CGFloat,
        elementWidth: CGFloat,
        horizontalSpacing: CGFloat,
        isActive: Bool,
        isPurchased: Bool,
        cost: Int = 0,
        onTap: @escaping () -> Void
    ) -> some View {
        HStack(spacing: horizontalSpacing) {
            Image(skinName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: skinSize)
            
            ZStack {
                Button(action: onTap) {
                    Image(elementName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: elementWidth)
                }
                .disabled(isPurchased || (elementName != "Element1" && !isPurchased)) // Отключаем все кнопки кроме первого элемента
                .opacity(elementName == "Element1" ? 
                    ((!isPurchased && totalCoins < cost) ? 0.5 : 1.0) : // Для первого элемента
                    (isActive || isPurchased ? 1.0 : 0.5)) // Для остальных элементов
            }
        }
    }
}

// Представление для экрана достижений
struct AchievesView: View {
    // Имена файлов изображений
    private let backgroundImageName = "AchievesBG"
    private let achievesPanelName = "AchievesPanel"
    private let backButtonName = "BackButton"
    private let achievesTitleName = "AchievesTitle"
    private let achieveStarName = "AchieveStar"
    private let achieveGoldStarName = "AchieveGoldStar"
    
    // Имена изображений достижений
    private let achieve1Name = "Achieve1"
    private let achieve2Name = "Achieve2"
    private let achieve3Name = "Achieve3"
    private let achieve4Name = "Achieve4"
    private let achieve5Name = "Achieve5"
    
    @State private var isFirstLevelCompleted = false
    
    var onBack: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom
            
            // Вычисляем оптимальные размеры на основе пропорций экрана
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let isLandscape = screenWidth > screenHeight
            let baseUnit = min(screenWidth, screenHeight) / (isIpad ? 8 : 6)
            
            // Размеры элементов, адаптированные для разных устройств
            let headerButtonSize = baseUnit * (isIpad ? 1.0 : 1.2)
            let titleWidth = baseUnit * (isIpad ? 3.0 : 3.5)
            let achieveWidth = baseUnit * (isIpad ? 5.5 : 5.0) * (isLandscape ? 0.85 : 1.0)
            let achieveHeight = baseUnit * (isIpad ? 2.0 : 1.8) * (isLandscape ? 0.85 : 1.0)
            let spacing = baseUnit * (isIpad ? 0.2 : 0.3)
            let starSize = baseUnit * (isIpad ? 0.6 : 0.8)
            let panelPadding = baseUnit * (isIpad ? 0.5 : 0.3)
            let panelWidth = screenWidth * (isLandscape ? 0.85 : 0.95)
            
            ZStack {
                // Фон
                Image(backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Верхняя панель
                    HStack {
                        Button(action: onBack) {
                            Image(backButtonName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: headerButtonSize)
                        }
                        .padding(.leading, baseUnit * 0.5)
                        
                        Spacer()
                    }
                    .padding(.top, safeTop + baseUnit * 0.3)
                    
                    // Заголовок
                    Image(achievesTitleName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: titleWidth)
                        .padding(.top, baseUnit * 0.3)
                    
                    // ScrollView с панелью достижений
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: spacing) {
                            // Достижение 1
                            achievementCard(
                                imageName: achieve1Name,
                                width: achieveWidth,
                                height: achieveHeight,
                                starSize: starSize,
                                useGoldStar: isFirstLevelCompleted
                            )
                            
                            // Достижение 2
                            achievementCard(
                                imageName: achieve2Name,
                                width: achieveWidth,
                                height: achieveHeight,
                                starSize: starSize,
                                useGoldStar: isFirstLevelCompleted
                            )
                            
                            // Достижение 3
                            achievementCard(
                                imageName: achieve3Name,
                                width: achieveWidth,
                                height: achieveHeight,
                                starSize: starSize,
                                useGoldStar: false
                            )
                            
                            // Достижение 4
                            achievementCard(
                                imageName: achieve4Name,
                                width: achieveWidth,
                                height: achieveHeight,
                                starSize: starSize,
                                useGoldStar: false
                            )
                            
                            // Достижение 5
                            achievementCard(
                                imageName: achieve5Name,
                                width: achieveWidth,
                                height: achieveHeight,
                                starSize: starSize,
                                useGoldStar: false
                            )
                        }
                        .padding(.vertical, baseUnit * 0.3)
                        .padding(.horizontal, baseUnit * 0.5)
                        .background(
                            Image(achievesPanelName)
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(width: panelWidth)
                        .padding(.bottom, safeBottom + baseUnit * 2)
                        .padding(.top, baseUnit * 0.5)
                    }
                    .padding(.horizontal, baseUnit * 0.2)
                    
                    Spacer(minLength: 0)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Проверяем, пройден ли первый уровень
            let currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
            isFirstLevelCompleted = currentLevel > 1
        }
    }
    
    // Обновленная вспомогательная функция для создания карточки достижения
    private func achievementCard(imageName: String, width: CGFloat, height: CGFloat, starSize: CGFloat, useGoldStar: Bool) -> some View {
        ZStack(alignment: .trailing) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
            
            Image(useGoldStar ? achieveGoldStarName : achieveStarName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: starSize)
                .offset(x: starSize * 0.3)
        }
    }
}

// Кастомный прогресс-бар для настроек
struct CustomProgressView: View {
    // Имена файлов изображений
    private let progressTrackName = "ProgressTrack" // Фон прогресс-бара
    private let progressThumbName = "ProgressThumb" // Ползунок прогресс-бара
    private let progressBackgroundName = "ProgressBackground" // Фон для прогресс-бара
    
    @Binding var value: Float
    var label: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Лейбл
            Image(label)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
            
            // Кастомный прогресс-бар
            ZStack(alignment: .leading) {
                // Фон прогресс-бара
                Image(progressTrackName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                
                // Ползунок
                Image(progressThumbName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .offset(x: CGFloat(value) * 150 - 20)
            }
            .frame(width: 150)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let width = 150.0
                        let x = value.location.x
                        let newValue = max(0, min(1, Float(x / width)))
                        self.value = newValue
                    }
            )
        }
    }
}

// Обновляем SettingsView
struct SettingsView: View {
    // Имена файлов изображений
    private let backgroundImageName = "SettingsBG" // Фон экрана настроек
    private let backButtonName = "BackButton"
    private let musicLabelName = "MusicLabel" // Лейбл для музыки
    private let soundLabelName = "SoundLabel" // Лейбл для звуков
    
    // Состояния для прогресс-баров
    @State private var musicVolume: Float = UserDefaults.standard.float(forKey: "musicVolume")
    @State private var soundVolume: Float = UserDefaults.standard.float(forKey: "soundVolume")
    
    // Добавляем ссылку на GameViewController
    var gameViewController: GameViewController
    var onBack: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom
            
            // Вычисляем оптимальные размеры на основе пропорций экрана
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let baseUnit = min(screenWidth, screenHeight)
            
            // Размеры элементов
            let headerButtonSize = baseUnit * (isIpad ? 0.12 : 0.15)
            let progressWidth = baseUnit * (isIpad ? 0.6 : 0.7)
            let progressBackgroundWidth = baseUnit * (isIpad ? 0.7 : 0.8) // Ширина фона прогресс-бара
            
            ZStack {
                // Фон
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Верхняя панель с кнопкой назад
                    HStack {
                        Button(action: {
                            gameViewController.playButtonSound() // Воспроизводим звук при нажатии
                            onBack()
                        }) {
                            Image(backButtonName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: headerButtonSize)
                        }
                        .padding(.leading, baseUnit * 0.06)
                        
                        Spacer()
                    }
                    .padding(.top, safeTop + baseUnit * 0.05)
                    
                    Spacer()
                    
                    // Настройки звука
                    VStack(spacing: baseUnit * 0.15) {
                        // Настройка музыки
                        CustomProgressView(value: $musicVolume, label: musicLabelName)
                            .frame(width: progressWidth)
                            .onChange(of: musicVolume) { newValue in
                                gameViewController.setMusicVolume(newValue)
                            }
                        
                        // Настройка звуков
                        CustomProgressView(value: $soundVolume, label: soundLabelName)
                            .frame(width: progressWidth)
                            .onChange(of: soundVolume) { newValue in
                                gameViewController.setSoundVolume(newValue)
                                gameViewController.playButtonSound() // Воспроизводим тестовый звук при изменении громкости
                            }
                    }
                    .padding(.bottom, baseUnit * 0.2)
                    
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Загружаем сохраненные настройки громкости при появлении экрана
            musicVolume = UserDefaults.standard.float(forKey: "musicVolume")
            soundVolume = UserDefaults.standard.float(forKey: "soundVolume")
        }
    }
}

// Представление для туториала
struct TutorialView: View {
    // Имена файлов изображений туториала
    private let tutorial1Name = "Tutorial1"
    private let tutorial2Name = "Tutorial2"
    private let tutorial3Name = "Tutorial3"
    
    @State private var currentStep = 0
    var onComplete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom
            
            // Вычисляем оптимальные размеры на основе пропорций экрана
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let isLandscape = screenWidth > screenHeight
            
            ZStack {
                // Адаптивный фон - масштабируется под разные устройства
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Показываем текущее изображение туториала
                Group {
                    if currentStep == 0 {
                        tutorialImage(name: tutorial1Name, screenWidth: screenWidth, 
                                      screenHeight: screenHeight, isLandscape: isLandscape)
                            .transition(.opacity)
                    } else if currentStep == 1 {
                        tutorialImage(name: tutorial2Name, screenWidth: screenWidth, 
                                      screenHeight: screenHeight, isLandscape: isLandscape)
                            .transition(.opacity)
                    } else if currentStep == 2 {
                        tutorialImage(name: tutorial3Name, screenWidth: screenWidth, 
                                      screenHeight: screenHeight, isLandscape: isLandscape)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: currentStep)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if currentStep < 2 {
                    currentStep += 1
                } else {
                    onComplete()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // Вспомогательная функция для адаптивного отображения изображений туториала
    private func tutorialImage(name: String, screenWidth: CGFloat, screenHeight: CGFloat, isLandscape: Bool) -> some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: isLandscape ? .fill : .fit)
            .frame(width: screenWidth, height: screenHeight)
            .clipped()
    }
}

class GameViewController: UIViewController {
    
    // Добавляем переменные для управления музыкой и звуком
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var buttonSoundPlayer: AVAudioPlayer?
    private var victorySound: AVAudioPlayer?
    private var starCollectSound: AVAudioPlayer?
    private var ballHitSound: AVAudioPlayer?
    private var currentVolume: Float = 0.5
    private var currentSoundVolume: Float = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Загружаем сохраненную громкость
        currentVolume = UserDefaults.standard.float(forKey: "musicVolume")
        currentSoundVolume = UserDefaults.standard.float(forKey: "soundVolume")
        
        if currentVolume == 0 {
            currentVolume = 0.5 // Значение по умолчанию
            UserDefaults.standard.set(currentVolume, forKey: "musicVolume")
        }
        
        if currentSoundVolume == 0 {
            currentSoundVolume = 0.5 // Значение по умолчанию
            UserDefaults.standard.set(currentSoundVolume, forKey: "soundVolume")
        }
        
        // Начинаем с экрана загрузки
        showLoadingScene()
        
        // Запускаем фоновую музыку
        playBackgroundMusic()
        
        // Подготавливаем звуки
        prepareButtonSound()
        prepareVictorySound()
        prepareStarCollectSound()
        prepareBallHitSound()
        
        // Настраиваем вид
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Подписываемся на уведомления
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(startGameFromNotification), 
            name: NSNotification.Name("StartGame"), 
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(returnToMainMenuFromNotification), 
            name: NSNotification.Name("ReturnToMainMenu"), 
            object: nil
        )
        
        // Добавляем обработчик для возврата к экрану выбора уровней
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(returnToLevelsViewFromNotification), 
            name: NSNotification.Name("ReturnToLevelsView"), 
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private func showLoadingScene() {
        let skView = self.view as! SKView
        
        // Создаем сцену загрузки вручную (без использования внешнего класса)
        let loadingScene = SKScene(size: view.bounds.size)
        loadingScene.scaleMode = .aspectFill
        loadingScene.backgroundColor = .black
        
        // Используем UIHostingController для интеграции SwiftUI
        let loadingScreenView = UIHostingController(rootView: LoadingScreenView { [weak self] in
            // Когда загрузка завершена, переходим к главному меню вместо игры
            self?.showMainMenuScene()
        })
        
        loadingScreenView.view.frame = view.bounds
        loadingScreenView.view.backgroundColor = UIColor.clear
        
        // Добавляем SwiftUI представление
        skView.addSubview(loadingScreenView.view)
        
        // Показываем базовую сцену
        skView.presentScene(loadingScene)
    }

    private func showMainMenuScene() {
        let skView = self.view as! SKView
        
        // Создаем сцену главного меню
        let mainMenuScene = MainMenuScene.newMainMenuScene(size: view.bounds.size)
        
        // Применяем переход между сценами
        let transition = SKTransition.fade(withDuration: 1.0)
        
        // Показываем сцену главного меню
        skView.presentScene(mainMenuScene, transition: transition)
        
        // Удаляем SwiftUI представление загрузочного экрана
        for subview in skView.subviews {
            if subview is UIView {
                subview.removeFromSuperview()
            }
        }
        
        // Создаем SwiftUI представление для главного меню
        DispatchQueue.main.async {
            let menuView = UIHostingController(rootView: FallbackView(
                onPlayTapped: { [weak self] in
                    self?.showLevelsScene()
                },
                onShopTapped: { [weak self] in
                    self?.showShopScene()
                },
                onAchievesTapped: { [weak self] in
                    self?.showAchievesScene()
                },
                onSettingsTapped: { [weak self] in
                    self?.showSettingsScene()
                },
                gameViewController: self
            ))
            menuView.view.frame = self.view.bounds
            menuView.view.backgroundColor = UIColor.clear
            skView.addSubview(menuView.view)
        }
    }

    private func showLevelsScene() {
        let skView = self.view as! SKView
        
        // Создаем сцену уровней
        let levelsScene = SKScene(size: view.bounds.size)
        levelsScene.scaleMode = .aspectFill
        
        // Создаем SwiftUI view для уровней
        let levelsView = LevelsView(
            onBack: { [weak self] in
                self?.showMainMenuScene()
            },
            onStartLevel: { [weak self] level in
                if level == -1 {
                    // Показываем туториал
                    self?.showTutorial()
                } else {
                    self?.startGame(level: level)
                }
            }
        )
        
        // Интегрируем SwiftUI в SpriteKit
        let levelsVC = UIHostingController(rootView: levelsView)
        levelsVC.view.frame = view.bounds
        levelsVC.view.backgroundColor = .clear
        
        // Удаляем предыдущие SwiftUI views
        skView.subviews.forEach { $0.removeFromSuperview() }
        
        // Добавляем новую SwiftUI view
        skView.addSubview(levelsVC.view)
        
        // Показываем сцену
        skView.presentScene(levelsScene)
    }

    @objc private func handleNextButtonTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let skView = self.view as! SKView
        let sceneLocation = skView.scene?.convertPoint(fromView: location)
        
        if let node = skView.scene?.nodes(at: sceneLocation ?? .zero).first,
           node.name == "nextButton" {
            // Действие при нажатии на кнопку next
            print("Next button tapped")
        }
    }

    @objc private func startGameFromNotification() {
        startGame(level: 1)
    }

    @objc private func returnToMainMenuFromNotification() {
        showMainMenuScene()
    }

    @objc private func returnToLevelsViewFromNotification() {
        showLevelsScene()
    }

    private func startGame(level: Int) {
        showGameScene(level: level)
    }

    private func showGameScene(level: Int) {
        let skView = self.view as! SKView
        
        // Создаем игровую сцену
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        scene.currentLevel = level // Устанавливаем уровень
        
        // Сбрасываем количество собранных звезд
        scene.starsCollected = 0
        
        // Проверяем, активирован ли первый элемент в магазине
        let isElement1Active = UserDefaults.standard.bool(forKey: "isElement1Active")
        scene.ballImageName = isElement1Active ? "BallSkin" : "Ball" // Устанавливаем имя изображения шарика
        
        // Применяем переход между сценами
        let transition = SKTransition.fade(withDuration: 1.0)
        
        // Показываем игровую сцену
        skView.presentScene(scene, transition: transition)
        
        // Удаляем SwiftUI представления
        for subview in skView.subviews {
            subview.removeFromSuperview()
        }
    }

    private func showShopScene() {
        let skView = self.view as! SKView
        
        // Создаем сцену магазина
        let shopScene = SKScene(size: view.bounds.size)
        shopScene.scaleMode = .aspectFill
        
        // Создаем SwiftUI view для магазина
        let shopView = ShopView(
            onBack: { [weak self] in
                self?.showMainMenuScene()
            }
        )
        
        // Интегрируем SwiftUI в SpriteKit
        let shopVC = UIHostingController(rootView: shopView)
        shopVC.view.frame = view.bounds
        shopVC.view.backgroundColor = .clear
        
        // Удаляем предыдущие SwiftUI views
        skView.subviews.forEach { $0.removeFromSuperview() }
        
        // Добавляем новую SwiftUI view
        skView.addSubview(shopVC.view)
        
        // Показываем сцену
        skView.presentScene(shopScene)
    }

    private func showAchievesScene() {
        let skView = self.view as! SKView
        
        // Создаем сцену достижений
        let achievesScene = SKScene(size: view.bounds.size)
        achievesScene.scaleMode = .aspectFill
        
        // Создаем SwiftUI view для достижений
        let achievesView = AchievesView(
            onBack: { [weak self] in
                self?.showMainMenuScene()
            }
        )
        
        // Интегрируем SwiftUI в SpriteKit
        let achievesVC = UIHostingController(rootView: achievesView)
        achievesVC.view.frame = view.bounds
        achievesVC.view.backgroundColor = .clear
        
        // Удаляем предыдущие SwiftUI views
        skView.subviews.forEach { $0.removeFromSuperview() }
        
        // Добавляем новую SwiftUI view
        skView.addSubview(achievesVC.view)
        
        // Показываем сцену
        skView.presentScene(achievesScene)
    }

    private func showSettingsScene() {
        let skView = self.view as! SKView
        
        // Создаем сцену настроек
        let settingsScene = SKScene(size: view.bounds.size)
        settingsScene.scaleMode = .aspectFill
        
        // Создаем SwiftUI view для настроек
        let settingsView = SettingsView(
            gameViewController: self,
            onBack: { [weak self] in
                self?.showMainMenuScene()
            }
        )
        
        // Интегрируем SwiftUI в SpriteKit
        let settingsVC = UIHostingController(rootView: settingsView)
        settingsVC.view.frame = view.bounds
        settingsVC.view.backgroundColor = .clear
        
        // Удаляем предыдущие SwiftUI views
        skView.subviews.forEach { $0.removeFromSuperview() }
        
        // Добавляем новую SwiftUI view
        skView.addSubview(settingsVC.view)
        
        // Показываем сцену
        skView.presentScene(settingsScene)
    }

    private func showTutorial() {
        let skView = self.view as! SKView
        
        // Создаем базовую сцену
        let tutorialScene = SKScene(size: view.bounds.size)
        tutorialScene.scaleMode = .aspectFill
        
        // Создаем SwiftUI view для туториала
        let tutorialView = TutorialView(onComplete: { [weak self] in
            // После завершения туториала запускаем первый уровень
            self?.startGame(level: 1)
        })
        
        // Интегрируем SwiftUI в SpriteKit
        let tutorialVC = UIHostingController(rootView: tutorialView)
        tutorialVC.view.frame = view.bounds
        tutorialVC.view.backgroundColor = .clear
        
        // Удаляем предыдущие SwiftUI views
        skView.subviews.forEach { $0.removeFromSuperview() }
        
        // Добавляем новую SwiftUI view
        skView.addSubview(tutorialVC.view)
        
        // Показываем сцену
        skView.presentScene(tutorialScene)
    }

    // Добавляем методы для управления музыкой
    private func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") else {
            print("Не удалось найти файл музыки")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Бесконечное повторение
            backgroundMusicPlayer?.volume = currentVolume
            backgroundMusicPlayer?.play()
        } catch {
            print("Не удалось воспроизвести музыку: \(error.localizedDescription)")
        }
    }
    
    func setMusicVolume(_ volume: Float) {
        currentVolume = volume
        backgroundMusicPlayer?.volume = volume
        UserDefaults.standard.set(volume, forKey: "musicVolume")
    }
    
    private func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }

    // Добавляем методы для управления звуком
    private func prepareButtonSound() {
        guard let url = Bundle.main.url(forResource: "buttonClick", withExtension: "mp3") else {
            print("Не удалось найти файл звука кнопки")
            return
        }
        
        do {
            buttonSoundPlayer = try AVAudioPlayer(contentsOf: url)
            buttonSoundPlayer?.volume = currentSoundVolume
            buttonSoundPlayer?.prepareToPlay()
        } catch {
            print("Не удалось подготовить звук кнопки: \(error.localizedDescription)")
        }
    }
    
    func playButtonSound() {
        buttonSoundPlayer?.play()
        buttonSoundPlayer?.currentTime = 0
    }
    
    // Добавляем методы для звука победы
    private func prepareVictorySound() {
        guard let url = Bundle.main.url(forResource: "victory", withExtension: "mp3") else {
            print("Не удалось найти файл звука победы")
            return
        }
        
        do {
            victorySound = try AVAudioPlayer(contentsOf: url)
            victorySound?.volume = currentSoundVolume
            victorySound?.prepareToPlay()
        } catch {
            print("Не удалось подготовить звук победы: \(error.localizedDescription)")
        }
    }
    
    func playVictorySound() {
        victorySound?.play()
        victorySound?.currentTime = 0
    }

    // Добавляем методы для звука сбора звездочки
    private func prepareStarCollectSound() {
        guard let url = Bundle.main.url(forResource: "star_collect", withExtension: "mp3") else {
            print("Не удалось найти файл звука сбора звездочки")
            return
        }
        
        do {
            starCollectSound = try AVAudioPlayer(contentsOf: url)
            starCollectSound?.volume = currentSoundVolume
            starCollectSound?.prepareToPlay()
        } catch {
            print("Не удалось подготовить звук сбора звездочки: \(error.localizedDescription)")
        }
    }
    
    func playStarCollectSound() {
        starCollectSound?.play()
        starCollectSound?.currentTime = 0
    }

    // Добавляем методы для звука удара мяча
    private func prepareBallHitSound() {
        guard let url = Bundle.main.url(forResource: "ball_hit", withExtension: "mp3") else {
            print("Не удалось найти файл звука удара мяча")
            return
        }
        
        do {
            ballHitSound = try AVAudioPlayer(contentsOf: url)
            ballHitSound?.volume = currentSoundVolume
            ballHitSound?.prepareToPlay()
        } catch {
            print("Не удалось подготовить звук удара мяча: \(error.localizedDescription)")
        }
    }
    
    func playBallHitSound() {
        ballHitSound?.play()
        ballHitSound?.currentTime = 0
    }
    
    func setSoundVolume(_ volume: Float) {
        currentSoundVolume = volume
        buttonSoundPlayer?.volume = volume
        victorySound?.volume = volume
        starCollectSound?.volume = volume
        ballHitSound?.volume = volume
        UserDefaults.standard.set(volume, forKey: "soundVolume")
    }
}

// SwiftUI представление для экрана загрузки
struct LoadingScreenView: View {
    @State private var isLoading = true
    @State private var loadingProgress: CGFloat = 0.0
    
    // Обработчик завершения загрузки
    var onComplete: (() -> Void)
    
    // Имя файла изображения фона
    private let backgroundImageName = "LoadingBackground"
    
    // Для анимации загрузки
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let safeBottom = geometry.safeAreaInsets.bottom
            
            // Вычисляем оптимальные размеры на основе пропорций экрана
            let isIpad = UIDevice.current.userInterfaceIdiom == .pad
            let isLandscape = screenWidth > screenHeight
            let baseUnit = min(screenWidth, screenHeight) / (isIpad ? 10 : 8)
            
            // Размеры элементов
            let progressBarWidth = baseUnit * (isIpad ? 6.0 : 5.0) * (isLandscape ? 1.2 : 1.0)
            let progressBarHeight = baseUnit * 0.15
            let bottomPadding = safeBottom + baseUnit * (isIpad ? 0.8 : 1.0)
            
            ZStack {
                // Фоновое изображение
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth, height: screenHeight)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    // Прогресс-бар (узкий, внизу экрана)
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: progressBarWidth, height: progressBarHeight)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                            .cornerRadius(progressBarHeight / 2)
                        
                        Rectangle()
                            .frame(width: progressBarWidth * loadingProgress, height: progressBarHeight)
                            .foregroundColor(.white)
                            .cornerRadius(progressBarHeight / 2)
                    }
                    .padding(.bottom, bottomPadding)
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(timer) { _ in
            // Симулируем процесс загрузки
            if loadingProgress < 1.0 {
                loadingProgress += 0.05
            } else {
                isLoading = false
                timer.upstream.connect().cancel()
                // Вызываем колбэк завершения загрузки
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
}

// Класс сцены главного меню
class MainMenuScene: SKScene {
    // Метод для создания новой сцены главного меню
    static func newMainMenuScene(size: CGSize) -> MainMenuScene {
        let scene = MainMenuScene(size: size)
        scene.scaleMode = .aspectFill
        return scene
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        // Оставляем сцену пустой, SwiftUI компонент будет добавлен через GameViewController
    }
}

// Обновляем FallbackView, добавляя колбэк для кнопки Achieves
struct FallbackView: View {
    // Имена файлов изображений
    private let backgroundImageName = "MainBackground"
    private let settingsIconName = "SettingsIcon"
    private let coinIconName = "CoinIcon"
    private let playButtonName = "PlayButton"
    private let shopButtonName = "ShopButton"
    private let achievesButtonName = "AchievesButton"
    
    // Колбэки для кнопок
    var onPlayTapped: () -> Void
    var onShopTapped: () -> Void
    var onAchievesTapped: () -> Void
    var onSettingsTapped: () -> Void
    
    // Добавляем ссылку на GameViewController
    var gameViewController: GameViewController
    
    @State private var totalCoins = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Фоновое изображение
                Image(backgroundImageName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Верхняя панель
                    HStack {
                        // Иконка настроек
                        Button(action: {
                            gameViewController.playButtonSound()
                            onSettingsTapped()
                        }) {
                            Image(settingsIconName)
                                .resizable()
                                .frame(width: geometry.size.width * 0.12, height: geometry.size.width * 0.12)
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        // Счетчик монет
                        Image(coinIconName)
                            .resizable()
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.width * 0.12)
                            .overlay(
                                Text("\(totalCoins)")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: geometry.size.width * 0.06, weight: .bold))
                                    .padding(.leading, geometry.size.width * 0.07)
                                    .padding(.bottom, 5)
                                , alignment: .center
                            )
                            .padding(.trailing)
                    }
                    .padding(.top, geometry.safeAreaInsets.top + 10)
                    
                    Spacer()
                    
                    // Кнопки меню
                    VStack(spacing: geometry.size.height * 0.02) {
                        Spacer()
                        // Кнопка Play
                        Button(action: {
                            gameViewController.playButtonSound()
                            onPlayTapped()
                        }) {
                            Image(playButtonName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.5)
                        }
                        
                        // Кнопка Shop
                        Button(action: {
                            gameViewController.playButtonSound()
                            onShopTapped()
                        }) {
                            Image(shopButtonName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.5)
                        }
                        
                        // Кнопка Achieves
                        Button(action: {
                            gameViewController.playButtonSound()
                            onAchievesTapped()
                        }) {
                            Image(achievesButtonName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.5)
                        }
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    
                    Spacer()
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            totalCoins = UserDefaults.standard.integer(forKey: "totalCoins")
        }
    }
}
