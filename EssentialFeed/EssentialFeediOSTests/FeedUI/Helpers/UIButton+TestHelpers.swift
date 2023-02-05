//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Radosław Serek on 05/02/2023.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
