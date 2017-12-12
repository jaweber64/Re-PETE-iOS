//
//  SettingsViewController.swift
//  RePEAT
//
//  Created by Janet Weber on 3/30/16.
//  Copyright © 2016 Weber Solutions. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var soundSegCtrl: UISegmentedControl!
    @IBOutlet var Classic: UIButton!
    @IBOutlet var noRepeat: UIButton!
    @IBOutlet var Blind: UIButton!
    @IBOutlet var Speed: UIButton!
    @IBOutlet var Crazy: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let attr = NSDictionary(object: UIFont(name: "HelveticaNeue-Bold", size: 20.0)!, forKey: NSAttributedStringKey.font as NSCopying)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as [NSObject : AnyObject] , for: [])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func modeSwitch(_ sender: UIButton) {
//        switch sender.tag {
//            case 20 :
//            case 21 :
//        case 22 :
//        case 23 :
//        case 24 :
//        default :
//        }
    }
    
    @IBAction func soundSwitch(_ sender: UISegmentedControl) {
        switch soundSegCtrl.selectedSegmentIndex {
        case 0 : myGame.setSound(soundString: myGame.glock)
            myGame.setSoundFile(fileString: "sounds/glock/")
             myGame.setSilence(quiet: false)
        case 1 : myGame.setSound(soundString: myGame.colors)
            myGame.setSoundFile(fileString: "sounds/colorWords/")
             myGame.setSilence(quiet: false)
        case 2 : myGame.setSilence(quiet: true)
        default : myGame.setSound(soundString: myGame.glock)
                 myGame.setSoundFile(fileString: "sounds/glock/")
                 myGame.setSilence(quiet: false)
            break;
            }
        }
    
    
    /*
    @IBAction func settingsButtonPressed(sender: UIButton) {
        let alert = UIAlertController(title: "Settings View Button Pressed", message: "You pressed the button for the settings view", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Yep, I did", style: .Default, handler:nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
*/

}
