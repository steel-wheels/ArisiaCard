//
//  ViewController.swift
//  ArisiaCard
//
//  Created by Tomoo Hamada on 2025/06/21.
//

import MultiUIKit
#if os(OSX)
import Cocoa
#else
import UIKit
#endif

class ViewController: MIViewController {

        override func viewDidLoad() {
                super.viewDidLoad()

                // Do any additional setup after loading the view.
        }

#if os(OSX)
        override var representedObject: Any? {
                didSet {
                // Update the view, if already loaded.
                }
        }
#endif
}


