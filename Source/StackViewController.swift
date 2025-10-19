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
        private var mStack:             ASStack?                = nil
        private var mFrameIndex:        Int                     = 0
        private var mFrameView:         MFStack?                = nil
        private var mFrameEditor:       ASFrameEditor?          = nil
        private var mFrameManager:      ASFrameManager?         = nil
        private var mResource:          ASResource?             = nil
        private var mUniqId:            Int = 0

        public func loadFrame(stack stk: ASStack, frameIndex fidx: Int, resource res: ASResource) {
                NSLog("Load root frame")

                guard let frame = stk.frame(at: fidx) else {
                        NSLog("[Error] No valid frame at \(#file)")
                        return
                }

                mStack        = stk
                mFrameManager = ASFrameManager(frame: frame)
                mFrameIndex   = fidx
                mResource     = res

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
                        if let myself = self {
                                /* add the frame to view */
                                myself.addDroppedFrame(at: pt, name: name, frame: frame)

                                /* requre layout again */
                                myself.requireLayout()
                        }
                }
                mview.addArrangedSubView(dropview) ; fid += 1

                /* allocate frame view */
                let frameview = MFStack(context: ctxt, frameId: fid) ; fid += 1
                dropview.contentsView.addArrangedSubView(frameview)
                mFrameView = frameview

                /* fix the size of main view */
                let framesize = mMainView.frame.size
                let fixsize   = MIContentSize(width:  .immediate(framesize.width),
                                              height: .immediate(framesize.height))
                mMainView.set(contentSize: fixsize)

                return fid
        }

        private func addDroppedFrame(at point: CGPoint, name nm: String,  frame frm: ASFrame) {
                guard let mgr = self.mFrameManager, let root = mFrameView else {
                        NSLog("[Error] No frame manager or frame view in \(#file)")
                        return
                }

                let uname = "\(nm)_\(self.mUniqId)"
                self.mUniqId += 1

                let detector = ASDropDetector()
                if let detpoint = detector.detect(point: point, in: root) {
                        //NSLog("The detected point is found: \(detpoint.description)")
                        mgr.insert(name: uname, frame: frm, at: detpoint)
                } else {
                        NSLog("[Error] The detected point is NOT found")
                }

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
                                        self.requireLayout()
                                })
                        }
                } else {
                        NSLog("[Error] The frame is not found: \(event.tag)")
                }
        }

        open override func viewWillLayout() {
                super.viewWillLayout()

                NSLog("viewWillLayout")
                guard let rootfrm = mFrameManager?.rootFrame, let pkg = mStack?.package else {
                        NSLog("[Error] No frame manager or package at \(#file)")
                        return
                }
                if let stackview = mFrameView, let ctxt = mContext, let strg = mConsoleStorage, let res = mResource {
                        NSLog("Compile: " + rootfrm.encode())
                        stackview.removeAllSubviews()
                        let compiler = ASFrameCompiler(context: ctxt, consoleStorage: strg, package: pkg, resource: res)
                        if let err = compiler.compile(frame: rootfrm, into: stackview) {
                                NSLog("[Error] \(MIError.toString(error: err)) at \(#function)")
                        }
                } else {
                        NSLog("[Error] No object at \(#function)")
                }
        }
}
