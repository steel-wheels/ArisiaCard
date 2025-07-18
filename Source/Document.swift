/*
 * @file Document.swift
 * @description Define Document class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import ArisiaScript
import MultiDataKit
import Cocoa

class Document: NSDocument
{
        static let DocumentTypeName = "com.github.steelwheels.arisiacard.stack"

        private var mStack:             ALStack
        private var mDidStackLoaded:    Bool

        override init() {
                if let resdir = FileManager.default.resourceDirectory {
                        let pkgdir = resdir.appending(path: "Stacks/Default.astack")
                        switch ALStackLoader.load(packageDirectory: pkgdir) {
                        case .success(let stack):
                                mStack = stack
                        case .failure(let err):
                                NSLog("[Error] \(MIError.errorToString(error: err)) at \(#function)")
                                mStack = ALStack(packageDirectory: pkgdir)
                        }
                } else {
                        NSLog("[Error] Failed to get resource directory")
                        mStack = ALStack(packageDirectory: URL(fileURLWithPath: "/dev/null"))
                }
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
                switch typeName {
                case Document.DocumentTypeName:
                        switch ALStackLoader.load(packageDirectory: url) {
                        case .success(let stack):
                                mStack = stack
                                mDidStackLoaded = true
                                updateViewController()
                        case .failure(let err):
                                throw err
                        }
                default:
                        NSLog("[Error] typename: \(typeName) at \(#function)")
                        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                }
        }

        override func write(to url: URL, ofType typeName: String) throws {
                NSLog("write to \(url.path)")
                NSLog("typename: \(typeName)")
        }

        /*
        override func read(from data: Data, ofType typeName: String) throws {
                switch typeName {
                case Document.DocumentTypeName:
                        if let text = String(data: data, encoding: .utf8) {
                                //NSLog("source: \(text)")
                                let parser = ALFrameParser()
                                switch parser.parse(string: text) {
                                case .success(let frame):
                                        mRootFrame       = frame
                                        mDidFrameUpdated = true
                                case .failure(let err):
                                        throw err
                                }
                        } else {
                                NSLog("[Error] failed to decode at \(#function)")
                                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                        }
                default:
                        NSLog("[Error] typename: \(typeName) at \(#function)")
                        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                }
        }*/

        private func updateViewController() {
                if mDidStackLoaded {
                        if let rctrl = rootViewController() {
                                rctrl.loadStack(stack: mStack)
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

