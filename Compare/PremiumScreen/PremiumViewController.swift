//
//  PremiumViewController.swift
//  Compare
//
//  Created by Aanchal Patial on 15/03/24.
//

import UIKit
import AuthenticationServices
import StoreKit
import Lottie

class PremiumViewController: UIViewController {

    @IBOutlet weak var welcomeStackView: UIStackView!
    
    @IBOutlet weak var fullNameLabel: UILabel!

    @IBOutlet weak var loginProviderStackView: UIStackView!

    @IBOutlet weak var premiumStackView: UIStackView!
    
    @IBOutlet weak var freeTrialLabel: UILabel!

    @IBAction func buyPremiumPressed(_ sender: UIButton) {
        buyPremium()
    }

    private var product: SKProduct?
    private let premiumAccessIdentifier = "PremiumAccessEnabled"
    private let freePremiumDaysLeft: Int
    @IBOutlet weak var restorePremiumButton: UIButton!
    
    @IBAction func restorePremiumPressed(_ sender: UIButton) {
        restorePremium()
    }

    init(freePremiumDaysLeft: Int) {
        self.freePremiumDaysLeft = freePremiumDaysLeft
        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder: NSCoder) {
        fatalError("This class does not support NSCoder")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                // The Apple ID credential is valid.
                DispatchQueue.main.async {
                    self.setupForPremium()
                }
            case .revoked, .notFound:
                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                DispatchQueue.main.async {
                    self.setupProviderLoginView()
                }
            default:
                break
            }
        }
        // Do any additional setup after loading the view.
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        performExistingAccountSetupFlows()
//    }

    func setupForPremium() {
        setupWelcomeStackView()
        premiumStackView.isHidden = false
        loginProviderStackView.isHidden = true
        restorePremiumButton.addGreyBorder()
        freeTrialLabel.text = "Free Trial! \(freePremiumDaysLeft) Days Left"
        if freePremiumDaysLeft == 0 {
            freeTrialLabel.textColor = .systemRed
        } else {
            freeTrialLabel.textColor = .systemBlue
        }
        fetchProducts()
    }

    func setupWelcomeStackView() {
        welcomeStackView.isHidden = false
        let welcomeAnimationView = LottieAnimationView(name: "welcome-colorful")
        welcomeStackView.insertArrangedSubview(welcomeAnimationView, at: 0)
        welcomeAnimationView.loopMode = .loop
        welcomeAnimationView.play()
        fullNameLabel.text = UserDefaults.standard.string(forKey: "full-name")
    }

    func setupProviderLoginView() {
        welcomeStackView.isHidden = true
        premiumStackView.isHidden = true
        loginProviderStackView.isHidden = false
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }

//    func performExistingAccountSetupFlows() {
//        // Prepare requests for both Apple ID and password providers.
//        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
//                        ASAuthorizationPasswordProvider().createRequest()]
//
//        // Create an authorization controller with the given requests.
//        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }

    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension PremiumViewController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:

            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            _ = appleIDCredential.email

            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            UserDefaults.standard.set(fullName?.givenName, forKey: "full-name")

            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            DispatchQueue.main.async {
                self.setupForPremium()
            }
//            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)

        case let passwordCredential as ASPasswordCredential:

            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password

            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }

        default:
            break
        }
    }

    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.example.apple-samplecode.juice", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }

    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
//        guard let viewController = self.presentingViewController as? ResultViewController
//            else { return }
//
//        DispatchQueue.main.async {
//            viewController.userIdentifierLabel.text = userIdentifier
//            if let givenName = fullName?.givenName {
//                viewController.givenNameLabel.text = givenName
//            }
//            if let familyName = fullName?.familyName {
//                viewController.familyNameLabel.text = familyName
//            }
//            if let email = email {
//                viewController.emailLabel.text = email
//            }
//            self.dismiss(animated: true, completion: nil)
//        }
        print("login success: \(fullName?.givenName ?? "-1")")
    }

    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension PremiumViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension PremiumViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {

    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: ["com.compareit.premium"])
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        product = response.products.first
    }
    
    func buyPremium() {
        if let product = product {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }

    func restorePremium() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState {
            case .purchasing, .deferred:
                queue.finishTransaction($0)
            case .purchased, .restored:
                queue.finishTransaction($0)
            case .failed:
                queue.finishTransaction($0)
            @unknown default:
                break
            }
        })
    }
    
    func havePremiumAccess() -> Bool {
        UserDefaults.standard.bool(forKey: premiumAccessIdentifier)
    }

    func updateAppForPremiumAccess() {
        UserDefaults.standard.set(true, forKey: premiumAccessIdentifier)
    }

}
