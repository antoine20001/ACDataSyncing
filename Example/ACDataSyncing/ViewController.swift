//
//  ViewController.swift
//  ACDataSyncing
//
//  Created by antoine20001 on 10/03/2017.
//  Copyright (c) 2017 antoine20001. All rights reserved.
//

import UIKit
import ACDataSyncing

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ACDataLoader.saveContext()
        ACDataLoader.saveContext()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

