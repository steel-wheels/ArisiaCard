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

        private var mDocument:          ASDocument
        private var mDidStackLoaded:    Bool

        override init() {
                if let resdir = FileManager.default.resourceDirectory {
                        let pkgdir = resdir.appending(path: "Stacks/Default.astack")
                        switch ASDocument.load(packageDirectory: pkgdir) {
                        case .success(let doc):
                                mDocument = doc
                        case .failure(let err):
                                NSLog("[Error] \(MIError.errorToString(error: err)) at \(#function)")
                                let manifest = ASManifest(packageDirectory: pkgdir)
                                mDocument = ASDocument(manifest: manifest)
                        }
                } else {
                        NSLog("[Error] Failed to get resource directory")
                        let nulldir = URL(filePath: "/dev/null")
                        let manifest = ASManifest(packageDirectory: nulldir)
                        mDocument = ASDocument(manifest: manifest)
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
                        switch ASDocument.load(packageDirectory: url) {
                        case .success(let doc):
                                mDocument       = doc
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

        private func updateViewController() {
                if mDidStackLoaded {
                        if let rctrl = rootViewController() {
                                rctrl.loadStack(stack: mDocument.stack)
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

