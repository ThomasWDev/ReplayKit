//
//  VideoView.swift
//  ScreenSharing
//
//  Created by Thomas Woodfin twoodfin@berkeley.edu on 05/22/2022.
//

import UIKit

extension Bundle {

    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }

        fatalError("Could not load view with type " + String(describing: type))
    }
}

class VideoView: UIView {

    @IBOutlet weak var videoView:UIView!
    @IBOutlet weak var placeholderLabel:UILabel!
    
    func setPlaceholder(text:String) {
        placeholderLabel.text = text
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
