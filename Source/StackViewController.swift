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
        private var mFrameEditor:       ASFrameEditor?          = nil
        private var mFrameView:         MFStack?                = nil
        private var mFrameManager:      ASFrameManager          = ASFrameManager()
        private var mDoUpdateView:      Bool                    = true
        private var mUniqId:            Int = 0

        public override func viewDidLoad() {
                var fid: Int = 0
                //NSLog("viewDidLoad at \(#file)")

                super.viewDidLoad()

                let ctxt = MFContext(virtualMachine: mVirtualMachine)
                mContext = ctxt

                let root = MFStack(context: ctxt, frameId: fid)
                root.axis = .vertical
                fid += 1

                /*
                 * Add views for stack
                 */
                let dropview = ASDropView(context: ctxt, frameId: fid)
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
                fid += 1

                /* allocate frame view */
                let frameview = MFStack(context: ctxt, frameId: fid)
                dropview.contentsView.addArrangedSubView(frameview)
                mFrameView = frameview
                fid += 1

                /*
                 * Add views for development
                 */
                let devbox = MFStack(context: ctxt, frameId: fid)
                devbox.axis = .horizontal
                devbox.set(contentSize: MIContentSize(width:  .ratioToScreen(0.5),
                                                      height: .ratioToScreen(0.5)))
                root.addArrangedSubView(devbox)
                fid += 1

                let buttonimg = MIIconView()
                buttonimg.set(symbol: .buttonHorizontalTopPress, size: .regular)
                devbox.addArrangedSubView(buttonimg)

                let editor = ASFrameEditor()
                devbox.addArrangedSubView(editor)
                mFrameEditor = editor

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

        open override func acceptViewEvent(_ event: MIViewEvent) {
                NSLog("acceptViewEvent: \(event.tag) at \(#function)")
                if let frm = mFrameManager.search(coreTag: event.tag) {
                        if let editor = mFrameEditor {
                                NSLog("acceptViewEvent: use frame \(frm.encode())")
                                editor.set(target: frm)
                        }
                } else {
                        NSLog("[Error] The frame is not found: \(event.tag)")
                }
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
