/*
 * @file Document.swift
 * @description Define Document class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import ArisiaScript
import Cocoa

class Document: NSDocument
{
        static let DocumentTypeName = "com.github.steelwheels.arisiascript.script"

        private var mRootFrame:         ALFrame

        override init() {
                // After the boot, the root frame is empty
                mRootFrame = ALFrame()
                super.init()
                // Add your subclass-specific initialization here.
        }

        override class var autosavesInPlace: Bool {
                return true
        }

        override func makeWindowControllers() {
                // Returns the Storyboard that contains your Document window.
                let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
                let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
                self.addWindowController(windowController)
        }

        override func data(ofType typeName: String) throws -> Data {
                switch typeName {
                case Document.DocumentTypeName:
                        let text = mRootFrame.encode()
                        if let data = text.data(using: .utf8) {
                                return data
                        } else {
                                NSLog("failed to encode at \(#function)")
                                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                        }
                default:
                        NSLog("typename: \(typeName) at \(#function)")
                        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                }
        }

        override func read(from data: Data, ofType typeName: String) throws {
                switch typeName {
                case Document.DocumentTypeName:
                        if let text = String(data: data, encoding: .utf8) {
                                //NSLog("source: \(text)")
                                let parser = ALFrameParser()
                                switch parser.parse(string: text) {
                                case .success(let frame):
                                        mRootFrame = frame
                                case .failure(let err):
                                        throw err

                                }
                        } else {
                                NSLog("failed to decode at \(#function)")
                                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                        }
                default:
                        NSLog("typename: \(typeName) at \(#function)")
                        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                }
        }
}

