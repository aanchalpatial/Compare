//
//  ViewController.swift
//  Compare
//
//  Created by Aanchal Patial on 13/03/24.
//

import UIKit
import AVFoundation
import PhotosUI
import Lottie

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    @IBOutlet weak var inputTypeSwitch: UISwitch!
    
    @IBAction func inputTypeSwitchToggled(_ sender: UISwitch) {
        UserDefaults.standard.setValue(sender.isOn, forKey: UserDefaults.Keys.inputTypeSwitch.rawValue)
        if(sender.isOn) {
            UIView.animate(withDuration: 0.5) {
                self.imageStackView.isHidden = true
            } completion: { _ in
                UIView.animate(withDuration: 0.5) {
                    self.textStackView.isHidden = false
                }
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.textStackView.isHidden = true
            } completion: { _ in
                UIView.animate(withDuration: 0.5) {
                    self.imageStackView.isHidden = false
                }
            }
        }
    }

    @IBOutlet weak var imageStackView: UIStackView!
    
    @IBOutlet weak var textStackView: UIStackView!

    @IBOutlet weak var firstImageView: UIImageView!

    @IBOutlet weak var secondImageView: UIImageView!

    @IBOutlet weak var firstInputTextField: UITextField!
    
    @IBOutlet weak var secondInputTextField: UITextField!
    
    @IBOutlet weak var questionTextField: UITextField!

    @IBOutlet weak var responseTableView: UITableView!
    
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

    @IBOutlet weak var premiumButton: UIButton!
    
    @IBAction func premiumButtonPressed(_ sender: UIButton) {
        let premiumViewController = PremiumViewController(freePremiumDaysLeft: freePremiumDaysLeft)
        present(premiumViewController, animated: true)
    }

    @IBAction func hamburgerButtonPressed(_ sender: UIButton) {
        showHamburgerActionSheet()
    }
    
    private var loaderAnimationView: LottieAnimationView!

    @IBOutlet weak var loaderStackView: UIStackView!

    private var sections: Sections?

    @IBAction func compareButtonPressed(_ sender: UIButton) {
        guard freePremiumDaysLeft > 0 else {
            let alert = UIAlertController(title: "Buy premium", message: "Free trail has expired", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.premiumButtonPressed(sender)
            }))
            present(alert, animated: true, completion: nil)
            return
        }
        if inputTypeSwitch.isOn {
            // text
            guard let firstInput = firstInputTextField.text,
                  !firstInput.isEmpty,
                  let secondInput = secondInputTextField.text,
                  !secondInput.isEmpty,
                  let question = questionTextField.text,
                  !question.isEmpty else {
                showAlert(title: "Input missing", message: "Required fields are empty")
                return
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            startLoadingAnimations()
            Task {
                do {
                    let response = try await aiModel.compare(firstInput: firstInput,
                                                             secondInput: secondInput,
                                                             question: question, criterias: taglistCollection.copyAllTags())
                    handleResponse(response: response, errorMessage: "Sorry ... no response available")
                } catch {
                    print(error)
                    handleResponse(response: nil, errorMessage: "We are facing some error, please retry after sometime ...")
                }
                stopLoadingAnimations()
            }
        } else {
            guard let firstImage = firstImageView.image,
                  firstImage != placeholderImage,
                  let secondImage = secondImageView.image,
                  secondImage != placeholderImage else {
                showAlert(title: "Input missing", message: "Please add both images")
                return
            }
            guard let question = questionTextField.text,
                  !question.isEmpty else {
                showAlert(title: "Input missing", message: "Please ask a question")
                    return
            }
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            startLoadingAnimations()
            Task {
                do {
                    let response = try await aiModel.compare(firstImage: firstImage,
                                                             secondImage: secondImage,
                                                             question: question, criterias: taglistCollection.copyAllTags())
                    handleResponse(response: response, errorMessage: "Sorry ... no response available")
                } catch {
                    print(error)
                    handleResponse(response: nil, errorMessage: "We are facing some error, please retry after sometime ...")
                }
                stopLoadingAnimations()
            }
        }
    }

    private func handleResponse(response: String?, errorMessage: String?) {
        if let response = response {
            if let sections = parseResponseJsonToSections(response: response) {
                self.sections = sections
                responseTableView.reloadData()
            } else {
                showAlert(title: "Sorry", message: "Please try again later")
            }
        } else {
            showAlert(title: "Sorry", message: "No response available")
        }
    }

    private func parseResponseJsonToSections(response: String) -> Sections? {
        guard let data = response.data(using: .utf8) else {
            return nil
        }
        do {
            let sections = try JSONDecoder().decode(Sections.self, from: data)
            return sections
        } catch {
            print("Error converting JSON to string array: \(error)")
            return nil
        }
    }

    private func startLoadingAnimations() {
        loaderStackView.isHidden = false
        loaderAnimationView.play()
        compareButton.isUserInteractionEnabled = false
    }

    private func stopLoadingAnimations() {
        loaderStackView.isHidden = true
        loaderAnimationView.stop()
        compareButton.isUserInteractionEnabled = true
    }

    private var aiModel: AiModel!
    private var imagePickerVC: UIImagePickerController!
    private var firstImageViewFlag = true
    private let placeholderImage = UIImage(systemName: "plus")!
    private let maxFreePremiumDays = 14
    private var freePremiumDaysLeft: Int {
        if let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            if let installDate = try! FileManager.default.attributesOfItem(atPath: documentsFolder.path)[.creationDate] as? Date,
               let daysSinceInstallation = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day {
                if daysSinceInstallation <= maxFreePremiumDays {
                    return maxFreePremiumDays - daysSinceInstallation
                } else {
                    return 0
                }
            }
        }
        return maxFreePremiumDays
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupAnimationView()
        inputTypeSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaults.Keys.inputTypeSwitch.rawValue)
        imageStackView.isHidden = inputTypeSwitch.isOn
        textStackView.isHidden = !inputTypeSwitch.isOn
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
        firstImageView.addGreyBorder()
        secondImageView.addGreyBorder()
        questionTextField.addGreyBorder()
        criteriaTextField.addGreyBorder()
        firstInputTextField.addGreyBorder()
        secondInputTextField.addGreyBorder()
        hideKeyboardWhenTappedAround()
        taglistCollection.setupTagCollection()
        taglistCollection.isHidden = true
        criteriaButton.layer.cornerRadius = 0
        compareButton.layer.cornerRadius = 0
        setupPremiumButton()

        setupResponseTableView()
        // TODO: - Remove
        preFillValues()
    }

    private func setupPremiumButton() {
        if PremiumViewController.alreadyPremiumUser() {
            premiumButton.isHidden = true
        } else {
            premiumButton.isHidden = false
            premiumButton.setTitle("\(freePremiumDaysLeft) days left", for: .normal)
            if freePremiumDaysLeft == 0 {
                premiumButton.tintColor = .systemRed
            } else {
                premiumButton.tintColor = .systemBlue
            }
        }
    }

    private func preFillValues() {
        firstInputTextField.text = "messi"
        secondInputTextField.text = "ronaldo"
        questionTextField.text = "best footballer"
    }

    private func setupResponseTableView() {
        responseTableView.delegate = self
        responseTableView.dataSource = self
        responseTableView.register(UINib(nibName: ParagraphTableViewCell.identifier, bundle: nil),
                                   forCellReuseIdentifier: ParagraphTableViewCell.identifier)
        responseTableView.register(UINib(nibName: ComparisonTableViewCell.identifier, bundle: nil),
                                   forCellReuseIdentifier: ComparisonTableViewCell.identifier)
        responseTableView.separatorStyle = .none
    }

    private func setupAnimationView() {
        loaderAnimationView = LottieAnimationView(name: "loader-cube")
        loaderAnimationView.loopMode = .loop
        loaderStackView.addArrangedSubview(loaderAnimationView)
        loaderStackView.isHidden = true
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        return
    }

    @objc func firstImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        firstImageViewFlag = true
        showEditImageActionSheet()
    }

    @objc func secondImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        firstImageViewFlag = false
        showEditImageActionSheet()
    }

    func showEditImageActionSheet() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.present(self.imagePickerVC, animated: true)
            }
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.openPHPicker()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(camera)
        sheet.addAction(photoLibrary)
        sheet.addAction(cancel)
        present(sheet, animated: true, completion: nil)
    }

    func showHamburgerActionSheet() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let tutorial = UIAlertAction(title: "Tutorial", style: .default) { _ in
            let tutorial = TutorialViewController()
            self.present(tutorial, animated: true)
        }
        let logout = UIAlertAction(title: "Logout", style: .default) { _ in
            let alert = UIAlertController(title: "Logout", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                KeychainItem.deleteUserIdentifierFromKeychain()
                UserDefaults.standard.reset()
                self.premiumButton.isHidden = false
            }))
            self.present(alert, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(tutorial)
        sheet.addAction(logout)
        sheet.addAction(cancel)
        present(sheet, animated: true, completion: nil)
    }

    private func openPHPicker() {
       var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
       phPickerConfig.selectionLimit = 1
        phPickerConfig.filter = PHPickerFilter.any(of: [.images])
       let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
       phPickerVC.delegate = self
       present(phPickerVC, animated: true)
   }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else { return }
        if(firstImageViewFlag) {
            firstImageView.contentMode = .scaleAspectFill
            firstImageView.image = image
        } else {
            secondImageView.contentMode = .scaleAspectFill
            secondImageView.image = image
        }
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    if(self.firstImageViewFlag) {
                        self.firstImageView.contentMode = .scaleAspectFill
                        self.firstImageView.image = image
                    } else {
                        self.secondImageView.contentMode = .scaleAspectFill
                        self.secondImageView.image = image
                    }
                }
            }
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

extension UIView {
    func addGreyBorder() {
        layer.borderColor = UIColor.gray.cgColor
        layer.masksToBounds = true
        contentMode = .scaleToFill
        layer.borderWidth = 2
        contentMode = .center
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        if sections != nil {
            count = 3
        }
        return count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Introduction"
        } else if section == 1 {
            return "Comparison Table"
        } else if section == 2 {
            return "Conclusion"
        }
        return ""
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sections = sections else {
            return UITableViewCell()
        }
        if indexPath.section == 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: ParagraphTableViewCell.identifier) as! ParagraphTableViewCell
            cell.configure(with: sections.introduction)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ComparisonTableViewCell.identifier) as! ComparisonTableViewCell
            cell.configure(rows: sections.comparisonTable)
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ParagraphTableViewCell.identifier) as! ParagraphTableViewCell
            cell.configure(with: sections.conclusion)
            return cell
        }
        return UITableViewCell()
    }
}
