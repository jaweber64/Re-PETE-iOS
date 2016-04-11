//
//  SimonGame.swift
//  MySimon
//
//  Created by Janet Weber on 4/4/16.
//  Copyright © 2016 Weber Solutions. All rights reserved.
//

import Foundation

let count = 8

class SimonGame {
    
    var sequence : [Int]
    var level : Int
    var levelThreshold : Int
    var matchesThisLevel : Int
    
    init() {
        sequence = []
        level = 1
        levelThreshold = 6  // Should be 15 for real.  Other settings (like 6) for debugging.
        matchesThisLevel = 0
    } // end of init()
    
    // ***********************************************************
    // Generate a random number (0 - num of elements to be repeatd) "count" times.
    // Use that random number as index into char set and append char
    // at that index to generated sequence string.
    // **************************************************************
    func generateSequence() -> Void {
        var randNum : Int                   // random number betw 0 and count of elements to be repeatd
        var len : UInt32                    // holds count of elements to be repeated

        self.sequence = []
        len = 4
        
        for _ in 0..<count  {                   // count (25) times
            randNum = Int(arc4random_uniform(len))+10  //    generate random number and add 10 (button tags are 10,11,12,13)
            print(randNum," ")
            self.sequence.append(randNum)              //    insert into sequence array
        }
    } // end of function generateSequence()


    // *****************************************
    // play one round:
    //
    // Display the generated sequence in game style: first char, then first
    //   and second char, then first second third char, and so on. After
    //   each gamestyle display, wait for user input (in this case - no input,
    //   just have user match sequence correctly until predetermined (randomly
    //   generated) number of matches from above has been reached.
    //
    // ****************************************
    func playRound() -> Int {
        let numMatches : Int = 8
        var waitTime : Double
        
        //self.generateSequence()    // generate the sequence to match from game character set
        self.sequence = [12,13,10,12,13,13,10,10]
        //self.sequence = [10,10,10,10,10,10,10,10]
        
        //var j : Int                            // loop variable
        //var repSeq = [Int]()                   // declare and/or initialize variables
        //var userGuess = -1                     // holds user "guess"
        var currentRepVal: Int                 // tracks how many chars to repeat from sequence
        
        currentRepVal = 0;                     // initialize currentRepVal
        while ((currentRepVal < self.sequence.count) &&  // display pattern to be repeated so far
                (currentRepVal <= numMatches)) {
            print (" ")
            for j in 0..<currentRepVal+1 {
                print("Sequence to be repeated => \(sequence[j])")
            }
                    
            waitTime = Double(currentRepVal+1) - 1.0
                    
            GamePlayViewController().displayPatternSoFar(currentRepVal, wait: waitTime, seq: sequence)
            //GamePlayViewController().displayPatternSoFar(currentRepVal, wait: waitTime)
 
    /*
                // Simulation: As long as the predetermined number of characters to
                //   match has not been reached, set the user's guess to be correct.
                userGuess = repSeq
                if (userGuess == repSeq) {              // guess matches sequence
                    //sleep(3)
                    print("\tMatch it => ")
                    if (currentRepVal <= numMatches-1) {  // AND haven't reached pre-
                        print("\t\(repSeq)\tCorrect!")// determined # matches
                        print("")                           // so print "correct" user guess
                        sleep(1)                            // and message then
                        repSeq = ""                         // re-init string var
                    } else {
                        print("\t SORRY NO MATCH!\n")// Pre-det # matches reached.
                    }
                }
            */
                currentRepVal += 1
                //println("currentRepVal => \(currentRepVal)")

        }
 
 /*
        if (currentRepVal >= genCharSeq.count) {  // Round complete, display match msg.
            println("AWESOME! Entire \(genCharSeq.count) character sequence MATCHED\n")
        } else {
            print("You matched \(numMatches) characters! Onto next round.\n")
            currentRepVal += -1                   // decrement as it contains one more than
        }                                         //     we've actually repeated or matched.
        
        //println("returning currentRepVal => \(currentRepVal)") // for debugging
        return(currentRepVal) // return number of matches this round
*/
        return 0
    } // end of play() method

    
} // end of SimonGame class definition
