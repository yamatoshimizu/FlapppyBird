//
//  GameScene.swift
//  FlappyBird
//
//  Created by 清水大和 on 2020/07/11.
//  Copyright © 2020 Yamato Shimizu. All rights reserved.
//
import AVKit
import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
//    親ノードの作成
    var scrollNode: SKNode!
    
    var wallNode: SKNode!
    var bird: SKSpriteNode!
    var mimizu: SKNode!
    
    //        効果音作成
    let mimizuSoundPlay = SKAction.playSoundFileNamed("coin05.mp3", waitForCompletion: true)
    let bgm = SKAudioNode(fileNamed: "summer_hill2.mp3")
    
//    衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3      //スコア判定用の物体
    let mimizuCategory: UInt32 = 1 << 4
    
//    スコア追加
    var score = 0
    var itemScore = 0
    var userDefaults:UserDefaults = UserDefaults.standard
    var scoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    var bestScoreLabelNode: SKLabelNode!
    
    override func didMove(to view: SKView) {
//        世界に重力を追加　もはや神
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
//        デリゲートメソッドを追加
        physicsWorld.contactDelegate = self
//        背景の色
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
//        親ノード作成
        scrollNode = SKNode()
        addChild(scrollNode)
//        壁をまとめたノード作成
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        mimizu = SKNode()
        scrollNode.addChild(mimizu)
//        let url = Bundle.main.url(forResource: "summer_hill_2", withExtension: "mp3")!
//        let player = AVAudioPlayer(contentsOf: url)
        addChild(bgm)
        
        
        
//スプライト作成の関数を呼びだし
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupMimizu()
        
        setupScoreLabel()
        

        }
//    地面のセットアップ
    func setupGround(){
//                 地面画像の読み込み
                    let groundTexture = SKTexture(imageNamed: "ground")
                    groundTexture.filteringMode = .nearest
            //        アクションの作成
       
                    let moveGround = SKAction.moveBy(x: -groundTexture.size().width  , y: 0, duration: 5)
                    let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
                    let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
            //        必要な地面スプライトの数を計算
                    let neadNumber = Int(self.frame.size.width/groundTexture.size().width+2)
            //        地面スプライトの作成
                    for i in 0..<neadNumber{
                        let sprite = SKSpriteNode(texture: groundTexture)
                        //        スプライトの位置指定
                        sprite.position = CGPoint(x: groundTexture.size().width/2 + groundTexture.size().width * CGFloat(i),y:groundTexture.size().height/2)
//                        スプライトにアクションを追加
                        sprite.run(repeatScrollGround)
                        //    スプライトに物理演算を追加
                        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
//                        衝突のカテゴリー追加
                        sprite.physicsBody?.categoryBitMask = groundCategory
//                        動かなくする
                        sprite.physicsBody?.isDynamic = false
//                        スプライトを親ノードに追加
                        scrollNode.addChild(sprite)
        }
    }
//    雲のセットアップ
    func setupCloud(){
    //   雲画像の読み込み
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
    //    アクションの作成
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud,resetCloud]))
    //    必要な雲スプライトの数を計算
        let neadNumber = Int(self.frame.size.width/cloudTexture.size().width+2)
    //   雲スプライトの作成
        for i in 0..<neadNumber{
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            sprite.position = CGPoint(x: cloudTexture.size().width/2 + cloudTexture.size().width*CGFloat(i),
                y: self.frame.size.height - cloudTexture.size().height/2)
//            スプライトにアクションを追加
            sprite.run(repeatScrollCloud)
//            スプライトを親ノードに追加
            scrollNode.addChild(sprite)
            
        }
        
    }
