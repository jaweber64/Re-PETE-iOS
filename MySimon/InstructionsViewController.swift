//
//  InstructionsViewController.swift
//  RePEAT
//
//  Created by Janet Weber on 3/30/16.
//  Copyright © 2016 Weber Solutions. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {

    @IBOutlet weak var instrWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        instrWebView.loadRequest(URLRequest(url: NSURL(fileURLWithPath: Bundle.main.path(forResource: "MySimonInstructions", ofType: "html")!) as URL) as URLRequest)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
