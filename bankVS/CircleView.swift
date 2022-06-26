//
//  CircleView.swift
//  bankVS
//
//  Created by Home on 22.06.2022.
//

import UIKit

class CircleView: UIView {
    
    private(set) var isFilled: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = (isFilled) ? UIColor.orange : UIColor.white
    }
    
    func config() {
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = frame.size.width / 2
    }
    
    public func toggleState() {
        isFilled.toggle()
        setNeedsLayout()
    }
}
