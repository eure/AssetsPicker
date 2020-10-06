//
//  GradientView.swift
//  MosaiqueAssetsPicker
//
//  Created by Antoine Marandon on 13/05/2020.
//  Copyright © 2020 eureka, Inc. All rights reserved.
//

import UIKit

final class GradiantView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    required init(colors: [CGColor], startPoint: CGPoint, endPoint: CGPoint, type: CAGradientLayerType, locations: [NSNumber]?) {
        super.init(frame: .zero)
        guard let layer = self.layer as? CAGradientLayer else {
            assertionFailure("should be of CAGradientLayer")
            return
        }
        layer.type = type
        layer.colors = colors
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        layer.locations = locations
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
