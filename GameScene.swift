// Текст количества собранных звезд (рядом со звездой)
starsCountLabel = SKLabelNode(fontNamed: "Arial-BoldItalicMT")
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
shotsCountLabel = SKLabelNode(fontNamed: "Arial-BoldItalicMT")
shotsCountLabel.text = "\(shotsRemaining)"
shotsCountLabel.fontSize = 24
shotsCountLabel.fontColor = .yellow
shotsCountLabel.position = CGPoint(x: shotsPanel.position.x, y: shotsPanel.position.y - 8)
shotsCountLabel.zPosition = 12
addChild(shotsCountLabel)

// Создание узла для отображения завершения уровня
let levelComplete = SKSpriteNode(color: .clear, size: CGSize(width: 300, height: 500))
levelComplete.position = CGPoint(x: frame.midX, y: frame.midY)
levelComplete.zPosition = 100
levelComplete.name = "levelComplete"

// Добавление кастомного лейбла
let titleLabel = SKSpriteNode(imageNamed: "LevelCompleteLabel")
titleLabel.size = CGSize(width: 250, height: 80)
titleLabel.position = CGPoint(x: 0, y: 120)
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
coinIcon.position = CGPoint(x: 0, y: 40)
levelComplete.addChild(coinIcon)

// Добавление текста с количеством монет на иконку
let coinsText = SKLabelNode(fontNamed: "Arial-BoldItalicMT")
coinsText.text = "+\(coinsAmount)"
coinsText.fontSize = 26
coinsText.fontColor = .orange
coinsText.position = CGPoint(x: 0, y: -5)
coinIcon.addChild(coinsText)

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