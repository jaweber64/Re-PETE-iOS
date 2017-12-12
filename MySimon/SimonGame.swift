//
//  SimonGame.swift
//  RePEAT
//
//  Created by Janet Weber on 4/4/16.
//  Copyright © 2016 Weber Solutions. All rights reserved.
//
// Mistake sound from:  http://www.freesound.org/people/Raccoonanimator/sounds/160907/
// Winning sound from: http://www.freesound.org/people/mojomills/sounds/167539/

import Foundation
import AVFoundation
import UIKit

// GLOBAL Variables
var timer:Timer? = Timer()              // Timer
var audioPlayer = AVAudioPlayer()   // Audio Player


class SimonGame {
    
    var viewController : GamePlayViewController!
    var playing : Bool              // Bool indicates playing (only true when it's time for 
                                    //   user to repeat sequence).
    var sequence : [Int]            // integer array containing correct sequence for round
    var indexMatched : Int          // current index up to which point user has matched
    var buttonTaps : Int            // count of button taps
    var roundCount : Int            // how many rounds has user played?
    var level : Int                 // what level is user currently playing?
    var levelThreshold : Int        // what is the level threshold?
    var matchesThisLevel : Int      // how many matches for user at this level?
    var userResp : [Int]
    
    let len = UInt32(4)             // constant for how many colors/tones are used in  the game
    let count = 25                  // Game length sequence limit
    
    var silence : Bool
    var sounds : [String]
    var soundFile : String
    
    // UIImage constants
    let redFrowny = UIImage(named: "redFrowny")
    let blueSurprise = UIImage(named:"blueSurprise")
    let blueSmiley = UIImage(named: "blueSmiley")
    let greenSmiley = UIImage(named: "RePETE-face")
//    let greenSmiley = UIImage(named: "greenSmiley")
    let blueDistressed = UIImage(named: "blueDistressed2")
    let yellowSmiley = UIImage(named: "RePETEicon")
    
    // Soundfile constants
    let glock = ["C06","D08","C18","G01"]
    let colors = ["blue-m","yellow-f","red-m","green-f"]
    
    init() {                    // instance initializer
        playing = false
        sequence = []
        indexMatched = 0
        buttonTaps = 0
        roundCount = 1
        level = 1
        levelThreshold = 15      // Should be 15 for real.  Other settings (4) for debugging.
        matchesThisLevel = 0
        userResp = []
        silence = false;
        sounds = glock
        soundFile = "sounds/glock/"
    } // end of init()
    
