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
        private var mFrameManager:      ASFrameManager?         = nil
        private var mDoLayoutView:      Bool                    = true
        private var mUniqId:            Int = 0

        public func loadFrame(frame frm: ASFrame) {
                //NSLog("Load root frame")
                mFrameManager = ASFrameManager(frame: frm)
                mDoLayoutView = true

                /* requre layout again */
                self.requireLayout()
        }

        public override func viewDidLoad() {
                var fid: Int = 0
                //NSLog("viewDidLoad at \(#file)")

                super.viewDidLoad()

                let ctxt = MFContext(virtualMachine: mVirtualMachine)
                mContext = ctxt

                let root = MFStack(context: ctxt, frameId: fid) ; fid += 1
                root.axis = .vertical
                root.set(contentSize: MIContentSize(width: .ratioToScreen(0.5),
                                                    height: .ratioToScreen(0.5)))
                self.view = root

                /* Allocate stack0 */
                let stack0 = MFStack(context: ctxt, frameId: fid) ; fid += 1
                stack0.axis = .horizontal
                root.addArrangedSubView(stack0)

                /*
                 * Add drop ro stack0
                 */
                let dropview = ASDropView(context: ctxt, frameId: fid)
                dropview.contentsView.axis = .vertical
                dropview.set(contentSize: MIContentSize(width:  .ratioToScreen(0.3),
                                                        height: .ratioToScreen(0.3)))
                dropview.droppingCallback = {
                        [weak self] (_ pt: CGPoint, _ name: String, _ frame: ASFrame) -> Void in
                        if let myself = self, let mgr = myself.mFrameManager {
                                let uname = "\(name)_\(myself.mUniqId)"
                                NSLog("Add dragged frame: \(uname)")
                                myself.mUniqId += 1
                                mgr.add(point: pt, name: uname, frame: frame)

                                /* requre layout again */
                                myself.mDoLayoutView = true
                                myself.requireLayout()
                        }
                }
                stack0.addArrangedSubView(dropview) ; fid += 1

                /* allocate frame view */
                let frameview = MFStack(context: ctxt, frameId: fid) ; fid += 1
                dropview.contentsView.addArrangedSubView(frameview)
                mFrameView = frameview
                fid += 1

                /*
                 * Add frame editor view ro stack0
                 */
                let editor = ASFrameEditor()
                stack0.addArrangedSubView(editor)
                mFrameEditor = editor

                /* allocate stack view */
                let stack1 = MFStack(context: ctxt, frameId: fid) ; fid += 1
                stack1.axis = .horizontal
                stack1.distribution = .fillEqually
                root.addArrangedSubView(stack1)

                /*
                 * Add collection view for GUI parts
                 */
                let iconsview = MICollectionView()
                iconsview.set(symbols: [.buttonHorizontalTopPress, .photo], size: .regular)
                stack1.addArrangedSubView(iconsview)

                /*
                 * Add console to stack1
                 */
                let console = MITextView()
                console.isEditable = false
                stack1.addArrangedSubView(console)
                mConsoleStorage = console.textStorage
        }

        open override func acceptViewEvent(_ event: MIViewEvent) {
                guard let mgr = mFrameManager else {
                        NSLog("[Error] No manager")
                        return
                }

                //NSLog("acceptViewEvent: \(event.tag) at \(#function)")
                if let frm = mgr.search(coreTag: event.tag) {
                        if let editor = mFrameEditor {
                                //NSLog("acceptViewEvent: use frame \(frm.encode())")
                                editor.set(target: frm, width: .ratioToScreen(0.2), updatedCallback: {
                                        (_ frameid: Int) -> Void in
                                        NSLog("acceptViewEvent: \(event.tag) -> \(frameid) at \(#function)")
                                        self.mDoLayoutView = true
                                        self.requireLayout()
                                })
                        }
                } else {
                        NSLog("[Error] The frame is not found: \(event.tag)")
                }
        }

        open override func viewWillLayout() {
                super.viewWillLayout()

                if(mDoLayoutView){
                        mDoLayoutView = false // do layout
                } else {
                        return // needless layout
                }

                guard let rootfrm = mFrameManager?.rootFrame else {
                        NSLog("[Error] No frame manager at \(#function)")
                        return
                }

                NSLog("viewWillLayout")

                if let stack = mFrameView, let ctxt = mContext, let strg = mConsoleStorage {
                                NSLog("Compile: " + rootfrm.encode())

                                stack.removeAllSubviews()
                                let compiler = ASFrameCompiler(context: ctxt, consoleStorage: strg)
                                if let err = compiler.compile(frame: rootfrm, into: stack) {
                                        NSLog("[Error] \(MIError.toString(error: err)) at \(#function)")
                                }
                        } else {
                                NSLog("[Error] No root view at \(#function)")
                }

        }
}
