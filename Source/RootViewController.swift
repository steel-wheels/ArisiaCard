/*
 * @file ViewController.swift
 * @description Define ViewController class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import MultiUIKit
import Cocoa

import ArisiaPlatform

class RootViewController: MITabViewController
{
        public func loadStack(stack: ASStack, resource res: ASResource) {
                let idx = currentViewIndex()
                if let fname = stack.scriptFileName(at: idx){
                        switch stack.frame(fileName: fname) {
                        case .success(let frame):
                                if let view = self.currentViewController() as? StackViewController {
                                        view.loadFrame(frame: frame, package: stack.package)
                                } else {
                                        NSLog("[Error] Failed to load stack for index \(idx)")
                                }
                        case .failure(let err):
                                NSLog("[Error] \(MIError.toString(error: err)) at \(#file)" )
                        }
                } else {
                        NSLog("[Error] No frame name for index \(idx) at \(#file)" )
                }
        }

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

