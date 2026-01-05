/*
 * @file StackViewController.swift
 * @description Define ToolViewController class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import ArisiaPlatform
import MultiUIKit
import MultiFrameKit
import JavaScriptKit
import JavaScriptCore
import Foundation

public class StackViewController: MIViewController
{
        @IBOutlet weak var mMainView: MIStack!
        @IBOutlet weak var mEditView: MIStack!
        @IBOutlet weak var mToolView: MIStack!
        
        private var mContext:           KSContext?              = nil
        private var mVirtualMachine:    JSVirtualMachine        = JSVirtualMachine()
        private var mConsoleStorage:    MITextStorage?          = nil
        private var mStack:             ASStack?                = nil
        private var mFrameIndex:        Int                     = 0
        private var mFrameView:         MFStack?                = nil
        private var mFrameCommandQueue: ASFrameCommandQueue     = ASFrameCommandQueue()
        private var mFrameEditor:       ASFrameEditorView?      = nil
        private var mFrameManager:      ASFrameManager?         = nil
        private var mDidFrameUpdated:   Bool                    = true
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
        }

        public override func viewDidLoad() {
                //NSLog("viewDidLoad at \(#file)")

                super.viewDidLoad()

                let ctxt = KSContext(virtualMachine: mVirtualMachine)
                mContext = ctxt

                allocateMainView(context: ctxt)
                allocateEditView(context: ctxt)
                allocateToolView(context: ctxt)

                /* setup library */
                if let storage = mConsoleStorage {
                        let lib = MFLibrary()
                        if let err = lib.load(into: ctxt, storage: storage) {
                                NSLog("[Error] \(err.description) at \(#file)")
                        }
                } else {
                        NSLog("[Error] Failed to load library at \(#file)")
                }
        }

        private func allocateMainView(context ctxt: KSContext) {
                let mview = MFStack(context: ctxt)
                mview.axis = .vertical
                mMainView.addArrangedSubView(mview)

                let dropview = ASDropView(context: ctxt)
                dropview.contentsView.axis = .vertical
                dropview.droppingCallback = {
                        [weak self] (_ pt: CGPoint, _ name: String, _ frame: ASFrame) -> Void in
                        if let myself = self {
                                /* add the frame to view */
                                myself.addDroppedFrame(at: pt, name: name, frame: frame)

                                /* requre layout again */
                                NSLog("require layout at \(#file)")
                                myself.mDidFrameUpdated = true
                                myself.requireLayout()
                        }
                }
                mview.addArrangedSubView(dropview) ;

                /* allocate frame view */
                let frameview = MFStack(context: ctxt)
                dropview.contentsView.addArrangedSubView(frameview)
                mFrameView = frameview

                /* fix the size of main view */
                let framesize = mMainView.frame.size
                mMainView.setFrameSize(framesize)
        }

        private func addDroppedFrame(at point: CGPoint, name nm: String,  frame frm: ASFrame) {
                guard let mgr = self.mFrameManager, let root = mFrameView else {
                        NSLog("[Error] No frame manager or frame view in \(#file)")
                        return
                }

                let uname = "\(nm)_\(self.mUniqId)"
                self.mUniqId += 1

                if let dpc = MIViewFinder.find(in: root, at: point) {
                        NSLog("View Finder (Detect) : \(dpc.description)")
                        if !mFrameCommandQueue.insert(rootFrame: mgr.rootFrame, sourceName: uname, sourceFrame: frm, detectedPoint: dpc) {
                                NSLog("[Error] Failed to insert")
                        }
                } else {
                        NSLog("[Error] The detected point is NOT found")
                }
        }

        private func allocateEditView(context ctxt: KSContext) {
                let mview = MFStack(context: ctxt)
                mview.axis = .vertical
                mEditView.addArrangedSubView(mview)

                let editor = ASFrameEditorView()
                mview.addArrangedSubView(editor)
                mFrameEditor = editor
        }

        private func allocateToolView(context ctxt: KSContext) {
                let mview = MFStack(context: ctxt)
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
        }

        open override func acceptViewEvent(_ event: MIViewEvent) {
                guard let mgr = mFrameManager, let pkg = mStack?.package else {
                        NSLog("[Error] No manager or package")
                        return
                }

                //NSLog("acceptViewEvent: \(event.tag) at \(#function)")
                let fid = MFInterfaceTagToFrameId(interfaceTag: event.tag)
                if let frm = ASFrameCommand.search(frame: mgr.rootFrame, frameId: fid) {
                        if let editor = mFrameEditor {
                                //NSLog("acceptViewEvent: use frame \(frm.encode())")
                                editor.set(target: frm, package: pkg, updatedCallback: {
                                        (_ frameid: Int) -> Void in
                                        NSLog("acceptViewEvent: \(event.tag) -> \(frameid) at \(#function)")
                                        self.mDidFrameUpdated = true
                                        self.requireLayout()
                                })
                        }
                } else {
                        NSLog("[Error] The frame is not found: \(event.tag)")
                }
        }

        open override func viewWillLayout() {
                NSLog("viewWillLayout start")

                guard let rootfrm = mFrameManager?.rootFrame, let stack = mStack, let pkg = mStack?.package else {
                        super.viewWillLayout()
                        return
                }

                if let stackview = mFrameView, let ctxt = mContext, let strg = mConsoleStorage, let res = mResource {
                        if mDidFrameUpdated {
                                NSLog("Compile: " + rootfrm.encode())
                                stackview.removeAllSubviews()
                                let compiler = ASFrameCompiler(context: ctxt, consoleStorage: strg, package: pkg, resource: res)
                                if let err = compiler.compile(frame: rootfrm, into: stackview) {
                                        NSLog("[Error] \(MIError.toString(error: err)) at \(#function)")
                                }
                                stack.updateFrame(index: self.mFrameIndex)

                                NSLog("Pre-layout")
                                MIPreLayouter.layout(rootView: mMainView)

                                let dumper = MIViewDumper()
                                mMainView.accept(visitor: dumper)

                                mDidFrameUpdated = false
                        }
                } else {
                        NSLog("[Error] No object at \(#function)")
                }

                NSLog("viewWillLayout end")
                super.viewWillLayout()
        }

        open override func viewDidLayout() {
                super.viewDidLayout()

                NSLog("Post-layout")

                let dumper = MIViewDumper()
                mMainView.accept(visitor: dumper)
        }
}
