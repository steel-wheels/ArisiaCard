/*
 * @file Document.swift
 * @description Define Document class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import Cocoa

class Document: NSDocument {

        override init() {
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
                // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
                // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }

        override func read(from data: Data, ofType typeName: String) throws {
                // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
                // Alternatively, you could remove this method and override read(from:ofType:) instead.
                // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }


}

