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
        @IBOutlet weak var mMainView: MIStack!
        @IBOutlet weak var mEditView: MIStack!
        @IBOutlet weak var mToolView: MIStack!
        
        private var mContext:           MFContext?              = nil
        private var mVirtualMachine:    JSVirtualMachine        = JSVirtualMachine()
        private var mConsoleStorage:    MITextStorage?          = nil
        private var mFrameView:         MFStack?                = nil
        private var mFrameEditor:       ASFrameEditor?          = nil
        private var mFrameManager:      ASFrameManager?         = nil
        private var mResource:          ASResource?             = nil
        private var mDoLayoutView:      Bool                    = true
        private var mUniqId:            Int = 0

        public func loadFrame(frame frm: ASFrame, resource res: ASResource) {
                //NSLog("Load root frame")
                mFrameManager = ASFrameManager(frame: frm)
                mResource     = res
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

                fid = allocateMainView(context: ctxt, frameId: fid)
                fid = allocateEditView(context: ctxt, frameId: fid)
                fid = allocateToolView(context: ctxt, frameId: fid)
        }

        private func allocateMainView(context ctxt: MFContext, frameId frameid: Int) -> Int {
                var fid = frameid

                let mview = MFStack(context: ctxt, frameId: fid) ; fid += 1
                mview.axis = .vertical
                mMainView.addArrangedSubView(mview)

                let dropview = ASDropView(context: ctxt, frameId: fid)
                dropview.contentsView.axis = .vertical
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
                mview.addArrangedSubView(dropview) ; fid += 1

                /* allocate frame view */
                let frameview = MFStack(context: ctxt, frameId: fid) ; fid += 1
                dropview.contentsView.addArrangedSubView(frameview)
                mFrameView = frameview

                return fid
        }

        private func allocateEditView(context ctxt: MFContext, frameId frameid: Int) -> Int {
                var fid = frameid

                let mview = MFStack(context: ctxt, frameId: fid) ; fid += 1
                mview.axis = .vertical
                mEditView.addArrangedSubView(mview)

                let editor = ASFrameEditor()
                mview.addArrangedSubView(editor)
                mFrameEditor = editor

                return fid
        }

        private func allocateToolView(context ctxt: MFContext, frameId frameid: Int) -> Int {
                var fid = frameid

                let mview = MFStack(context: ctxt, frameId: fid) ; fid += 1
                mview.axis = .horizontal
                mview.distribution = .fillEqually
                mToolView.addArrangedSubView(mview)

                let iconsview = MICollectionView()
                iconsview.set(symbols: [.buttonHorizontalTopPress, .photo], size: .regular)
                mview.addArrangedSubView(iconsview)

                let console = MITextView()
                console.isEditable = false
                mview.addArrangedSubView(console)
                mConsoleStorage = console.textStorage

                return fid
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
                                editor.set(target: frm, updatedCallback: {
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
                        NSLog("[Error] No frame manager at \(#file)")
                        return
                }

                NSLog("viewWillLayout")

                if let stack = mFrameView, let ctxt = mContext, let strg = mConsoleStorage {
                        NSLog("Compile: " + rootfrm.encode())
                        if let res = mResource {
                                stack.removeAllSubviews()
                                let compiler = ASFrameCompiler(context: ctxt, consoleStorage: strg, resource:  res)
                                if let err = compiler.compile(frame: rootfrm, into: stack) {
                                        NSLog("[Error] \(MIError.toString(error: err)) at \(#function)")
                                }
                        } else {
                                NSLog("[Error] No resource at \(#function)")
                        }

                } else {
                        NSLog("[Error] No root view at \(#function)")
                }

        }
}
