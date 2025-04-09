//
//  GameViewController.swift
//  ShotPinBound iOS
//
//  Created by Рома Котов on 07.04.2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Начинаем с экрана загрузки
        showLoadingScene()
        
        // Настраиваем вид
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
    private func showLoadingScene() {
        let skView = self.view as! SKView
        
        // Создаем экран загрузки
        let loadingScene = LoadingScene.newLoadingScene(size: view.bounds.size) { [weak self] in
            // Когда загрузка завершена, переходим к игровой сцене
            self?.showGameScene()
        }
        
        // Показываем сцену загрузки
        skView.presentScene(loadingScene)
    }
    
    private func showGameScene() {
        let skView = self.view as! SKView
        
        // Создаем игровую сцену
        let scene = GameScene.newGameScene()
        
        // Применяем переход между сценами
        let transition = SKTransition.fade(withDuration: 1.0)
        
        // Показываем игровую сцену
        skView.presentScene(scene, transition: transition)
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
}
