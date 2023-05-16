//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Radosław Serek on 16/05/2023.
//

import UIKit

final public class ErrorView: UIView {
    @IBOutlet private var label: UILabel!
    
    public var message: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = nil
    }
}
