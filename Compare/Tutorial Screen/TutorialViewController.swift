//
//  TutorialViewController.swift
//  Compare
//
//  Created by Aanchal Patial on 15/03/24.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var dismissImageView: UIImageView!
    @IBOutlet weak var dismissView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissImageView.isUserInteractionEnabled = true
        let dismissGesture1 = UITapGestureRecognizer(target: self, action: #selector(dismissTapGestureHandler(_:)))
        dismissImageView.addGestureRecognizer(dismissGesture1)
        let dismissGesture2 = UITapGestureRecognizer(target: self, action: #selector(dismissTapGestureHandler(_:)))
        dismissView.isUserInteractionEnabled = true
        dismissView.addGestureRecognizer(dismissGesture2)
    }


    @objc func dismissTapGestureHandler(_ sender:AnyObject){
         dismiss(animated: true)
    }
}
