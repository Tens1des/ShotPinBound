//
//  GameScene.swift
//  ShotPinBound Shared
//
//  Created by Рома Котов on 07.04.2025.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Категории физических объектов
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let ball      : UInt32 = 0b1
        static let wall      : UInt32 = 0b10
        static let deadWall  : UInt32 = 0b100
        static let star      : UInt32 = 0b1000
        static let ground    : UInt32 = 0b10000
        static let finishLine: UInt32 = 0b100000
    }
    
    // MARK: - Игровые элементы
    private var ball: SKSpriteNode!
    private var platform: SKSpriteNode!
    private var ground: SKSpriteNode!
    private var finishLine: SKSpriteNode!
    private var topBar: SKSpriteNode!
    private var pauseButton: SKSpriteNode!
    private var trajectory: SKShapeNode!
    private var shotsPanel: SKSpriteNode! // Панель для отображения выстрелов
    private var starsCountNode: SKSpriteNode! // Панель для отображения звезд
    private var shotsCountLabel: SKLabelNode! // Текст для отображения количества выстрелов
    private var starsCountLabel: SKLabelNode! // Текст для отображения количества звезд
    
    // MARK: - Игровые переменные
    public var currentLevel: Int = 1
    public var ballImageName: String = "Ball"
    private var shotsRemaining: Int = 3
    public var starsCollected: Int = 0
    private var isAiming: Bool = false
    private var startPosition: CGPoint = .zero
    private var maxPower: CGFloat = 100.0
    private var isBallMoving: Bool = false
    private var stars: [SKSpriteNode] = []
    private var isGameRunning: Bool = false
    private var canShoot: Bool = true
    
    // MARK: - Жизненный цикл сцены
    override func didMove(to view: SKView) {
        // Настройка физики
        updateGravityForLevel()
        physicsWorld.contactDelegate = self
        
        // Настройка фона
        setupBackground()
        
        // Настройка элементов интерфейса
        setupUI()
        
        // Настройка игровых объектов
        setupGameObjects()
        
        // Определяем и настраиваем выбранный уровень
        setupLevel(level: currentLevel)
    }
    
    // Метод для настройки гравитации в зависимости от уровня
    private func updateGravityForLevel() {
        if currentLevel == 1 {
            // Стандартная гравитация для первого уровня
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        } else if currentLevel == 2 {
            // Слегка измененная гравитация для второго уровня - более "легкий" мир
            physicsWorld.gravity = CGVector(dx: 0, dy: -8.5)
        } else if currentLevel == 3 {
            // Усиленная гравитация для третьего уровня - более "тяжелый" мир
            physicsWorld.gravity = CGVector(dx: 0, dy: -10.5)
        }
    }
    
    // MARK: - Настройка сцены
    private func setupBackground() {
        // Выбираем бэкграунд в зависимости от уровня
        let backgroundImageName: String
        if currentLevel == 1 {
            backgroundImageName = "GameBG"
        } else if currentLevel == 2 {
            backgroundImageName = "GameBG2"
        } else {
            backgroundImageName = "GameBG" // Для 3 уровня можно использовать тот же фон, что и для 1
        }
        
        let background = SKSpriteNode(imageNamed: backgroundImageName)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -10
        addChild(background)
        
        // Выбираем пол в зависимости от уровня
        let groundImageName: String
        if currentLevel == 1 {
            groundImageName = "Ground"
        } else if currentLevel == 2 {
            groundImageName = "Ground2"
        } else {
            groundImageName = "Ground" // Для 3 уровня можно использовать тот же пол, что и для 1
        }
        
        ground = SKSpriteNode(imageNamed: groundImageName)
        ground.position = CGPoint(x: frame.midX, y: ground.size.height / 2)
        ground.zPosition = -5
        ground.size = CGSize(width: frame.width, height: 100)
        
        // Физика для земли
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        ground.physicsBody?.collisionBitMask = PhysicsCategory.ball
        
        addChild(ground)
    }
    
    private func setupUI() {
        // Добавляем верхнюю панель
        topBar = SKSpriteNode(imageNamed: "TopPanel")
        // Делаем панель шире (95% от ширины экрана)
        let panelWidth = frame.width * 0.95
        // Увеличиваем высоту панели
        let panelHeight: CGFloat = 80
        topBar.size = CGSize(width: panelWidth, height: panelHeight)
        // Располагаем панель с учетом safeArea
        let safeAreaTop = (view?.safeAreaInsets.top ?? 0)
        topBar.position = CGPoint(x: frame.midX, y: frame.height - safeAreaTop - panelHeight/2)
        topBar.zPosition = 10
        addChild(topBar)
        
        // Кнопка паузы (слева на панели)
        pauseButton = SKSpriteNode(imageNamed: "PauseButton")
        pauseButton.size = CGSize(width: 50, height: 50)
        pauseButton.position = CGPoint(x: topBar.frame.minX + 40, y: topBar.position.y)
        pauseButton.zPosition = 11
        pauseButton.name = "pauseButton"
        addChild(pauseButton)
        
        // Панель для отображения звезд (в центре)
        starsCountNode = SKSpriteNode(imageNamed: "Star")
        starsCountNode.size = CGSize(width: 40, height: 40)
        starsCountNode.position = CGPoint(x: frame.midX - 20, y: topBar.position.y)
        starsCountNode.zPosition = 11
        addChild(starsCountNode)
        
        // Текст количества собранных звезд (рядом со звездой)
        starsCountLabel = SKLabelNode(fontNamed: "Arial-Bold")
        starsCountLabel.text = "0/3"
        starsCountLabel.fontSize = 24
        starsCountLabel.fontColor = .yellow
        starsCountLabel.position = CGPoint(x: frame.midX + 20, y: topBar.position.y - 8)
        starsCountLabel.zPosition = 11
        addChild(starsCountLabel)
        
        // Панель для отображения выстрелов (справа)
        shotsPanel = SKSpriteNode(imageNamed: "ShotsPanel")
        shotsPanel.size = CGSize(width: 60, height: 60)
        shotsPanel.position = CGPoint(x: topBar.frame.maxX - 60, y: topBar.position.y)
        shotsPanel.zPosition = 11
        addChild(shotsPanel)
        
        // Текст количества выстрелов
        shotsCountLabel = SKLabelNode(fontNamed: "Arial-Bold")
        shotsCountLabel.text = "\(shotsRemaining)"
        shotsCountLabel.fontSize = 24
        shotsCountLabel.fontColor = .white
        shotsCountLabel.position = CGPoint(x: shotsPanel.position.x, y: shotsPanel.position.y - 8)
        shotsCountLabel.zPosition = 12
        addChild(shotsCountLabel)
    }
    
    private func setupGameObjects() {
        // Создание платформы
        platform = SKSpriteNode(imageNamed: "Platform")
        platform.position = CGPoint(x: 40, y: ground.position.y + ground.size.height / 2 + platform.size.height / 2 + 120)
        platform.zPosition = 1
        platform.size = CGSize(width: 60, height: 20)
        addChild(platform)
        
        // Создание мяча с выбранным скином
        ball = SKSpriteNode(imageNamed: ballImageName)
        ball.position = CGPoint(x: platform.position.x, y: platform.position.y + platform.size.height / 2 + ball.size.height / 2)
        ball.zPosition = 2
        ball.size = CGSize(width: 30, height: 30)
        resetBall()
        
        // Добавление финишной линии
        finishLine = SKSpriteNode(imageNamed: "FinishLine")
        
        // Рассчитываем высоту от пола до верха экрана
        let heightAboveGround = frame.height - ground.position.y - ground.size.height / 2
        
        // Размещаем финишную линию вплотную к правому краю экрана
        finishLine.position = CGPoint(x: frame.width - finishLine.size.width / 2, y: ground.position.y + ground.size.height / 2 + heightAboveGround / 2)
        finishLine.zPosition = 1
        finishLine.size = CGSize(width: 30, height: heightAboveGround)
        finishLine.name = "finishLine"
        
        // Физика для финишной линии
        finishLine.physicsBody = SKPhysicsBody(rectangleOf: finishLine.size)
        finishLine.physicsBody?.isDynamic = false
        finishLine.physicsBody?.categoryBitMask = PhysicsCategory.finishLine
        finishLine.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        finishLine.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(finishLine)
        
        // Создание линии траектории
        trajectory = SKShapeNode()
        trajectory.strokeColor = .white
        trajectory.lineWidth = 2 // Увеличиваем толщину линии с 1 до 2
        trajectory.alpha = 0.7 // Увеличиваем прозрачность с 0.3 до 0.7
        trajectory.zPosition = 1
        addChild(trajectory)
    }
    
    // MARK: - Настройка уровней
    private func setupLevel(level: Int) {
        // Сохраняем значение текущего уровня
        currentLevel = level
        
        // Обновляем фон и пол для соответствия текущему уровню
        updateBackgroundAndGround()
        
        // Обновляем гравитацию для соответствия выбранному уровню
        updateGravityForLevel()
        
        // Удаление предыдущих элементов уровня
        removeWalls()
        removeStars()
        
        // Настройка количества выстрелов
        // Для первого уровня: 3 взаимодействия с мячом (включая первый выстрел)
        // Для остальных уровней: level + 2 выстрела
        shotsRemaining = level == 1 ? 3 : level + 2
        
        // Обнуляем собранные звезды при начале уровня
        starsCollected = 0
        
        // Проверяем, есть ли сохраненные препятствия для этого уровня
        let wallsKey = "wallsForLevel\(level)"
        let starsKey = "starPositionsForLevel\(level)"
        
        // Проверяем есть ли в UserDefaults сохраненные данные для этого уровня
        if let wallsData = UserDefaults.standard.array(forKey: wallsKey) as? [[String: Any]], !wallsData.isEmpty {
            // Создаем стены из сохраненных данных
            for wallInfo in wallsData {
                if let positionDict = wallInfo["position"] as? [String: CGFloat],
                   let sizeDict = wallInfo["size"] as? [String: CGFloat],
                   let isDead = wallInfo["isDead"] as? Bool {
                    
                    let position = CGPoint(x: positionDict["x"] ?? 0, y: positionDict["y"] ?? 0)
                    let size = CGSize(width: sizeDict["width"] ?? 30, height: sizeDict["height"] ?? 100)
                    
                    createWall(position: position, size: size, isDead: isDead)
                }
            }
            
            // Проверяем наличие финишной линии
            if !children.contains(where: { $0.name == "finishLine" }) {
                // Добавляем финишную линию справа
                let gameHeight = frame.height - ground.position.y - ground.size.height / 2
                finishLine.position = CGPoint(x: frame.width - finishLine.size.width / 2, y: ground.position.y + ground.size.height / 2 + gameHeight / 2)
                
                if finishLine.parent == nil {
                    addChild(finishLine)
                }
            }
            
            // Загружаем сохраненные позиции звезд
            if let starsData = UserDefaults.standard.array(forKey: starsKey) as? [[String: CGFloat]], !starsData.isEmpty {
                for starInfo in starsData {
                    let position = CGPoint(x: starInfo["x"] ?? 0, y: starInfo["y"] ?? 0)
                    createStar(position: position)
                }
            }
        } else {
            // Создаем уровень с нуля
            if level == 1 {
                setupLevel1()
            } else if level == 2 {
                setupLevel2()
            } else if level == 3 {
                setupLevel3()
            } else if level == 4 {
                setupLevel4()
            }
            
            // Сохраняем позиции стен для будущего использования
            saveWalls()
            // Сохраняем начальные позиции звезд
            saveStarsPositions()
        }
        
        // Сброс мяча на начальную позицию
        resetBall()
    }
    
    // Метод для обновления фона и пола при смене уровня
    private func updateBackgroundAndGround() {
        // Удаляем текущий фон
        for child in children {
            if child.zPosition == -10 {
                child.removeFromParent()
            }
        }
        
        // Удаляем текущий пол
        if ground.parent != nil {
            ground.removeFromParent()
        }
        
        // Выбираем бэкграунд в зависимости от уровня
        let backgroundImageName: String
        if currentLevel == 1 {
            backgroundImageName = "GameBG"
        } else if currentLevel == 2 {
            backgroundImageName = "GameBG2"
        } else {
            backgroundImageName = "GameBG" // Для 3 уровня можно использовать тот же фон, что и для 1
        }
        
        let background = SKSpriteNode(imageNamed: backgroundImageName)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -10
        addChild(background)
        
        // Выбираем пол в зависимости от уровня
        let groundImageName: String
        if currentLevel == 1 {
            groundImageName = "Ground"
        } else if currentLevel == 2 {
            groundImageName = "Ground2"
        } else {
            groundImageName = "Ground" // Для 3 уровня можно использовать тот же пол, что и для 1
        }
        
        ground = SKSpriteNode(imageNamed: groundImageName)
        ground.position = CGPoint(x: frame.midX, y: ground.size.height / 2)
        ground.zPosition = -5
        ground.size = CGSize(width: frame.width, height: 100)
        
        // Физика для земли
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        ground.physicsBody?.collisionBitMask = PhysicsCategory.ball
        
        addChild(ground)
    }
    
    private func setupLevel1() {
        // Удаление предыдущих элементов уровня
        removeWalls()
        removeStars()
        
        // Начальный уровень после туториала
        
        // Размещаем мяч и платформу еще левее и значительно выше
        platform.position = CGPoint(x: 40, y: ground.position.y + ground.size.height / 2 + platform.size.height / 2 + 120)
        resetBall()
        
        // Получаем высоту игрового поля от земли
        let gameHeight = frame.height - ground.position.y - ground.size.height / 2
        
        // Создаем верхние фиолетовые стены, свисающие сверху (как на фото)
        // Левая верхняя стена
        let topWall1 = createWall(position: CGPoint(x: frame.width * 0.2, y: frame.height - 120), 
                                 size: CGSize(width: 30, height: 240), 
                                 isDead: false)
        
        // Центральная верхняя стена
        let topWall2 = createWall(position: CGPoint(x: frame.width * 0.5, y: frame.height - 80), 
                                 size: CGSize(width: 30, height: 160), 
                                 isDead: false)
        
        // Правая верхняя стена
        let topWall3 = createWall(position: CGPoint(x: frame.width * 0.8, y: frame.height - 120), 
                                 size: CGSize(width: 30, height: 240), 
                                 isDead: false)
        
        // Создаем нижние фиолетовые стены
        // Левая нижняя стена
        let bottomWall1 = createWall(position: CGPoint(x: frame.width * 0.25, y: ground.position.y + ground.size.height / 2 + 80), 
                                    size: CGSize(width: 30, height: 160), 
                                    isDead: false)
        
        // Правая нижняя стена
        let bottomWall2 = createWall(position: CGPoint(x: frame.width * 0.75, y: ground.position.y + ground.size.height / 2 + 80), 
                                    size: CGSize(width: 30, height: 160), 
                                    isDead: false)
        
        // Красная стена посередине (смертельная)
        let deadWall = createWall(position: CGPoint(x: frame.midX, y: ground.position.y + ground.size.height / 2 + 120), 
                                 size: CGSize(width: 30, height: 240), 
                                 isDead: true)
        
        // Создаем звезды для сбора как на фото
        // Верхняя звезда (центр) - поднимаем выше
        createStar(position: CGPoint(x: frame.midX, y: frame.height - 250))
        
        // Левая нижняя звезда - поднимаем выше
        createStar(position: CGPoint(x: frame.width * 0.25, y: gameHeight * 0.5))
        
        // Правая нижняя звезда - поднимаем выше
        createStar(position: CGPoint(x: frame.width * 0.75, y: gameHeight * 0.5))
        
        // Добавляем финишную линию справа
        finishLine.position = CGPoint(x: frame.width - finishLine.size.width / 2, y: ground.position.y + ground.size.height / 2 + gameHeight / 2)
        if finishLine.parent == nil {
            addChild(finishLine)
        }
    }
    
    private func setupLevel2() {
        // Удаление предыдущих элементов уровня
        removeWalls()
        removeStars()
        
        // Начальный второй уровень с новым дизайном
        
        // Размещаем мяч и платформу чуть правее чем на первом уровне
        platform.position = CGPoint(x: 60, y: ground.position.y + ground.size.height / 2 + platform.size.height / 2 + 100)
        resetBall()
        
        // Получаем высоту игрового поля от земли
        let gameHeight = frame.height - ground.position.y - ground.size.height / 2
        
        // Создаем сложную конфигурацию стен для второго уровня
        
        // Центральная высокая стена
        let centralWall = createWall(position: CGPoint(x: frame.midX, y: ground.position.y + ground.size.height / 2 + 220), 
                                   size: CGSize(width: 40, height: 440), 
                                   isDead: false)
        
        // Верхние стены справа
        let topRightWall1 = createWall(position: CGPoint(x: frame.width * 0.7, y: frame.height - 100), 
                                     size: CGSize(width: 40, height: 200), 
                                     isDead: false)
        
        let topRightWall2 = createWall(position: CGPoint(x: frame.width * 0.85, y: frame.height - 150), 
                                     size: CGSize(width: 40, height: 300), 
                                     isDead: false)
        
        // Смертельная стена слева от центральной
        let deadWallLeft = createWall(position: CGPoint(x: frame.width * 0.3, y: ground.position.y + ground.size.height / 2 + 150), 
                                    size: CGSize(width: 40, height: 300), 
                                    isDead: true)
        
        // Нижние стены
        let bottomRightWall = createWall(position: CGPoint(x: frame.width * 0.7, y: ground.position.y + ground.size.height / 2 + 80), 
                                       size: CGSize(width: 40, height: 160), 
                                       isDead: false)
        
        // Смертельная нижняя стена для усложнения прохождения
        let deadBottomWall = createWall(position: CGPoint(x: frame.width * 0.85, y: ground.position.y + ground.size.height / 2 + 80), 
                                      size: CGSize(width: 40, height: 160), 
                                      isDead: true)
        
        // Создаем звезды для сбора (более сложное расположение)
        // Первая звезда над смертельной стеной слева
        createStar(position: CGPoint(x: frame.width * 0.3, y: gameHeight * 0.7))
        
        // Вторая звезда над центральной стеной - поднимаем выше
        createStar(position: CGPoint(x: frame.midX, y: frame.height - 100))
        
        // Третья звезда в сложном месте между стенами справа
        createStar(position: CGPoint(x: frame.width * 0.77, y: gameHeight * 0.5))
        
        // Добавляем финишную линию справа
        finishLine.position = CGPoint(x: frame.width - finishLine.size.width / 2, y: ground.position.y + ground.size.height / 2 + gameHeight / 2)
        if finishLine.parent == nil {
            addChild(finishLine)
        }
    }
    
    // Метод для создания третьего уровня
    private func setupLevel3() {
        // Удаление предыдущих элементов уровня
        removeWalls()
        removeStars()
        
        // Получаем высоту игрового поля от земли
        let gameHeight = frame.height - ground.position.y - ground.size.height / 2
        
        // Размещаем мяч и платформу похоже на второй уровень
        platform.position = CGPoint(x: 60, y: ground.position.y + ground.size.height / 2 + platform.size.height / 2 + 100)
        resetBall()
        
        // Создаем конфигурацию стен похожую на второй уровень, но с модификациями
        
        // Центральная стена - базовый элемент дизайна, как на втором уровне
        let centralWall = createWall(position: CGPoint(x: frame.midX, y: ground.position.y + ground.size.height / 2 + 220), 
                                   size: CGSize(width: 40, height: 440), 
                                   isDead: false)
        
        // Верхние стены справа
        let topRightWall1 = createWall(position: CGPoint(x: frame.width * 0.7, y: frame.height - 100), 
                                     size: CGSize(width: 40, height: 200), 
                                     isDead: false)
        
        let topRightWall2 = createWall(position: CGPoint(x: frame.width * 0.85, y: frame.height - 150), 
                                     size: CGSize(width: 40, height: 300), 
                                     isDead: false)
        
        // Смертельная стена слева от центральной - удалена
        
        // Нижние стены
        let bottomRightWall = createWall(position: CGPoint(x: frame.width * 0.7, y: ground.position.y + ground.size.height / 2 + 80), 
                                       size: CGSize(width: 40, height: 160), 
                                       isDead: false)
        
        // Смертельная нижняя стена для усложнения прохождения
        let deadBottomWall = createWall(position: CGPoint(x: frame.width * 0.85, y: ground.position.y + ground.size.height / 2 + 80), 
                                      size: CGSize(width: 40, height: 160), 
                                      isDead: true)
        
        // Дополнительные препятствия для третьего уровня
        let topLeftWall = createWall(position: CGPoint(x: frame.width * 0.15, y: frame.height - 120), 
                                   size: CGSize(width: 40, height: 240), 
                                   isDead: false)
        
        // Создаем звезды для сбора (более сложное расположение)
        // Первая звезда над смертельной стеной слева (переместим ее, так как стены больше нет)
        createStar(position: CGPoint(x: frame.width * 0.3, y: gameHeight * 0.6))
        
        // Вторая звезда над центральной стеной - поднимаем выше
        createStar(position: CGPoint(x: frame.midX, y: frame.height - 100))
        
        // Третья звезда в сложном месте между стенами справа
        createStar(position: CGPoint(x: frame.width * 0.77, y: gameHeight * 0.5))
        
        // Добавляем финишную линию справа
        finishLine.position = CGPoint(x: frame.width - finishLine.size.width / 2, y: ground.position.y + ground.size.height / 2 + gameHeight / 2)
        if finishLine.parent == nil {
            addChild(finishLine)
        }
    }
    
    // Метод для создания четвертого уровня
    private func setupLevel4() {
        // Удаление предыдущих элементов уровня
        removeWalls()
        removeStars()
        
        // Получаем высоту игрового поля от земли
        let gameHeight = frame.height - ground.position.y - ground.size.height / 2
        
        // Размещаем мяч и платформу в начальной позиции
        platform.position = CGPoint(x: 50, y: ground.position.y + ground.size.height / 2 + platform.size.height / 2 + 90)
        resetBall()
        
        // Создаем вертикальные препятствия
        
        // Центральная высокая фиолетовая стена
        let centerWall = createWall(position: CGPoint(x: frame.width * 0.5, y: ground.position.y + ground.size.height / 2 + 220), 
                                  size: CGSize(width: 40, height: 440), 
                                  isDead: false)
        
        // Правая высокая фиолетовая стена
        let rightWall = createWall(position: CGPoint(x: frame.width * 0.8, y: ground.position.y + ground.size.height / 2 + 220), 
                                 size: CGSize(width: 40, height: 440), 
                                 isDead: false)
        
        // Правая нижняя красная стена
        let rightDeadWall = createWall(position: CGPoint(x: frame.width * 0.65, y: ground.position.y + ground.size.height / 2 + 120), 
                                     size: CGSize(width: 40, height: 240), 
                                     isDead: true)
        
        // Создаем звезды
        // Первая звезда - над местом, где была левая красная стена
        createStar(position: CGPoint(x: frame.width * 0.2, y: ground.position.y + ground.size.height / 2 + 300))
        
        // Вторая звезда - между центральной и правой стеной
        createStar(position: CGPoint(x: frame.width * 0.65, y: frame.height - 150))
        
        // Третья звезда - поднимаем выше и смещаем левее
        createStar(position: CGPoint(x: frame.width * 0.75, y: frame.height - 80))
        
        // Добавляем финишную линию справа
        finishLine.position = CGPoint(x: frame.width - finishLine.size.width / 2, y: ground.position.y + ground.size.height / 2 + gameHeight / 2)
        if finishLine.parent == nil {
            addChild(finishLine)
        }
    }
    
    // MARK: - Создание игровых объектов
    private func createWall(position: CGPoint, size: CGSize, isDead: Bool) {
        // Выбираем текстуру стены в зависимости от уровня и типа стены
        let wallImageName: String
        if isDead {
            wallImageName = currentLevel == 1 ? "DeadWall" : "DeadWall2"
        } else {
            wallImageName = currentLevel == 1 ? "Wall" : "Wall2"
        }
        
        let wall = SKSpriteNode(imageNamed: wallImageName)
        wall.position = position
        wall.size = size
        wall.zPosition = 1
        wall.name = isDead ? "DeadWall" : "Wall"
        
        // Настройка физики для стены
        wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = isDead ? PhysicsCategory.deadWall : PhysicsCategory.wall
        wall.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        wall.physicsBody?.collisionBitMask = PhysicsCategory.ball
        wall.physicsBody?.affectedByGravity = false
        wall.physicsBody?.allowsRotation = false
        
        addChild(wall)
    }
    
    private func createStar(position: CGPoint) {
        // Создание звезды с соответствующей текстурой для текущего уровня
        let starImageName = currentLevel == 1 ? "Star" : "Star" // Пока используем одинаковые звезды
        let star = SKSpriteNode(imageNamed: starImageName)
        star.position = position
        star.size = CGSize(width: 25, height: 25)
        star.zPosition = 1
        
        // Настройка физики для звезды
        star.physicsBody = SKPhysicsBody(circleOfRadius: star.size.width / 2)
        star.physicsBody?.isDynamic = false
        star.physicsBody?.categoryBitMask = PhysicsCategory.star
        star.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        star.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(star)
        stars.append(star)
        
        // Добавление анимации
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.5)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatForever = SKAction.repeatForever(sequence)
        
        star.run(repeatForever)
    }
    
    // MARK: - Управление мячом
    private func resetBall() {
        // Сброс физики мяча
        ball.removeFromParent()
        ball.physicsBody = nil
        
        // Пересоздаем мяч с текущим скином
        ball = SKSpriteNode(imageNamed: ballImageName)
        ball.size = CGSize(width: 30, height: 30)
        ball.zPosition = 2
        
        // Размещение мяча на платформе
        ball.position = CGPoint(x: platform.position.x, y: platform.position.y + platform.size.height / 2 + ball.size.height / 2)
        
        addChild(ball)
        
        // Сброс состояния мяча
        isBallMoving = false
    }
    
    private func shootBall(angle: CGFloat, power: CGFloat) {
        guard shotsRemaining > 0 else { return }
        
        // Уменьшение количества выстрелов и обновление отображения
        shotsRemaining -= 1
        updateShotsDisplay()
        
        // Настройка физики для мяча
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.wall | PhysicsCategory.deadWall | PhysicsCategory.star | PhysicsCategory.ground | PhysicsCategory.finishLine
        ball.physicsBody?.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.ground
        
        // Настраиваем массу мяча - делаем еще легче
        ball.physicsBody?.mass = 0.7 // Уменьшаем с 0.8 до 0.7
        
        // Коэффициент отскока - увеличиваем для большей "живости"
        ball.physicsBody?.restitution = 0.9 // Увеличиваем с 0.8 до 0.9
        
        // Трение - полностью убираем
        ball.physicsBody?.friction = 0.001 // Почти полностью убираем трение
        
        // Демпфирование для имитации сопротивления воздуха - полностью убираем
        ball.physicsBody?.linearDamping = 0.0001 // Практически убираем сопротивление воздуха
        
        ball.physicsBody?.angularDamping = 0.0001 // Практически убираем сопротивление вращению
        ball.physicsBody?.allowsRotation = true // Разрешаем вращение мяча
        
        // Добавляем границы экрана
        let screenBounds = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        screenBounds.categoryBitMask = PhysicsCategory.wall
        screenBounds.contactTestBitMask = PhysicsCategory.ball
        screenBounds.collisionBitMask = PhysicsCategory.ball
        physicsBody = screenBounds
        
        // Расчет импульса для мяча с увеличением высоты при максимальной силе
        let powerMultiplier: CGFloat = 4.0
        
        // Вычисляем процент от максимальной силы
        let powerPercent = power / maxPower
        
        // Увеличиваем вертикальную составляющую импульса при сильном оттягивании
        var verticalBoost: CGFloat = 1.0
        if powerPercent > 0.8 { // Если сила больше 80% от максимальной
            verticalBoost = 1.5 + (powerPercent - 0.8) * 2.5 // От 1.5 до 2.0 в зависимости от силы
        }
        
        let impulse = CGVector(
            dx: cos(angle) * power * powerMultiplier,
            dy: sin(angle) * power * powerMultiplier * verticalBoost // Увеличиваем вертикальную составляющую
        )
        ball.physicsBody?.applyImpulse(impulse)
        
        isBallMoving = true
        
        // Проверяем, если это был последний выстрел
        if shotsRemaining == 0 {
            // Запускаем таймер для проверки проигрыша через 2 секунды
            let waitAction = SKAction.wait(forDuration: 2.0)
            let checkGameOverAction = SKAction.run { [weak self] in
                guard let self = self else { return }
                // Проверяем, не достиг ли мяч финишной линии
                if !self.children.contains(where: { $0.name == "levelComplete" }) &&
                   !self.children.contains(where: { $0.name == "gameOver" }) {
                    self.showGameOver()
                }
            }
            let sequence = SKAction.sequence([waitAction, checkGameOverAction])
            run(sequence)
        }
    }
    
    private func updateTrajectory(from start: CGPoint, to end: CGPoint) {
        // Расчет угла и силы выстрела
        let dx = start.x - end.x
        let dy = start.y - end.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // Ограничение максимальной силы
        let power = min(distance, maxPower)
        
        // Создание точек для траектории
        var points: [CGPoint] = []
        let angle = atan2(dy, dx)
        
        // Вычисляем процент от максимальной силы для адаптивного масштаба
        let powerPercent = power / maxPower
        
        // Адаптивный масштаб: чем сильнее оттягивание, тем плотнее точки
        let scale: CGFloat = powerPercent > 0.8 ? 0.02 : 0.04 // Еще сильнее уменьшаем масштаб при максимальном оттягивании
        
        let gravity = CGVector(dx: 0, dy: -9.8) // Используем стандартную гравитацию
        let powerMultiplier: CGFloat = 4.0 // Используем тот же множитель, что и в shootBall
        
        // Увеличиваем вертикальную составляющую импульса при сильном оттягивании
        var verticalBoost: CGFloat = 1.0
        if powerPercent > 0.8 { // Если сила больше 80% от максимальной
            verticalBoost = 1.5 + (powerPercent - 0.8) * 2.5 // От 1.5 до 2.0 в зависимости от силы
        }
        
        let initialVelocity = CGVector(
            dx: cos(angle) * power * scale * powerMultiplier, 
            dy: sin(angle) * power * scale * powerMultiplier * verticalBoost // Увеличиваем вертикальную составляющую
        )
        
        var position = ball.position
        var velocity = initialVelocity
        
        // Количество точек в траектории - при сильном оттягивании делаем меньше точек
        let dotsCount = powerPercent > 0.8 ? 18 : 25 // Уменьшаем количество точек при максимальном оттягивании
        
        // Симуляция движения для расчета траектории с учетом физики
        for _ in 0..<dotsCount {
            points.append(position)
            
            position.x += velocity.dx
            position.y += velocity.dy
            
            velocity.dy += gravity.dy * scale
        }
        
        // Создаем путь из отдельных точек вместо линий
        let path = CGMutablePath()
        
        for point in points {
            // Уменьшаем размер точек
            let dotRadius: CGFloat = 2.5 // Делаем точки еще меньше
            let dotRect = CGRect(x: point.x - dotRadius, y: point.y - dotRadius, 
                                width: dotRadius * 2, height: dotRadius * 2)
            path.addEllipse(in: dotRect)
        }
        
        trajectory.path = path
        
        // Устанавливаем цвет и стиль траектории
        trajectory.strokeColor = .white
        trajectory.fillColor = .white
        trajectory.lineWidth = 2
    }
    
    // MARK: - Очистка уровня
    private func removeWalls() {
        // Удаляем все стены из сцены
        for child in children {
            if child.name == "Wall" || child.name == "DeadWall" {
                child.removeFromParent()
            }
        }
    }
    
    private func removeStars() {
        // Удаляем только визуальные представления звезд
        for star in stars {
            star.removeFromParent()
        }
        stars.removeAll()
    }
    
    // MARK: - Обработка прикосновений
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Проверка нажатия на паузу
        if pauseButton.contains(location) {
            togglePause()
            return
        }
        
        // Проверка нажатия на кнопки в меню паузы
        if let pauseMenu = childNode(withName: "pauseMenu") as? SKSpriteNode {
            let localLocation = pauseMenu.convert(location, from: self)
            
            if let replayButton = pauseMenu.childNode(withName: "replayButton") as? SKSpriteNode, replayButton.contains(localLocation) {
                // Перезапуск уровня
                // Сначала закрываем меню паузы
                childNode(withName: "pauseMenu")?.removeFromParent()
                childNode(withName: "pauseOverlay")?.removeFromParent()
                isPaused = false
                
                // Затем перезапускаем уровень
                restartLevel()
                return
            }
            
            if let continueButton = pauseMenu.childNode(withName: "continueButton") as? SKSpriteNode, continueButton.contains(localLocation) {
                // Продолжение игры
                togglePause()
                return
            }
            
            if let homeButton = pauseMenu.childNode(withName: "homeButton") as? SKSpriteNode, homeButton.contains(localLocation) {
                returnToMainMenu()
                return
            }
            
            return // Предотвращаем клики "сквозь" меню паузы
        }
        
        // Проверка нажатия на кнопки завершения уровня
        if let levelComplete = childNode(withName: "levelComplete") as? SKSpriteNode {
            let localLocation = levelComplete.convert(location, from: self)
            
            if let nextButton = levelComplete.childNode(withName: "nextButton") as? SKSpriteNode, nextButton.contains(localLocation) {
                // Переход на следующий уровень
                proceedToNextLevel()
                return
            }
            
            if let homeButton = levelComplete.childNode(withName: "homeButton") as? SKSpriteNode, homeButton.contains(localLocation) {
                // Возврат в главное меню
                returnToMainMenu()
                return
            }
            
            return // Предотвращаем клики "сквозь" меню завершения уровня
        }
        
        // Проверка нажатия на кнопки проигрыша
        if let gameOver = childNode(withName: "gameOver") as? SKSpriteNode {
            let localLocation = gameOver.convert(location, from: self)
            
            if let replayButton = gameOver.childNode(withName: "replayButton") as? SKSpriteNode, replayButton.contains(localLocation) {
                // Удаляем окно поражения
                childNode(withName: "gameOver")?.removeFromParent()
                childNode(withName: "gameOverOverlay")?.removeFromParent()
                isPaused = false
                
                // Перезапускаем уровень
                restartLevel()
                return
            }
            
            if let homeButton = gameOver.childNode(withName: "homeButton") as? SKSpriteNode, homeButton.contains(localLocation) {
                // Возврат в главное меню
                returnToMainMenu()
                return
            }
            
            return // Предотвращаем клики "сквозь" меню проигрыша
        }
        
        // Начало прицеливания, если мяч не движется или если есть оставшиеся выстрелы
        if (!isBallMoving || shotsRemaining > 0) && shotsRemaining > 0 {
            isAiming = true
            startPosition = location
            trajectory.isHidden = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isAiming else { return }
        let location = touch.location(in: self)
        
        // Обновление линии траектории
        updateTrajectory(from: startPosition, to: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isAiming else { return }
        let location = touch.location(in: self)
        
        // Скрытие линии траектории
        trajectory.isHidden = true
        isAiming = false
        
        // Расчет угла и силы выстрела
        let dx = startPosition.x - location.x
        let dy = startPosition.y - location.y
        let angle = atan2(dy, dx)
        let distance = sqrt(dx * dx + dy * dy)
        
        // Ограничение максимальной силы
        let power = min(distance, maxPower)
        
        // Выстрел мячом
        shootBall(angle: angle, power: power)
    }
    
    // MARK: - Игровые механики
    private func togglePause() {
        if isPaused {
            // Убираем меню паузы и затемнение
            childNode(withName: "pauseMenu")?.removeFromParent()
            childNode(withName: "pauseOverlay")?.removeFromParent()
            isPaused = false
        } else {
            isPaused = true
            
            // Создаем затемнение всего экрана
            let pauseOverlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: self.size)
            pauseOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
            pauseOverlay.zPosition = 99
            pauseOverlay.name = "pauseOverlay"
            addChild(pauseOverlay)
            
            // Создаем меню паузы
            let pauseMenu = SKSpriteNode(color: .clear, size: CGSize(width: 300, height: 500))
            pauseMenu.position = CGPoint(x: frame.midX, y: frame.midY)
            pauseMenu.zPosition = 100
            pauseMenu.name = "pauseMenu"
            
            // Добавление заголовка
            let titleLabel = SKSpriteNode(imageNamed: "PauseLabel")
            titleLabel.size = CGSize(width: 200, height: 60)
            titleLabel.position = CGPoint(x: 0, y: 200)
            pauseMenu.addChild(titleLabel)
            
            // Добавление кнопки Replay
            let replayButton = SKSpriteNode(imageNamed: "ReplayButton")
            replayButton.size = CGSize(width: 200, height: 100)
            replayButton.position = CGPoint(x: 0, y: 80)
            replayButton.name = "replayButton"
            pauseMenu.addChild(replayButton)
            
            // Добавление кнопки Continue
            let continueButton = SKSpriteNode(imageNamed: "ContinueButton")
            continueButton.size = CGSize(width: 200, height: 100)
            continueButton.position = CGPoint(x: 0, y: -40)
            continueButton.name = "continueButton"
            pauseMenu.addChild(continueButton)
            
            // Добавление кнопки Home
            let homeButton = SKSpriteNode(imageNamed: "HomeButton")
            homeButton.size = CGSize(width: 200, height: 100)
            homeButton.position = CGPoint(x: 0, y: -160)
            homeButton.name = "homeButton"
            pauseMenu.addChild(homeButton)
            
            addChild(pauseMenu)
        }
    }
    
    private func collectStar(_ star: SKSpriteNode) {
        if stars.contains(star) {
            // Воспроизводим звук сбора звездочки
            if let gameVC = self.view?.window?.rootViewController as? GameViewController {
                gameVC.playStarCollectSound()
            }
            
            // Анимация сбора звезды
            let scaleAction = SKAction.scale(to: 1.5, duration: 0.2)
            let fadeAction = SKAction.fadeOut(withDuration: 0.2)
            let group = SKAction.group([scaleAction, fadeAction])
            let removeAction = SKAction.removeFromParent()
            let sequence = SKAction.sequence([group, removeAction])
            
            star.run(sequence)
            
            // Удаление звезды из массива
            if let index = stars.firstIndex(of: star) {
                stars.remove(at: index)
            }
            
            // Обновление счетчика звезд
            starsCollected += 1
            
            // Сохраняем информацию о собранных звездах сразу после сбора
            saveCollectedStars()
            
            // Обновляем отображение звезд
            updateStarsDisplay()
        }
    }
    
    private func showLevelComplete() {
        // Сохраняем прогресс до создания UI
        saveProgress()
        
        // Воспроизводим звук победы
        if let gameVC = self.view?.window?.rootViewController as? GameViewController {
            gameVC.playVictorySound()
        }
        
        // Создание затемнения всего экрана
        let levelCompleteOverlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: self.size)
        levelCompleteOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        levelCompleteOverlay.zPosition = 99
        levelCompleteOverlay.name = "levelCompleteOverlay"
        addChild(levelCompleteOverlay)
        
        // Создание узла для отображения завершения уровня
        let levelComplete = SKSpriteNode(color: .clear, size: CGSize(width: 300, height: 500))
        levelComplete.position = CGPoint(x: frame.midX, y: frame.midY)
        levelComplete.zPosition = 100
        levelComplete.name = "levelComplete"
        
        // Добавление кастомного лейбла
        let titleLabel = SKSpriteNode(imageNamed: "LevelCompleteLabel")
        titleLabel.size = CGSize(width: 250, height: 80)
        titleLabel.position = CGPoint(x: 0, y: 220)
        levelComplete.addChild(titleLabel)
        
        // Определяем количество монет в зависимости от уровня
        let coinsAmount: Int
        switch currentLevel {
        case 1:
            coinsAmount = 50
        case 2, 3:
            coinsAmount = 100
        case 4:
            coinsAmount = 150
        default:
            coinsAmount = 50
        }
        
        // Добавление иконки монеты с текстом
        let coinIcon = SKSpriteNode(imageNamed: "CoinIcon")
        coinIcon.size = CGSize(width: 160, height: 80)
        coinIcon.position = CGPoint(x: 0, y: 120)
        levelComplete.addChild(coinIcon)
        
        // Добавление текста с количеством монет на иконку
        let coinsText = SKLabelNode(fontNamed: "Arial-BoldItalicMT")
        coinsText.text = "+\(coinsAmount)"
        coinsText.fontSize = 26
        coinsText.fontColor = .orange
        coinsText.position = CGPoint(x: 0, y: -5)
        coinIcon.addChild(coinsText)
        
        // Отображение заработанных звезд
        let starsNode = SKNode()
        starsNode.position = CGPoint(x: 0, y: 40)
        levelComplete.addChild(starsNode)
        
        // Отображаем звезды в ряд
        let starSpacing: CGFloat = 55
        let starSize = CGSize(width: 40, height: 40)
        
        for i in 0..<3 {
            let starX = CGFloat(i - 1) * starSpacing
            let starImageName = i < starsCollected ? "StarFilled" : "StarEmpty"
            let star = SKSpriteNode(imageNamed: starImageName)
            star.size = starSize
            star.position = CGPoint(x: starX, y: 0)
            starsNode.addChild(star)
        }
        
        // Добавление кнопки Next
        let nextButton = SKSpriteNode(imageNamed: "NextButton")
        nextButton.size = CGSize(width: 200, height: 100)
        nextButton.position = CGPoint(x: 0, y: -40)
        nextButton.name = "nextButton"
        levelComplete.addChild(nextButton)
        
        // Добавление кнопки Home
        let homeButton = SKSpriteNode(imageNamed: "HomeButton")
        homeButton.size = CGSize(width: 200, height: 100)
        homeButton.position = CGPoint(x: 0, y: -160)
        homeButton.name = "homeButton"
        levelComplete.addChild(homeButton)
        
        addChild(levelComplete)
        
        // Приостановка физики
        isPaused = true
        
        // Добавление монет за прохождение уровня
        addCoins(amount: coinsAmount)
    }
    
    // Добавляем метод для работы с монетами
    private func addCoins(amount: Int) {
        // Получаем текущее количество монет
        let currentCoins = UserDefaults.standard.integer(forKey: "totalCoins")
        // Добавляем новые монеты к существующим
        let newTotal = currentCoins + amount
        // Сохраняем новое значение
        UserDefaults.standard.set(newTotal, forKey: "totalCoins")
        UserDefaults.standard.synchronize()
    }
    
    private func showGameOver() {
        // Создание затемнения всего экрана
        let gameOverOverlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: self.size)
        gameOverOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverOverlay.zPosition = 99
        gameOverOverlay.name = "gameOverOverlay"
        addChild(gameOverOverlay)
        
        // Создание узла для отображения проигрыша
        let gameOver = SKSpriteNode(color: .clear, size: CGSize(width: 300, height: 500))
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.zPosition = 100
        gameOver.name = "gameOver"
        
        // Добавление кастомного лейбла
        let titleLabel = SKSpriteNode(imageNamed: "GameOverLabel")
        titleLabel.size = CGSize(width: 250, height: 80)
        titleLabel.position = CGPoint(x: 0, y: 220)
        gameOver.addChild(titleLabel)
        
        // Добавление кнопки рестарта
        let replayButton = SKSpriteNode(imageNamed: "ReplayButton")
        replayButton.size = CGSize(width: 200, height: 100)
        replayButton.position = CGPoint(x: 0, y: 20)
        replayButton.name = "replayButton"
        gameOver.addChild(replayButton)
        
        // Добавление кнопки в меню
        let homeButton = SKSpriteNode(imageNamed: "HomeButton")
        homeButton.size = CGSize(width: 200, height: 100)
        homeButton.position = CGPoint(x: 0, y: -100)
        homeButton.name = "homeButton"
        gameOver.addChild(homeButton)
        
        addChild(gameOver)
        
        // Приостановка физики
        isPaused = true
    }
    
    // MARK: - Обновление сцены
    override func update(_ currentTime: TimeInterval) {
        // Проверка, если мяч вышел за пределы экрана
        if isBallMoving {
            // Ограничиваем мяч в пределах экрана
            let minX = ball.size.width / 2
            let maxX = frame.width - ball.size.width / 2
            let minY = ball.size.height / 2
            let maxY = frame.height - ball.size.height / 2
            
            if ball.position.x < minX {
                ball.position.x = minX
                ball.physicsBody?.velocity.dx = abs(ball.physicsBody?.velocity.dx ?? 0) * 0.5
            } else if ball.position.x > maxX {
                ball.position.x = maxX
                ball.physicsBody?.velocity.dx = -abs(ball.physicsBody?.velocity.dx ?? 0) * 0.5
            }
            
            if ball.position.y < minY {
                ball.position.y = minY
                ball.physicsBody?.velocity.dy = abs(ball.physicsBody?.velocity.dy ?? 0) * 0.5
            } else if ball.position.y > maxY {
                ball.position.y = maxY
                ball.physicsBody?.velocity.dy = -abs(ball.physicsBody?.velocity.dy ?? 0) * 0.5
            }
            
            // Проверяем, если мяч упал ниже пола
            if ball.position.y < -ball.size.height {
                if shotsRemaining > 0 {
                    resetBall()
                } else if !children.contains(where: { $0.name == "gameOver" }) &&
                          !children.contains(where: { $0.name == "levelComplete" }) {
                    showGameOver()
                }
            }
        }
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        // Воспроизводим звук удара при столкновении с препятствиями
        if collision == PhysicsCategory.ball | PhysicsCategory.wall ||
           collision == PhysicsCategory.ball | PhysicsCategory.ground {
            if let gameVC = self.view?.window?.rootViewController as? GameViewController {
                gameVC.playBallHitSound()
            }
        }
        
        if collision == PhysicsCategory.ball | PhysicsCategory.star {
            // Определение звезды в контакте
            let star = contact.bodyA.categoryBitMask == PhysicsCategory.star ? contact.bodyA.node as! SKSpriteNode : contact.bodyB.node as! SKSpriteNode
            
            // Сбор звезды
            collectStar(star)
            // Обновляем отображение звезд
            updateStarsDisplay()
        }
        
        if collision == PhysicsCategory.ball | PhysicsCategory.deadWall {
            // Проигрыш при столкновении со смертельной стеной
            if !children.contains(where: { $0.name == "gameOver" }) {
                showGameOver()
            }
        }
        
        if collision == PhysicsCategory.ball | PhysicsCategory.finishLine {
            // Завершение уровня при достижении финишной линии
            if !children.contains(where: { $0.name == "levelComplete" }) {
                showLevelComplete()
            }
        }
    }
    
    // MARK: - Переходы между уровнями
    private func proceedToNextLevel() {
        // Удаление всплывающего окна и затемнения
        childNode(withName: "levelComplete")?.removeFromParent()
        childNode(withName: "levelCompleteOverlay")?.removeFromParent()
        
        // Сброс паузы
        isPaused = false
        
        // Сброс счетчика собранных звезд
        starsCollected = 0
        updateStarsDisplay()
        
        // Сохраняем прогресс - разблокируем следующий уровень, если он доступен
        if currentLevel < 4 {
            let nextLevel = currentLevel + 1
            UserDefaults.standard.set(nextLevel, forKey: "currentLevel")
            
            // Обновляем максимальный разблокированный уровень, если необходимо
            let maxUnlockedLevel = UserDefaults.standard.integer(forKey: "maxUnlockedLevel")
            if nextLevel > maxUnlockedLevel {
                UserDefaults.standard.set(nextLevel, forKey: "maxUnlockedLevel")
            }
            
            // Переходим на следующий уровень
            currentLevel = nextLevel
            setupLevel(level: currentLevel)
            
            // Обновляем количество выстрелов для нового уровня
            shotsRemaining = currentLevel == 1 ? 3 : currentLevel + 2
            updateShotsDisplay()
        } else {
            // Если это последний уровень, возвращаемся в меню
            returnToMainMenu()
        }
    }
    
    private func restartLevel() {
        // Удаление всплывающего окна
        childNode(withName: "gameOver")?.removeFromParent()
        childNode(withName: "gameOverOverlay")?.removeFromParent()
        
        // Сброс паузы
        isPaused = false
        
        // Перезапуск текущего уровня с сохранением позиций звезд
        setupLevel(level: currentLevel)
        
        // Восстанавливаем количество выстрелов для уровня
        shotsRemaining = currentLevel == 1 ? 3 : currentLevel + 2
        updateShotsDisplay()
        
        // Сбрасываем счетчик собранных звезд
        starsCollected = 0
        updateStarsDisplay()
        
        // Сбрасываем мяч на начальную позицию
        resetBall()
    }
    
    private func returnToMainMenu() {
        // Уведомляем GameViewController о необходимости вернуться в главное меню
        NotificationCenter.default.post(name: NSNotification.Name("ReturnToMainMenu"), object: nil)
    }
    
    // MARK: - Сохранение прогресса
    private func saveProgress() {
        // Сохраняем информацию о текущем уровне (максимум уровень 4)
        let levelToSave = min(currentLevel, 4)
        UserDefaults.standard.set(levelToSave, forKey: "currentLevel")
        
        // Примечание: сохранение собранных звезд вынесено в отдельный метод,
        // чтобы предотвратить перезапись данных при вызове saveProgress из разных мест
        
        // Сохраняем информацию о препятствиях
        saveWalls()
        
        // Сохраняем изменения
        UserDefaults.standard.synchronize()
    }
    
    // Метод для сохранения собранных звезд
    private func saveCollectedStars() {
        // Сохраняем информацию о собранных звездах
        let key = "starsForLevel\(currentLevel)"
        let previousStars = UserDefaults.standard.integer(forKey: key)
        
        // Сохраняем только если текущий результат лучше предыдущего
        if starsCollected > previousStars {
            UserDefaults.standard.set(starsCollected, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    // Метод для сохранения только стен
    private func saveWalls() {
        let wallsKey = "wallsForLevel\(currentLevel)"
        var wallsData: [[String: Any]] = []
        
        // Собираем информацию о всех стенах на текущем уровне
        for child in children {
            if child.name == "Wall" || child.name == "DeadWall" {
                if let wall = child as? SKSpriteNode {
                    let wallInfo: [String: Any] = [
                        "position": ["x": wall.position.x, "y": wall.position.y],
                        "size": ["width": wall.size.width, "height": wall.size.height],
                        "isDead": wall.name == "DeadWall"
                    ]
                    wallsData.append(wallInfo)
                }
            }
        }
        
        // Сохраняем данные о стенах
        UserDefaults.standard.set(wallsData, forKey: wallsKey)
        UserDefaults.standard.synchronize()
    }
    
    // Метод для сохранения только начальных позиций звезд
    private func saveStarsPositions() {
        let starsKey = "starPositionsForLevel\(currentLevel)"
        var starsData: [[String: CGFloat]] = []
        
        // Собираем информацию о всех звездочках на текущем уровне
        for star in stars {
            let starInfo: [String: CGFloat] = [
                "x": star.position.x,
                "y": star.position.y
            ]
            starsData.append(starInfo)
        }
        
        // Сохраняем данные о звездочках
        UserDefaults.standard.set(starsData, forKey: starsKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Проверка доступности уровней
    func isLevelUnlocked(_ level: Int) -> Bool {
        let maxUnlockedLevel = UserDefaults.standard.integer(forKey: "maxUnlockedLevel")
        return level <= maxUnlockedLevel
    }
    
    // MARK: - Сохранение прогресса
    private func loadProgress() {
        // Загружаем информацию о максимальном разблокированном уровне
        let maxUnlockedLevel = UserDefaults.standard.integer(forKey: "maxUnlockedLevel")
        if maxUnlockedLevel == 0 {
            // Если это первый запуск, разблокируем первый уровень
            UserDefaults.standard.set(1, forKey: "maxUnlockedLevel")
        }
        
        // Загружаем текущий уровень
        currentLevel = UserDefaults.standard.integer(forKey: "currentLevel")
        if currentLevel == 0 {
            currentLevel = 1
            UserDefaults.standard.set(currentLevel, forKey: "currentLevel")
        }
    }
    
    // Метод для перезапуска текущего уровня
    private func resetLevel() {
        // Сохраняем текущие позиции звезд перед сбросом
        saveStarsPositions()
        
        switch currentLevel {
        case 1:
            resetLevel1()
        case 2:
            resetLevel2()
        case 3:
            resetLevel3()
        case 4:
            resetLevel4()
        default:
            break
        }
    }
    
    // Метод для перезапуска четвертого уровня
    private func resetLevel4() {
        removeChildren(in: [ball, platform])
        
        setupLevel4()
        addChild(platform)
        addChild(ball)
        
        isGameRunning = false
        canShoot = true
    }
    
    // Метод для перезапуска первого уровня
    private func resetLevel1() {
        removeChildren(in: [ball, platform])
        
        setupLevel1()
        addChild(platform)
        addChild(ball)
        
        isGameRunning = false
        canShoot = true
    }
    
    // Метод для перезапуска второго уровня
    private func resetLevel2() {
        removeChildren(in: [ball, platform])
        
        setupLevel2()
        addChild(platform)
        addChild(ball)
        
        isGameRunning = false
        canShoot = true
    }
    
    // Метод для перезапуска третьего уровня
    private func resetLevel3() {
        removeChildren(in: [ball, platform])
        
        setupLevel3()
        addChild(platform)
        addChild(ball)
        
        isGameRunning = false
        canShoot = true
    }
    
    // Обновление отображения количества выстрелов
    private func updateShotsDisplay() {
        shotsCountLabel.text = "\(shotsRemaining)"
    }
    
    // Обновление отображения количества звезд
    private func updateStarsDisplay() {
        starsCountLabel.text = "\(starsCollected)/3"
    }
}


#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    // Удаляем дублирующиеся методы, так как они уже реализованы в основном классе
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    // ... existing code ...
}
#endif

