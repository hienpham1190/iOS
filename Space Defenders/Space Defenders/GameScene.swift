//
//  GameScene.swift
//  GameBanMayBay
//
//  Created by Hien Pham on 11/10/16.
//  Copyright (c) 2016 Hien Pham. All rights reserved.
//

import SpriteKit
var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var livesNumber = 3
    let livesLable = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    let player = SKSpriteNode(imageNamed: "Spaceship")
    let bulletSound = SKAction.playSoundFileNamed("bulletsound.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let gameLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    enum gameStage{
        case preGame //Tro choi o trang thai Tap to play
        case inGame //Khi nguoi choi dang choi game
        case afterGame //Khi Game Over
    }
    
    var currentGameStage = gameStage.preGame
    
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Bullet: UInt32 = 0b10 //2
        static let Enemy: UInt32 = 0b100 //4
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    var gameArea: CGRect
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin =  (size.width - playableWidth)/2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode (imageNamed: "background" )
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        player.setScale(0.5)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        
        
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLable.text = "Lives: 3"
        livesLable.fontSize = 70
        livesLable.fontColor = SKColor.whiteColor()
        livesLable.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        livesLable.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLable.frame.size.height)
        livesLable.zPosition = 100
        self.addChild(livesLable)
        
        let moveOnToScreenAction = SKAction.moveToY(self.size.height * 0.9, duration: 0.3)
        scoreLabel.runAction(moveOnToScreenAction)
        livesLable.runAction(moveOnToScreenAction)
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 90
        tapToStartLabel.fontColor = SKColor.whiteColor()
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        gameLabel.text = "SPACE DEFENDERS"
        gameLabel.fontSize = 130
        gameLabel.fontColor = SKColor.whiteColor()
        gameLabel.zPosition = 1
        gameLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2 * 1.3)
        self.addChild(gameLabel)
        
        let fadeInAction = SKAction.fadeInWithDuration(0.3)
        gameLabel.runAction(fadeInAction)
        tapToStartLabel.runAction(fadeInAction)
    }
    
    
    func addScore(){
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 {
            startNewLevel()
        }
        
    }
    
    func runGameOver(){
        
        currentGameStage = gameStage.afterGame
        self.removeAllActions()
        //Goi bullet dua theo tham chieu ten "Bullet"
        self.enumerateChildNodesWithName("Bullet"){
            bullet, stop in
            bullet.removeAllActions()
            
        }
        self.enumerateChildNodesWithName("Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.runBlock(changeScene)
        let waitToChangeScene = SKAction.waitForDuration(1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.runAction(changeSceneSequence)
        
    }
    //Chuyen doi sang GameOverScene
    func changeScene(){
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fadeWithDuration(0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    func startGame(){
        currentGameStage = gameStage.inGame
        
        let fadeOutAction = SKAction.fadeOutWithDuration(0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        gameLabel.runAction(deleteSequence)
        tapToStartLabel.runAction(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveToY(self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.runBlock(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.runAction(startGameSequence)
    }
    
    func loseALife(){
        livesNumber -= 1
        livesLable.text = "Lives: \(livesNumber)"
        
        //Lam cho chu Live phong to len thong bao cho nguoi choi khi mat mot mang
        let scaleUp = SKAction.scaleTo(1.5, duration: 0.2)
        let scaleDown = SKAction.scaleTo(1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLable.runAction(scaleSequence)
        
        if(livesNumber == 0){
            runGameOver()
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            // Nguoi choi cham phai ke dich
            
            if body1.node != nil{
            spawnExplosion(body1.node!.position)
            }
            if body2.node != nil{
            spawnExplosion(body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && body2.node?.position.y < self.size.height{
            //Dan ban trung ke dich
            
            addScore()
            
            if body2.node != nil{
            spawnExplosion(body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scaleTo(1, duration: 0.1)
        let fadeOut = SKAction.fadeInWithDuration(0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.runAction(explosionSequence)
    }

    
    
    func startNewLevel(){
        
        //Ngan ke dich xuat hien khi nguoi choi moi vo level moi
        levelNumber += 1
        if self.actionForKey("spawningEnemies") != nil{
            self.removeActionForKey("spawningEnemies")
        }
        
        var levelDuration = NSTimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Cannot find level info")
        }
        
        // Thoi gian ke dich xuat hien
        let spawn = SKAction.runBlock(spawnEnemy)
        let waitToSpawn = SKAction.waitForDuration(levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatActionForever(spawnSequence)
        self.runAction(spawnForever, withKey: "spawningEnemies")
    }
    
    
    func fireBullet(){
        let bullet = SKSpriteNode(imageNamed: "laser")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveToY(self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.runAction(bulletSequence)
    }
    
    func spawnEnemy(){
        let randomXStart = random(min: CGRectGetMinX(gameArea),max: CGRectGetMaxX(gameArea))
        let randomXEnd = random(min: CGRectGetMinX(gameArea),max: CGRectGetMaxX(gameArea))
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOfSize: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.moveTo(endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        //Khi nguoi choi de mat ke dich nguoi choi se mat mot mang
        let loseALifeAction = SKAction.runBlock(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameStage == gameStage.inGame{
        enemy.runAction(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentGameStage == gameStage.preGame{
            startGame()
        }
        
        else if currentGameStage == gameStage.inGame{
        fireBullet()
        }
        
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.locationInNode(self)
            let previousPointOfTouch = touch.previousLocationInNode(self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameStage == gameStage.inGame{
            player.position.x += amountDragged //Di chuyen phi thuyen
            }
            
            if player.position.x > CGRectGetMaxX(gameArea) - player.size.width/2{
                player.position.x = CGRectGetMaxX(gameArea) - player.size.width/2
            }
            if player.position.x < CGRectGetMinX(gameArea) + player.size.width/2{
                player.position.x = CGRectGetMinX(gameArea) + player.size.width/2
            }
        }
    }
    
}
