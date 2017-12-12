//
//  GamePlayViewController.swift
//  RePEAT
//
//  Created by Janet Weber on 3/30/16.
//  Copyright © 2016 Weber Solutions. All rights reserved.
//

import UIKit
import SRCountdownTimer

var myGame = SimonGame()

class GamePlayViewController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!        // Start new game button tag = 5
    @IBOutlet weak var blueButton: UIButton!        // blue button   tag = 10
    @IBOutlet weak var yellowButton: UIButton!      // yellow button tag = 11
    @IBOutlet weak var redButton: UIButton!         // red button    tag = 12
    @IBOutlet weak var greenButton: UIButton!       // green button  tag = 13
    @IBOutlet weak var againButton: UIButton!       // Play another round tag = 6
    @IBOutlet weak var levelLabel: UILabel!           // tag = 101 diplays current level
    @IBOutlet weak var matchesForLevelLabel: UILabel! // tag = 100 displays matches for this level.
    @IBOutlet weak var matchesForRoundLabel: UILabel! // tag = 102 displays matches this round (sequence)
   // @IBOutlet weak var thresholdLabel: UILabel!       // tag = 103 displays threshold for next level
    @IBOutlet weak var roundNumThisLevel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!         // tag = 110 displays reason round is over
    @IBOutlet weak var messageLabel2: UILabel!        // tag = 111 displays next or repeat level
    @IBOutlet weak var smiley: UIImageView!
    @IBOutlet weak var bigSmiley: UIImageView!
    @IBOutlet var countDown: SRCountdownTimer!
   
    
//    var myGame = SimonGame()                   // create instance of SimonGame (in SimonGame.swift)
    var gameStarting = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Assign this view controller to the instance  property (idea came from link).  Then I can always
        //    reference this view controller from the SimonGame class functions.
        //    http://stackoverflow.com/questions/28184461/how-to-call-method-from-viewcontroller-in-gamescene
        myGame.viewController = self
        
        blueButton.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        
        // Set up the fonts for both message labels.
        messageLabel.font = UIFont(name: "TrebuchetMS-Bold", size: 24.0)
        messageLabel2.font = UIFont(name: "MarkerFelt-Wide", size: 24.0)
        matchesForRoundLabel.font = UIFont(name: "TrebuchetMS-Bold", size: 35.0)
        
        countDown.lineWidth = 1.5
        countDown.lineColor = .blue
        countDown.isLabelHidden = true
        countDown.timerFinishingText = ""
        countDown.isHidden = true
        
        // myGame already initialized, but call reset() to take care of additional game setup
        myGame.reset(first: true)  // boolean indicates this is the FIRST call
        
        //Display the big smiley (for aesthetics)
        messageLabel.text = ""
        messageLabel2.text = ""
        bigSmiley.isHidden = false
     } // end of viewDidLoad()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // **************************************************************************************************************
    // highLight(Int, Bool)
    // Function sets the .highlighted property of the appropriate button (passedin as the Int - button tag) to
    // true or false (passed in as Bool) to highlight and unhighlight the colored buttons
    // **************************************************************************************************************
    func highlight(btag: Int, flash: Bool) {
        switch(btag) {
        case 10:
            blueButton.isHighlighted = flash
        case 11:
            yellowButton.isHighlighted = flash
        case 12:
            redButton.isHighlighted = flash
        case 13:
            greenButton.isHighlighted = flash
        default: print("Error: highlighting button")
        } // end of switch(btag)
    } // end of highlightButtonTag()
    

    // **************************************************************************************************************
    // buttonPressed(UIButton)
    // Function handles ANY button press (4 colored buttons, Continue button or New Game button)
    // **************************************************************************************************************
    
    @IBAction func buttonPressed(sender: UIButton) {
        
        switch (sender.tag) {
        case 5: // NEW GAME
            gameStarting = false
            myGame.reset(first: false)                 // reset game (not from viewDidLoad)
            myGame.startRound(first: true)             // call startRound (indicate NEW game)
            
        case 6: // CONTINUE
            if !gameStarting {
                myGame.startRound(first: false)
            }
            
        case 10, 11, 12, 13: // Colored Button (blue, yellow, red, or green)
            // Only process button tap if .playing is true (otherwise ignore button taps)
            // .playing only true when time for user to repeat sequence
           if myGame.playing {
                myGame.stopTookTooLong()            // Stop the timer - user response within 3 sec limit
                myGame.playTone(btag: sender.tag)   // play the button tone
                myGame.buttonTaps += 1              // update button tap count
                myGame.userResp.append(sender.tag)  // append user response array (holds user response seq up to this press)
                
                if sender.tag !=
                    myGame.sequence[myGame.userResp.count-1] {        // check if current button press is correct
                                                                      //     by comparing it to correct sequence
                    myGame.roundFinished(reason: 1)                           // If NOT, call roundFinished() reason 1.
                } else {                                              // If YES, ...
                    if (myGame.buttonTaps == myGame.indexMatched+1) { // Check if we're at end of matched seqence (so far)
                        myGame.indexMatched += 1                      // YES, continue, increment index
//                        smiley.image = myGame.yellowSmiley            //      and load/display yellow smiley
//                        smiley.isHidden = false
//                        matchesForLevelLabel.text =                   //      Update statics labels
//                            String(myGame.matchesThisLevel +
//                            myGame.indexMatched)
                        matchesForRoundLabel.isHidden = false
                        if ((myGame.levelThreshold - myGame.matchesThisLevel - myGame.indexMatched) >= 0) {
                            matchesForLevelLabel.text = String(myGame.levelThreshold - myGame.matchesThisLevel - myGame.indexMatched)
                        } else {
                            matchesForLevelLabel.text = "0"
                        }
                        
                        matchesForRoundLabel.text =
                            String(myGame.indexMatched)
                        if (myGame.indexMatched < myGame.sequence.count) {         // Check that we're not at end of seq (25)
                            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + (1.0))) {
                                myGame.playNextSeq()                          //  NO, proceed (adding 1 more element to seq).
                            }
                        } else {
                            myGame.roundFinished(reason: 3)                        //  YES, call roundFinished() reason 3
                        }
                    } else {                                          // NO, keep playing this round (wait for more
                        myGame.startTookTooLong()                     //     button taps) so start the timer
                    }
                }
            }
            
        default: print("Error in buttonPressed()\n")
        } // end of case statemet
    } // end of buttonPressed function
    
}
