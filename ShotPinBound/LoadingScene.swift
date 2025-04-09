//
//  LoadingScene.swift
//  ShotPinBound Shared
//
//  Created by Рома Котов on 07.04.2025.
//

import SpriteKit

class LoadingBackground: SKSpriteNode {
    static func create(size: CGSize) -> LoadingBackground {
        let background = LoadingBackground(color: .darkGray, size: size)
        background.name = "loadingBackground"
        background.zPosition = -1
        
        // Добавляем градиентный фон
        let topColor = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)
        let bottomColor = UIColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 1.0)
        
        let gradientNode = SKSpriteNode(color: .clear, size: size)
        
        let shader = SKShader(source: """
        void main() {
            vec2 position = v_tex_coord;
            gl_FragColor = vec4(
                mix(0.1, 0.2, position.y),
                mix(0.2, 0.3, position.y),
                mix(0.3, 0.4, position.y),
                1.0
            );
        }
        """)
        
        gradientNode.shader = shader
        background.addChild(gradientNode)
        
        // Добавляем декоративные элементы
        for _ in 0..<20 {
            let dotSize = CGFloat.random(in: 2...6)
            let dot = SKShapeNode(circleOfRadius: dotSize)
            dot.fillColor = .white
            dot.alpha = CGFloat.random(in: 0.2...0.6)
            dot.position = CGPoint(
                x: CGFloat.random(in: -size.width/2...size.width/2),
                y: CGFloat.random(in: -size.height/2...size.height/2)
            )
            background.addChild(dot)
        }
        
        return background
    }
}

class LoadingScene: SKScene {
    private var progressBar: SKSpriteNode!
    private var progressBarBackground: SKSpriteNode!
    private var progressLabel: SKLabelNode!
    private var loadingText: SKLabelNode!
    private var progress: CGFloat = 0.0
    
    private var onComplete: (() -> Void)?
    
    class func newLoadingScene(size: CGSize, onComplete: @escaping () -> Void) -> LoadingScene {
        let scene = LoadingScene(size: size)
        scene.scaleMode = .aspectFill
        scene.onComplete = onComplete
        return scene
    }
    
    override func didMove(to view: SKView) {
        setupScene()
        startLoading()
    }
    
    private func setupScene() {
        // Фон
        let background = LoadingBackground.create(size: self.size)
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(background)
        
        // Заголовок
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "ShotPinBound"
        title.fontSize = 42
        title.fontColor = .white
        title.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.7)
        self.addChild(title)
        
        // Текст загрузки
        loadingText = SKLabelNode(fontNamed: "AvenirNext-Regular")
        loadingText.text = "Загрузка..."
        loadingText.fontSize = 24
        loadingText.fontColor = .white
        loadingText.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2 + 40)
        self.addChild(loadingText)
        
        // Прогресс лейбл
        progressLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        progressLabel.text = "0%"
        progressLabel.fontSize = 20
        progressLabel.fontColor = .white
        progressLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2 - 40)
        self.addChild(progressLabel)
        
        // Фон прогресс-бара
        let progressBarWidth = self.size.width * 0.8
        let progressBarHeight: CGFloat = 10
        
        progressBarBackground = SKSpriteNode(color: UIColor.white.withAlphaComponent(0.3), size: CGSize(width: progressBarWidth, height: progressBarHeight))
        progressBarBackground.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        progressBarBackground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.addChild(progressBarBackground)
        
        // Прогресс-бар
        progressBar = SKSpriteNode(color: .white, size: CGSize(width: 0, height: progressBarHeight))
        progressBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressBar.position = CGPoint(x: progressBarBackground.position.x - progressBarWidth/2, y: progressBarBackground.position.y)
        self.addChild(progressBar)
    }
    
    private func startLoading() {
        // Имитация загрузки
        let waitAction = SKAction.wait(forDuration: 0.05)
        let updateAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            if self.progress < 1.0 {
                self.progress += CGFloat.random(in: 0.01...0.05)
                if self.progress > 1.0 {
                    self.progress = 1.0
                }
                self.updateProgress()
            } else {
                self.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.5),
                    SKAction.run { [weak self] in
                        self?.onComplete?()
                    }
                ]))
            }
        }
        
        let sequence = SKAction.sequence([waitAction, updateAction])
        let repeatAction = SKAction.repeat(sequence, count: 30) // примерно количество шагов загрузки
        
        self.run(repeatAction)
    }
    
    private func updateProgress() {
        let progressWidth = progressBarBackground.size.width * progress
        progressBar.size.width = progressWidth
        progressLabel.text = "\(Int(progress * 100))%"
        
        let dots = Int((Date().timeIntervalSince1970 * 2).truncatingRemainder(dividingBy: 4))
        var dotsString = ""
        for _ in 0..<dots {
            dotsString += "."
        }
        loadingText.text = "Загрузка\(dotsString)"
    }
} 