/*
 * @file Document.swift
 * @description Define Document class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import ArisiaPlatform
import MultiDataKit
import Cocoa

class Document: NSDocument
{
        static let DocumentTypeName = "com.github.steelwheels.arisiacard.stack"

        private var mStack:             ASStack
        private var mResource:          ASResource
        private var mDidStackLoaded:    Bool

        override init() {
                switch ASStack.loadNewStack() {
                case .success(let stack):
                        mStack = stack
                case .failure(let err):
                        fatalError("[Error] \(MIError.errorToString(error: err)) at \(#file)")
                }
                mResource       = ASResource()
                mDidStackLoaded = true
                super.init()
        }

        override class var autosavesInPlace: Bool {
                return true
        }

        override func makeWindowControllers() {
                // Returns the Storyboard that contains your Document window.
                let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
                let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
                self.addWindowController(windowController)
                // Update contents
                updateViewController()
        }

        override func read(from url: URL, ofType typeName: String) throws {
                NSLog("read from \(url.path), typename: \(typeName)")
                switch typeName {
                case Document.DocumentTypeName:
                        switch ASStack.load(from: url) {
                        case .success(let stack):
                                mStack = stack
                        case .failure(let err):
                                NSLog("[Error] \(MIError.errorToString(error: err)) at \(#file)")
                        }
                default:
                        NSLog("[Error] typename: \(typeName) at \(#file)")
                        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                }
        }

        override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping ((any Error)?) -> Void) {
                NSLog("write to \(url.path), typename: \(typeName)")
                if let err = mStack.save(to: url) {
                        NSLog("[Error] \(MIError.errorToString(error: err)) at \(#file)")
                        completionHandler(err)
                } else {
                        completionHandler(nil)
                        self.fileURL = url
                }
        }

        private func updateViewController() {
                if mDidStackLoaded {
                        if let rctrl = rootViewController() {
                                rctrl.loadStack(stack: mStack, resource: mResource)
                                mDidStackLoaded = false
                        }
                }
        }

        private func rootViewController() -> RootViewController? {
                for winctrl in self.windowControllers {
                        if let viewctrl = winctrl.contentViewController as? RootViewController {
                                return viewctrl
                        }
                }
                return nil
        }
}

