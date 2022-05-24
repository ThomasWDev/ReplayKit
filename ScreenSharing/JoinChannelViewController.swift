//
//  ViewController.swift
//  ScreenSharing
//
//  Created by Thomas Woodfin twoodfin@berkeley.edu on 05/22/2022.
//

import UIKit

class JoinChannelViewController: UIViewController {

    
    @IBOutlet weak var channelTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let screenSharingVC = segue.destination as? ScreenSharingViewController {
            channelTextField.resignFirstResponder()
            screenSharingVC.configs = ["channelName": channelTextField.text ?? ""]
        }
    }
    
    private func setupUI() {
        overrideUserInterfaceStyle = .light
        joinButton.layer.masksToBounds = true
        joinButton.layer.cornerRadius = 10
        channelTextField.layer.masksToBounds = true
        channelTextField.layer.cornerRadius = 10
        channelTextField.layer.borderColor = UIColor.darkGray.cgColor
        channelTextField.layer.borderWidth = 1.0
        channelTextField.text = "ThomasWoodfin"
        channelTextField.isEnabled = false
    }
    

}

