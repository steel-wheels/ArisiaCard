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
        private var mContext:           MFContext?      = nil
        private var mConsoleStorage:    MITextStorage?  = nil
        private var mFrameManager:      ASFrameManager  = ASFrameManager()
        private var mUniqId:            Int = 0

        public override func viewDidLoad() {
                //NSLog("viewDidLoad at \(#file)")

                super.viewDidLoad()

                let vm   = JSVirtualMachine()
                let ctxt = MFContext(virtualMachine: vm)
                mContext = ctxt

                let root = MIStack()
                root.axis = .vertical

                /*
                 * Add views for stack
                 */
                let stack = ASDropView()
                stack.contentsView.axis = .vertical
                stack.droppingCallback = {
                        [weak self] (_ pt: CGPoint, _ name: String, _ frame: ASFrame) -> Void in
                        if let myself = self {
                                let mgr = myself.mFrameManager

                                let uname = "\(name)_\(myself.mUniqId)"
                                NSLog("Add dragged frame: \(uname)")
                                myself.mUniqId += 1
                                mgr.add(point: pt, name: uname, frame: frame)

                                /* requre layout again */
                                myself.requireLayout()
                        }
                }
                root.addArrangedSubView(stack)

                let button = MIButton()
                button.title = "Hello"
                stack.contentsView.addArrangedSubView(button)

                /*
                 * Add views for development
                 */
                let devbox = MIStack()
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

                /* setup JavaScript context */
                boot(context: ctxt)
        }

        public func loadFrame(frame: ASFrame) {
                //NSLog("Load root frame")
                mFrameManager.add(contentsOf: frame)
        }

        private func boot(context ctxt: MFContext) {
                guard let storage = mConsoleStorage else {
                        NSLog("[Error] Parameter is NOT set")
                        return
                }

                /* set "console" */
                MFConsole.boot(storage: storage, context: ctxt)
        }

        open override func viewWillLayout() {
                super.viewWillLayout()
                NSLog("viewWillLayout")
        }
}
