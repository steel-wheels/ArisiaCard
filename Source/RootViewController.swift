/*
 * @file ViewController.swift
 * @description Define ViewController class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import MultiUIKit
import Cocoa

class RootViewController: MITabViewController
{
        override func viewDidLoad() {
                super.viewDidLoad()

                // Do any additional setup after loading the view.
                //addNewController()
                //switchView(index: 0)
        }

        override var representedObject: Any? {
                didSet {
                // Update the view, if already loaded.
                }
        }

        private func addNewController() {
                let controller = StackViewController()
                super.pushViewController(viewController: controller)
        }
}

