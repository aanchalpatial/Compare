//
//  ViewController.swift
//  Compare
//
//  Created by Aanchal Patial on 13/03/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var firstImageView: UIImageView!

    @IBOutlet weak var secondImageView: UIImageView!

    @IBOutlet weak var questionTextField: UITextField!

    @IBOutlet weak var responseTextView: UITextView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func compareButtonPressed(_ sender: UIButton) {
        guard let firstImage = firstImageView.image,
              let secondImage = secondImageView.image,
              let question = questionTextField.text else {
            let alert = UIAlertController(title: "Alert", message: "Please add both images & question", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        Task {
            do {
                let response = try await aiModel.compare(image1: firstImage, image2: secondImage, question: question)
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
                responseTextView.text = response ?? "Sorry ... no response available"
            } catch {
                print(error)
            }
        }

    }

    private var aiModel: AiModel!
    private var imagePickerVC: UIImagePickerController!
    var firstImageViewFlag = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        aiModel = AiModel()
        imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .camera
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        let firstTapGesture = UITapGestureRecognizer(target: self, action: #selector(firstImageTapped(tapGestureRecognizer:)))
        firstImageView.isUserInteractionEnabled = true
        firstImageView.addGestureRecognizer(firstTapGesture)
        let secondTapGesture = UITapGestureRecognizer(target: self, action: #selector(secondImageTapped(tapGestureRecognizer:)))
        secondImageView.isUserInteractionEnabled = true
        secondImageView.addGestureRecognizer(secondTapGesture)
        activityIndicator.isHidden = true
        hideKeyboardWhenTappedAround()
    }

    @objc func firstImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        firstImageViewFlag = true
        present(imagePickerVC, animated: true)
    }

    @objc func secondImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        firstImageViewFlag = false
        present(imagePickerVC, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else { return }
        if(firstImageViewFlag) {
            firstImageView.image = image
        } else {
            secondImageView.image = image
        }
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