//    壁のセットアップ
    func setupWall(){
//        壁のテクスチャーを作成
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
//        壁の移動距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width * CGFloat(1.5))
//        壁のアクションを作成
        let movingAction = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        let removeAction = SKAction.removeFromParent()
        let wallAnimation = SKAction.sequence([movingAction,removeAction])
//        色々な数値を作成
//        壁の隙間　= 鳥の縦かけ3
        let slit_length = SKTexture(imageNamed: "bird_a").size().height * 3
//        隙間位置の上下の振れ幅
        let random_y_range = SKTexture(imageNamed: "bird_a").size().height * 3
//        下の壁の最低高さ
        let center = SKTexture(imageNamed: "ground").size().height + (self.frame.size.height - SKTexture(imageNamed: "ground").size().height)/2
        let under_bar_lowest_position = center - wallTexture.size().height/2 - slit_length/2 - random_y_range/2
        
//    　壁の生成
        let createWallAnimation = SKAction.run({
//            壁関連のノードを載せるノードの作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width, y: 0)
            wall.zPosition = -50
//            ランダム数を作る
            let random_y = CGFloat.random(in: 0..<random_y_range)
//            下の壁のy座標を作る
            let under_bar_position_y = under_bar_lowest_position + random_y
//            下の壁作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_bar_position_y)
//            下の壁に物理演算を設定
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
//            動かなくする
            under.physicsBody?.isDynamic = false
//            早速wallノードに加える
            wall.addChild(under)
//            上の壁作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_bar_position_y + slit_length + wallTexture.size().height)
//            上の壁に物理演算を設定
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
//            動かなくする
            upper.physicsBody?.isDynamic = false
//            wallノードにupperを追加
            wall.addChild(upper)
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + SKTexture(imageNamed: "bird_a").size().height / 2 , y:self.frame.size.height/2 )
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
                   
            wall.addChild(scoreNode)
//            wallにアニメーションを追加
            wall.run(wallAnimation)
//            wallスプライトをwallNodeに追加
            self.wallNode.addChild(wall)
    
        })
        let waitingTimeAnimation = SKAction.wait(forDuration: 2)
                         
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation,waitingTimeAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }
//    鳥のセットアップ
    func setupBird(){
//        鳥画像読み込み
        let birdTextrueA = SKTexture(imageNamed: "bird_a")
        birdTextrueA.filteringMode = .linear
        let birdTextrueB = SKTexture(imageNamed: "bird_b")
        birdTextrueB.filteringMode = .linear
//        鳥が羽ばたくアニメーション
        let birdAnimation = SKAction.animate(with: [birdTextrueA,birdTextrueB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(birdAnimation)
//        スプライト作成
        bird = SKSpriteNode(texture: birdTextrueA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
//        物理演算を設定。スプライトに追加する形
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
//        回れない
        bird.physicsBody?.allowsRotation = false
//        カテゴリーを追加
        bird.physicsBody?.categoryBitMask = birdCategory
//        collisionBitMaskでぶつかったときに跳ね返る
        bird.physicsBody?.collisionBitMask = wallCategory | groundCategory
//        接触の判定
        bird.physicsBody?.contactTestBitMask = wallCategory | groundCategory
//        鳥にアニメーションを追加
        bird.run(flap)
//        スプライトをシーンに追加
        addChild(bird)
    }
//    ミミズのセットアップ
    func setupMimizu(){
//        テクスチャー作成
        let mimizuTexture = SKTexture(imageNamed: "bug_character_mimizu")
        mimizuTexture.filteringMode = .nearest
// scrollNode.addChild(mimizu)
//        アニメーション作成
        let moveAction = SKAction.moveBy(x: -self.frame.size.width - 170 , y: 0, duration: 4.7)
        let removeAction = SKAction.removeFromParent()
        let mimizuAnimation = SKAction.sequence([moveAction, removeAction])
        
//        スプライト作成のアニメーション
        let createSprite = SKAction.run({
            let mimizuSprite = SKSpriteNode(texture: mimizuTexture)
            mimizuSprite.physicsBody = SKPhysicsBody(circleOfRadius: mimizuTexture.size().width/2)
            mimizuSprite.physicsBody?.categoryBitMask = self.mimizuCategory
            mimizuSprite.physicsBody?.contactTestBitMask = self.birdCategory
            mimizuSprite.physicsBody?.isDynamic = false
            mimizuSprite.position = CGPoint(x: self.frame.size.width + 167, y: CGFloat.random(in: 200..<self.frame.size.height - 200))
            mimizuSprite.run(mimizuAnimation)
            self.mimizu.addChild(mimizuSprite)
        })
        let watingAnimation = SKAction.wait(forDuration: 2)
        let repeatAnimation = SKAction.repeatForever(SKAction.sequence([createSprite, watingAnimation]))
        mimizu.run(repeatAnimation)
        
    }
//    スコア表示のセットアップ
    func setupScoreLabel(){
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "score \(score)"
        self.addChild(scoreLabelNode)
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        bestScoreLabelNode.text = "Best Score \(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Item Score \(itemScore)"
        self.addChild(itemScoreLabelNode)
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0{
//        鳥の速度を0に
        bird.physicsBody?.velocity = CGVector.zero
//        鳥に縦方向の力を加える
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
        }
        else if bird.speed == 0{
            restart()
        }
    }
//    衝突のとき
// SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
//        ゲームオーバーの時に地面にぶつかっても反応しない
        if scrollNode.speed <= 0{
            return
    }

//何とぶつかったかで分ける
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory{
//           ”&”なので scoreCategoryの1の部分がbodyAのカテゴリでも1になっていれば良い。　　「||」は「又は」。
            // スコア用の物体と衝突した
           print("Score UP")
            score += 1
            scoreLabelNode.text = "Score \(score)"
//            ベストスコアかどうかの確認
            var bestScore = userDefaults.integer(forKey: "BEST")
            
//           スコアがベストスコア以上なら、スコアをベストスコアに入れて、UserDefaultsの"BEST"キーに格納して、更新する。
            if score > bestScore{
                bestScore = score
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
                bestScoreLabelNode.text = "Best Score \(bestScore)"
            }
        
        }
        else if (contact.bodyA.categoryBitMask & mimizuCategory) == mimizuCategory {
            print("Score UP")
            contact.bodyA.node?.removeFromParent()
            self.scrollNode.run(mimizuSoundPlay)
            itemScore += 1
            itemScoreLabelNode.text = "Item Score \(itemScore)"
            
        }
        else if (contact.bodyB.categoryBitMask & mimizuCategory) == mimizuCategory {
            print("Score UP")
            contact.bodyB.node?.removeFromParent()
            self.scrollNode.run(mimizuSoundPlay)
            itemScore += 1
            itemScoreLabelNode.text = "Item Score \(score)"

            
        }
        else{ // 壁か地面と衝突した
            print("Gameover")
            // スクロールを停止させる
            scrollNode.speed = 0
//一旦地面だけにコリジョンさせる
            bird.physicsBody?.collisionBitMask = groundCategory
//ぶつかったら鳥を回転させる
            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y)*001 , duration: 1)
            bird.run(roll, completion:{
                self.bird.speed = 0
                
        })
    }
}
    func restart(){
        score = 0
        scoreLabelNode.text = "Score \(score)"
        itemScore = 0
        itemScoreLabelNode.text = "Item Score \(itemScore)"
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0
        
        wallNode.removeAllChildren()
        mimizu.removeAllChildren()
        
        scrollNode.speed = 1
        bird.speed = 1
    }
    
}
