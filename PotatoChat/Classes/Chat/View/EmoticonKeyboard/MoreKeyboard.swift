//
//  MoreKeyboardView.swift
//  WeChat
//
//  Created by 黄中山 on 2018/5/5.
//  Copyright © 2018年 黄中山. All rights reserved.
//

import UIKit

enum MoreKeyboardButtonType {
    case album
}

protocol MoreKeyboardDelegate: class {
    func moreKeyboard(_ view: MoreKeyboard, didSelectedButton type: MoreKeyboardButtonType)
}

extension MoreKeyboardDelegate {
    func moreKeyboard(_ view: MoreKeyboard, didSelectedButton type: MoreKeyboardButtonType) {}
}

final class MoreKeyboard: UIView {
    
    weak var delegate: MoreKeyboardDelegate?
    
    static func keyboard() -> Self {
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216)
        let view = self.init(frame: rect)
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(albumButton)
        albumButton.frame = CGRect(x: 40, y: 30, width: 60, height: 60)
        albumButton.backgroundColor = UIColor.brown
    }
    
    // MARK: - Properties[lazy]
    private lazy var albumButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("相册", for: .normal)
        button.addTarget(self, action: #selector(clickAlbumButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Selector
    @objc private func clickAlbumButton() {
        delegate?.moreKeyboard(self, didSelectedButton: .album)
    }
    
}
