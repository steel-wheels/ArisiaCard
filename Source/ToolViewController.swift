/*
 * @file ToolViewController.swift
 * @description Define ToolViewController class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import MultiUIKit
import Foundation

public class ToolViewController: MIViewController
{
        public override func viewDidLoad() {
                super.viewDidLoad()

                let root = MIStack()
                root.axis = .vertical

                let buttonimg = MIIconView()
                buttonimg.set(symbol: .buttonHorizontalTopPress, size: .regular)
                root.addArrangedSubView(buttonimg)

                let button = MIButton()
                button.title = "Hello"
                root.addArrangedSubView(button)

                self.view = root
                root.setFrameSize(NSSize(width: 320, height: 240))
        }
}
