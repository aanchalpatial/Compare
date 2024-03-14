//
//  ViewController.swift
//  Compare
//
//  Created by Aanchal Patial on 13/03/24.
//

import UIKit
import AVFoundation
import SkeletonView

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var firstImageView: UIImageView!

    @IBOutlet weak var secondImageView: UIImageView!

    @IBOutlet weak var questionTextField: UITextField!

    @IBOutlet weak var responseTextView: UITextView!

    @IBOutlet weak var responseContainerView: UIView!

    @IBOutlet weak var shimmerStackView: UIStackView!
    
    @IBOutlet weak var criteriaButton: UIButton!
    
    @IBAction func addCriteriaButtonPressed(_ sender: UIButton) {
        guard let criteria = criteriaTextField.text,
              !criteria.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter text first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.taglistCollection.isHidden = false
        } completion: { _ in
            self.criteriaTextField.text = ""
            self.taglistCollection.appendTag(tagName: criteria)
        }
    }
    
    @IBOutlet weak var criteriaTextField: UITextField!
    
    @IBOutlet weak var taglistCollection: TaglistCollection!

    @IBOutlet weak var compareButton: UIButton!
    

    @IBAction func compareButtonPressed(_ sender: UIButton) {

        guard let question = questionTextField.text,
              !question.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please ask a valid question", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        var firstImage: UIImage?
        if let image = firstImageView.image,
           image != placeholderImage {
            firstImage = image
        }
        var secondImage: UIImage?
        if let image = secondImageView.image,
           image != placeholderImage {
            secondImage = image
        }
        responseTextView.text = ""
        shimmerStackView.isHidden = false
        shimmerStackView.showAnimatedSkeleton()
        Task {
            do {
                let response = try await aiModel.compare(image1: firstImage, 
                                                         image2: secondImage,
                                                         question: question, criterias: taglistCollection.copyAllTags())
                shimmerStackView.isHidden = true
                shimmerStackView.stopSkeletonAnimation()
                responseTextView.text = response ?? "Sorry ... no response available"
            } catch {
                print(error)
            }
        }

    }

    private var aiModel: AiModel!
    private var imagePickerVC: UIImagePickerController!
    private var firstImageViewFlag = true
    private let placeholderImage = UIImage(systemName: "plus")!

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
        firstImageView.image = placeholderImage
        secondImageView.image = placeholderImage
        addGreyBorder(firstImageView)
        addGreyBorder(secondImageView)
//        addGreyBorder(responseContainerView)
        addGreyBorder(questionTextField)
        addGreyBorder(criteriaTextField)
        hideKeyboardWhenTappedAround()
        taglistCollection.setupTagCollection()
        taglistCollection.isHidden = true
        shimmerStackView.isHidden = true
        criteriaButton.layer.cornerRadius = 0
        compareButton.layer.cornerRadius = 0
    }

    private func addGreyBorder(_ view: UIView) {
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.masksToBounds = true
        view.contentMode = .scaleToFill
        view.layer.borderWidth = 2
        view.contentMode = .center
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
            firstImageView.contentMode = .scaleAspectFit
            firstImageView.image = image
        } else {
            secondImageView.contentMode = .scaleAspectFit
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
