//
//  GamePlayViewController.swift
//  MySimon
//
//  Created by Janet Weber on 3/30/16.
//  Copyright © 2016 Weber Solutions. All rights reserved.
//

import UIKit

class GamePlayViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    
    var myGame = SimonGame()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NEW GAME\n")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    func highlightButton(btag: Int) {
        let t = 0.25

        switch(btag) {
        case 10:
            blueButton.highlighted = true
            delay(t){self.blueButton.highlighted = false}
            
        case 11:
            yellowButton.highlighted = true
            delay(t) {self.yellowButton.highlighted = false}
            
        case 12:
            self.redButton.highlighted = true
            delay(t) {self.redButton.highlighted = false}
            
        case 13:
            greenButton.highlighted = true
            delay(t) {self.greenButton.highlighted = false}
            
        default: print("Error: highlighting button")
        }
    }
    
//
//    func displayPatternSoFar(index: Int, wait: Double) {
//        print("Displaying pattern so far - index => \(index)\twait => \(wait)")
//        if (index > 0) {
//            displayPatternSoFar(index-1, wait: wait-1)
//        }
//        
//        let buttonTag = myGame.sequence[index]
//        print ("buttonTag => \(buttonTag)")
//        delay(wait) {self.highlightButton(buttonTag)}
//    }


    func displayPatternSoFar(index: Int, wait: Double, seq: [Int]) {
        print("Displaying pattern so far - index => \(index)\twait => \(wait)")
        if (index > 0) {
            displayPatternSoFar(index-1, wait: wait-1, seq: seq)
        }
        
        let buttonTag = seq[index]
        print ("buttonTag => \(buttonTag)")
        delay(wait) {self.highlightButton(buttonTag)}
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func buttonPressed(sender: UIButton) {

        switch (sender.tag) {
        case 5:
            print("Start Button Pressed\n")
            let waitTime = 8.0 - 1

            myGame.playRound()
            
            
//            print ("myGame.sequence.count => \(myGame.sequence.count)")
//            for i in 0..<myGame.sequence.count {
//                print ("seq [\(i)] => \(myGame.sequence[i])")
//            }
//            
//            displayPatternSoFar(myGame.sequence.count-1, wait: waitTime)
//            

        case 10: print("Blue Button Pressed\n")
        case 11: print("Yellow\n")
        case 12: print("Red\n")
        case 13: print("Green\n")
        default: print("Error\n")
        }
    } // end of buttonPressed function
    
}
