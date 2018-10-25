//
//  PhotoPicker.TitleView.swift
//  AssetsPicker
//
//  Created by Aymen Rebouh on 2018/10/23.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation
import UIKit

extension PhotosPicker {
    
    final class TitleView : UIControl {
        
        private let label: UILabel = .init()

        override var intrinsicContentSize: CGSize {
            return UIView.layoutFittingExpandedSize
        }
        
        init(withTitle title: String) {
            super.init(frame: .zero)
            
            label.font = UIFont.boldSystemFont(ofSize: 17)
            label.textAlignment = .center
            label.textColor = #colorLiteral(red: 0.172549, green: 0.231373, blue: 0.282353, alpha: 1.000000)
            
            addSubview(label)
            
            label.text = title
            label.backgroundColor = .green
            backgroundColor = .red
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: topAnchor, constant: 0)
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0)
            label.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var isHighlighted: Bool {
            didSet {
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    options: [.allowUserInteraction, .beginFromCurrentState],
                    animations: {
                        self.alpha = self.isHighlighted ? 0.6 : 1
                },
                    completion: nil
                )
            }
        }
        
        func setOpened() {}
        
        func setClosed() {}
    }
    
}