    func setSound(soundString : [String]) {
        self.sounds = soundString
    }
    func setSoundFile(fileString : String) {
        self.soundFile = fileString
    }
    func setSilence(quiet : Bool) {
        self.silence = quiet
    }
    // **************************************************************************************************************
    // TIMER Functions
    // **************************************************************************************************************
    func startTookTooLong() {
        if timer == nil {                                       // This function starts a timer which will fire in
            timer = Timer.scheduledTimer(timeInterval: 3,   // 3 seconds (the amount of time the user has to
                target:self,                                    // begin responding) if it's not invalidated before
                selector: #selector(SimonGame.tookTooLong),     // 3 seconds (see stopTookTooLong()).
                userInfo: nil, repeats: false)
        }
        viewController.countDown.start(beginingValue: 3,interval: 1)
        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + (0.25))){
            self.viewController.countDown.isHidden = false
        }
    
    }
    
    func stopTookTooLong() {        // This function stops or invalidates a timer.  Used
        if timer != nil {           // with above function for timing user response.
            timer?.invalidate()
            timer = nil
        }
        viewController.countDown.isHidden = true
        viewController.countDown.end()
    }
    
    @objc func tookTooLong() {      // This function is triggered if the timer ever fires
        stopTookTooLong()           // indicating the round is over.
        roundFinished(reason: 2)            // Stop the timer and call roundFinished() reason 2
    }
    
    // **************************************************************************************************************
    // Functions used to display the current pattern
    //      highLightButton(Int)
    //      displayPatternSoFar(Int, Double)
    // **************************************************************************************************************
    func highlightButton(btag: Int) {                               // The highlightButton(btag) function calls the
        let t = 0.25                                                // 'highlight' function in GamePlayViewcontroller
        viewController.highlight(btag: btag, flash: true)           // passing the button tag (btag) and boolean (flash) that
        self.playTone(btag: btag)                                   // will set button highlight property initally to true.
        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + (t))) { // Then after time "t" calls 'highlight' function again with
            self.viewController.highlight(btag: btag, flash: false) // button highlight property of false.
        }                                                           // The appropriate button tone is played
    } // end of highlightButton()
    // *************************************************************************************************************
    func displayPatternSoFar(index: Int, wait: Double) { // Recursive function to highlight buttons in current sequence
        if (index > 0) {                                 // to be matched. The index argument is the index into the
            displayPatternSoFar(index: index-1, wait: wait-0.75) // sequence for this round that has been correctly matched
        }                                                // thus far.  The wait argument inserts a delay - otherwise it
                                                         // happens too fast to see. Calls itself from high to low index,
        let buttonTag = sequence[index]                  // then when at 0 begins highlighting as it returns back up the
        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + (wait))) { // stack (from low to high).
            self.highlightButton(btag: buttonTag)
        }
    }
    // **************************************************************************************************************
    // Generate a random number (0 - num (4) of elements to be repeatd) count (25) times.
    // Use that random number as index into char set and append char
    // at that index to generated sequence string.
    // **************************************************************************************************************
    func generateSequence() -> Void {
        sequence = []
        
        // These used for debugging
//        sequence = [12,13,10,11]
//        self.sequence = [12,13,10,12,13,13,11,10]
//        self.sequence = [10,10,10,10,10,10,10,10]

        var randNum : Int                   // random number betw 0 and count of elements to be repeatd
        
        for _ in 0..<count  {                    // count (25) times
            randNum =
                Int(arc4random_uniform(len))+10  // generate random number (len is 4) and add 10
                                                 //    (button tags are 10,11,12,13)
            self.sequence.append(randNum)        // insert into sequence array
        }
    } // end of function generateSequence()

    // **************************************************************************************************************
    // startRound(Bool)
    // Function called at start of each round.  A new sequence is generated and variables/properties updated/reset
    // **************************************************************************************************************
    func startRound(first: Bool) {
        if (level <= 10) {                      // Check level property (>10 means game over)
            viewController.smiley.isHidden = true // hide the smiley
            viewController.matchesForRoundLabel.isHidden = true
            generateSequence()                  // generate the sequence to match
            indexMatched = 0                    // initialize game property tracking how many we've matched
           
            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + .seconds(1))) {
                self.playNextSeq()              // play the next sequence after 1 second
            }
            
            viewController.messageLabel.text = ""                       // reset message label
            if (!first) {                                               // update messageLabel2 with roundCount (if not first round)
                viewController.messageLabel2.text = "Play Next Round \(roundCount)"
                DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + (1.5))) {
                    self.viewController.messageLabel2.text = ""             // after 1.5 secs reset messageLabel2
                }
            }
            viewController.matchesForRoundLabel.text = String(indexMatched)// update stats label
            viewController.roundNumThisLevel.text = String(roundCount)
        }

    } // end of startRound() method

    // **************************************************************************************************************
    // reset(bool)
    // Function called to start a brand new game.  The boolean passed in indicates if this is called from viewDidLoad.
    // All game properties are reset for a fresh start.
    // **************************************************************************************************************
    func reset(first: Bool) {   // Reset all of the class properties (myGame)
        playing = false         // only true when time for user to repeat sequence
        sequence = []
        indexMatched = 0
        buttonTaps = 0
        roundCount = 1
        level = 1
        levelThreshold = 15      // Should be 15 for real.  Other settings for debugging.
        matchesThisLevel = 0
        
        // Reset all of the statistics labels to display new game appropriate info
        viewController.matchesForLevelLabel.text = String(levelThreshold)
        viewController.levelLabel.text = String(level)
        viewController.roundNumThisLevel.text = String(roundCount)
//        viewController.thresholdLabel.text = String(levelThreshold)
        viewController.matchesForRoundLabel.text = String(indexMatched)
        
        // Display NEW GAME label every time unless called from viewDidLoad (just big smiley)
        if !first {
            viewController.messageLabel2.text = "NEW GAME!"
            DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + (1.5))) {
                self.viewController.messageLabel2.text = ""
            }
        }
        
        // Make sure the smileys are hidden
        viewController.matchesForRoundLabel.isHidden = true
        viewController.smiley.isHidden = true
        viewController.bigSmiley.isHidden = true
        
    } // end of reset() method

    // **************************************************************************************************************
    // playNextSeq()
    // Function hides smiley image from previous play, then computes the wait time (time required to display the
    // sequence so far. diplayPatternSoFar is called with the index to repeat up to and the wait time.  After the
    // wait time (time for RePEAT to play sequence), start the timer and set .playing to true (means it's time
    // for user to respond).  buttonTaps and userResp are readied for user response.
    // **************************************************************************************************************
    func playNextSeq() {
        var waitTime: Double
        
        viewController.smiley.isHidden = true
        viewController.matchesForRoundLabel.isHidden = true
        waitTime = Double(self.indexMatched+1)*0.75 - 0.75  // Compute how long to display current pattern to match
        self.playing = false
        displayPatternSoFar(index: indexMatched, wait: waitTime)   // Call recursive function to display current pattern to match
        
        // Start timer (user only has 3 seconds to hit a button or
        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + (waitTime))) {
            self.startTookTooLong()
        }
        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + (waitTime))) {
            self.playing = true                             // the round is over).  Delay starting this timer until
        }                                                   // displayPatternSoFar() has time to complete.  Otherwise the
                                                            // timer starts while the pattern is being displayed and will
                                                            // eventually expire before user can respond - actually before
                                                            // the displayPatternSoFar() has even finished.
        buttonTaps = 0                  // initialize buttonTaps count property
        userResp = []                   // and userResp for capture user response sequence.
     } // end of playSeq()

    // **************************************************************************************************************
    // managelevel()
    // Function called after each round, but only executes after every third round.  Stat labels are updated and the
    // level threshold is compared to the number of matches obtained during this level (last 3 rounds).  If threshold 
    // is met, increase level and threshold, then update corresponding stat labels.  Update the message label with
    // text indicating whether the level will be repeated or if we move to the next level.
    // **************************************************************************************************************
    func manageLevel() {
        if (roundCount == 4) || (matchesThisLevel >= levelThreshold){
            if (matchesThisLevel >= levelThreshold) {
                level += 1
                levelThreshold += 3
//                viewController.matchesForLevelLabel.text = String(levelThreshold)
//                viewController.thresholdLabel.text = String(levelThreshold)
                if (level <= 10) {
                    viewController.levelLabel.text = String(level)
                    viewController.messageLabel2.text = "Next Level Achieved"
                }
            } else {
                viewController.messageLabel2.text = "Repeat Level"
            }
            matchesThisLevel = 0
            roundCount = 1
            viewController.roundNumThisLevel.text = String(roundCount)
            viewController.matchesForLevelLabel.text = String(levelThreshold)
            viewController.matchesForRoundLabel.text = "0"
        }
    } // end of managedLevel()
    
    // **************************************************************************************************************
    // roundFinished(Int)
    // Function called at end of each round.  The reason round has ended is indicated by the integer passed in.
    // **************************************************************************************************************
    func roundFinished(reason: Int) {
        self.playing = false                    // no longer accept colored button input from user
        
        switch reason {                         // Based on reason, update message label and smiley image
        case 1 :                                //   and play the mistake or winning tone
            viewController.messageLabel.text = "Oops! No match!"
            viewController.smiley.image = redFrowny
            //viewController.smiley.hidden = false
            self.playTone(btag: 99)
        case 2 :
            viewController.messageLabel.text = "Took too long!"
            viewController.smiley.image = blueDistressed
            self.playTone(btag: 99)
        case 3 :
            viewController.messageLabel.text = "AWESOME! \nEntire sequence matched!"
            viewController.smiley.image = blueSmiley
            self.playTone(btag: 98)
        default : print("Error finishing up round")
        }
        viewController.smiley.isHidden = false    // Display the smiley image
        matchesThisLevel += indexMatched        // update index and corresponding label
//        viewController.matchesForLevelLabel.text = String(matchesThisLevel)
        if ((levelThreshold - matchesThisLevel) >= 0) {
            viewController.matchesForLevelLabel.text = String(levelThreshold - matchesThisLevel)
        } else {
            viewController.matchesForLevelLabel.text = "0"
        }
        
        
        roundCount += 1                         // increment round count
        manageLevel()                           // call function to manage the level
        if level > 10 {                         // check to see if gameis over
            viewController.messageLabel.text = "HIGHEST level completed!"
            viewController.smiley.image = greenSmiley
            self.playTone(btag: 98)
            viewController.messageLabel2.text = ""
        }
    } // end of roundOver()
    
    // **************************************************************************************************************
    // playTone(int)
    // This function plays the sound indicated by integer passed in.  .wav is default file extension.
    // **************************************************************************************************************
    func playTone(btag: Int) {
        if (!self.silence) {
            var mySoundFile = ""
            var ext : String = "wav"            // default file extension
            
            switch btag {
            case 10: mySoundFile = self.soundFile + sounds[0]  //"C06"          // tone for blue button
            case 11: mySoundFile = self.soundFile + sounds[1] //"D08"          // tone for yellow button
            case 12: mySoundFile = self.soundFile + sounds[2] //"C18"          // tone for red button
            case 13: mySoundFile = self.soundFile + sounds[3] //"G01"          // tone for green button
            case 98: mySoundFile = "winning"      // tone for match of entire sequence OR completing level 10
                     ext = "mp3"                //       This file has .mp3 extension
            case 99: mySoundFile = "mistake"     // tone for mistake
            default: mySoundFile = self.soundFile + sounds[0] //"C06"          // DEFAULT (shouldn't get here)
            }
            
            // This code taken from stackOverflow
            // http://stackoverflow.com/questions/32816514/play-sound-using-avfoundation-with-swift-2
            // Construct the path to the sound file.
         
            let url:NSURL = Bundle.main.url(forResource: mySoundFile, withExtension: ext)! as NSURL
            
            // Make sure the audio player can find the file
            do { audioPlayer = try AVAudioPlayer(contentsOf: url as URL, fileTypeHint: nil) }
            catch let error as NSError { print(error.description) }
            
            audioPlayer.numberOfLoops = 0   // will play once
            audioPlayer.prepareToPlay()     // get ready
            audioPlayer.play()              // play the sound
        }
    }
    
} // end of SimonGame class definition
