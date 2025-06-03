//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by KM on 03.06.2025.
//

import Foundation
import UIKit

public final class ErrorView: UIView {
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
