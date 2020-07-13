//
//  ViewController.swift
//  FlappyBird
//
//  Created by 清水大和 on 2020/07/11.
//  Copyright © 2020 Yamato Shimizu. All rights reserved.
//
import SpriteKit
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let skView = self.view as! SKView
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let scene = GameScene(size: skView.frame.size)
        skView.presentScene(scene)
    }
    override var prefersStatusBarHidden: Bool{
//        コンピューティングプロパティ。もともと値が入っているストアドプロパティとは異なり、{}内で算出した値を返す。「get」で自分の値、「set」で他のストアドプロパティに値を返すことができる。getのみ必須。
        get{
            return true
        }
    }

}

