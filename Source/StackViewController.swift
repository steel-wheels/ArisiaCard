/*
 * @file StackViewController.swift
 * @description Define ToolViewController class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import MultiUIKit
import MultiFrameKit
import JavaScriptCore
import Foundation

public class StackViewController: MIViewController
{
        private var mContext:           MFContext?     = nil
        private var mConsoleStorage:    MITextStorage? = nil

        public override func viewDidLoad() {
                super.viewDidLoad()

                let vm   = JSVirtualMachine()
                let ctxt = MFContext(virtualMachine: vm)
                mContext = ctxt

                let root = MIStack()
                root.axis = .vertical

                /*
                 * Add views for stack
                 */
                let stack = MFDropView()
                stack.contentsView.axis = .vertical
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

        private func boot(context ctxt: MFContext) {
                guard let storage = mConsoleStorage else {
                        NSLog("[Error] Parameter is NOT set")
                        return
                }

                /* set "console" */
                MFConsole.boot(storage: storage, context: ctxt)
        }
}
