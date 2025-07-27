/*
 * @file StackViewController.swift
 * @description Define ToolViewController class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import ArisiaPlatform
import MultiUIKit
import MultiFrameKit
import JavaScriptCore
import Foundation

public class StackViewController: MIViewController
{
        private var mContext:           MFContext?              = nil
        private var mVirtualMachine:    JSVirtualMachine        = JSVirtualMachine()
        private var mConsoleStorage:    MITextStorage?          = nil
        private var mFrameView:         MFStack?                = nil
        private var mFrameManager:      ASFrameManager          = ASFrameManager()
        private var mDoUpdateView:      Bool                    = true
        private var mUniqId:            Int = 0

        public override func viewDidLoad() {
                //NSLog("viewDidLoad at \(#file)")

                super.viewDidLoad()

                let ctxt = MFContext(virtualMachine: mVirtualMachine)
                mContext = ctxt

                let root = MFStack(context: ctxt)
                root.axis = .vertical

                /*
                 * Add views for stack
                 */
                let dropview = ASDropView(context: ctxt)
                dropview.contentsView.axis = .vertical
                dropview.droppingCallback = {
                        [weak self] (_ pt: CGPoint, _ name: String, _ frame: ASFrame) -> Void in
                        if let myself = self {
                                let mgr = myself.mFrameManager

                                let uname = "\(name)_\(myself.mUniqId)"
                                NSLog("Add dragged frame: \(uname)")
                                myself.mUniqId += 1
                                mgr.add(point: pt, name: uname, frame: frame)

                                /* requre layout again */
                                myself.mDoUpdateView = true
                                myself.requireLayout()
                        }
                }
                root.addArrangedSubView(dropview)

                /* allocate frame view */
                let frameview = MFStack(context: ctxt)
                dropview.contentsView.addArrangedSubView(frameview)
                mFrameView = frameview

                /*
                 * Add views for development
                 */
                let devbox = MFStack(context: ctxt)
                devbox.axis = .horizontal
                root.addArrangedSubView(devbox)

                let buttonimg = MIIconView()
                buttonimg.set(symbol: .buttonHorizontalTopPress, size: .regular)
                devbox.addArrangedSubView(buttonimg)

                let console = MITextView()
                console.isEditable = false
                devbox.addArrangedSubView(console)
                mConsoleStorage = console.textStorage

                self.view = root
                //root.setFrameSize(NSSize(width: 320, height: 240))
        }

        public func loadFrame(frame: ASFrame) {
                //NSLog("Load root frame")
                mFrameManager.add(contentsOf: frame)
                mDoUpdateView = true

                /* requre layout again */
                self.requireLayout()
        }

        open override func viewWillLayout() {
                super.viewWillLayout()

                if mDoUpdateView {
                        NSLog("viewWillLayout")

                        if let stack = mFrameView, let ctxt = mContext, let strg = mConsoleStorage {
                                let frame = mFrameManager.rootFrame
                                NSLog("Compile: " + frame.encode())

                                stack.removeAllSubviews()
                                let compiler = ASFrameCompiler(context: ctxt, consoleStorage: strg)
                                if let err = compiler.compile(frame: frame, into: stack) {
                                        NSLog("[Error] \(MIError.toString(error: err)) at \(#function)")
                                }
                        } else {
                                NSLog("[Error] No root view at \(#function)")
                        }

                        mDoUpdateView = false
                }
        }
}
