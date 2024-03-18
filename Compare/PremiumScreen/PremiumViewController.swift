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
    @IBOutlet weak var alreadyBoughtPremiumStackView: UIStackView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var loginProviderStackView: UIStackView!
    @IBOutlet weak var buyPremiumStackView: UIStackView!
    @IBOutlet weak var freeTrialLabel: UILabel!
    @IBAction func buyPremiumPressed(_ sender: UIButton) {
        buyPremium()
    }
    @IBOutlet weak var restorePremiumButton: UIButton!
    @IBAction func restorePremiumPressed(_ sender: UIButton) {
        restorePremium()
    }

    private var product: SKProduct?
    private let freePremiumDaysLeft: Int
    // This key should match with the key in app store connect
    private let premiumAccessProductId = "compareit.premium.access"

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
    }

    func setupForPremium() {
        setupWelcomeStackView()
        loginProviderStackView.isHidden = true
        if alreadyPremiumUser() {
            setupForAlreadyBoughtPremium()
        } else {
            alreadyBoughtPremiumStackView.isHidden = true
            fetchInappPremiumAccessProduct()
            buyPremiumStackView.isHidden = false
            restorePremiumButton.addGreyBorder()
            freeTrialLabel.text = "Free Trial! \(freePremiumDaysLeft) Days Left"
            if freePremiumDaysLeft == 0 {
                freeTrialLabel.textColor = .systemRed
            } else {
                freeTrialLabel.textColor = .systemBlue
            }
        }
    }

    private func setupForAlreadyBoughtPremium() {
        buyPremiumStackView.isHidden = true
        alreadyBoughtPremiumStackView.isHidden = false
        let diamondAnimationView = LottieAnimationView(name: "diamond")
        alreadyBoughtPremiumStackView.insertArrangedSubview(diamondAnimationView, at: 0)
        diamondAnimationView.loopMode = .loop
        diamondAnimationView.play()
    }

    func setupWelcomeStackView() {
        welcomeStackView.isHidden = false
        let welcomeAnimationView = LottieAnimationView(name: "welcome-colorful")
        welcomeStackView.insertArrangedSubview(welcomeAnimationView, at: 0)
        welcomeAnimationView.loopMode = .loop
        welcomeAnimationView.play()
        fullNameLabel.text = UserDefaults.standard.string(forKey: UserDefaults.Keys.fullName.rawValue)
    }

    func setupProviderLoginView() {
        welcomeStackView.isHidden = true
        buyPremiumStackView.isHidden = true
        loginProviderStackView.isHidden = false
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }

    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: - Sign in with apple
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
            UserDefaults.standard.set(fullName?.givenName, forKey: UserDefaults.Keys.fullName.rawValue)

            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            DispatchQueue.main.async {
                self.setupForPremium()
            }

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
            try KeychainItem(service: KeychainItem.Constant.service, account: KeychainItem.Constant.account).saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
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

// MARK: - In-app purchase
extension PremiumViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {

    func fetchInappPremiumAccessProduct() {
        let request = SKProductsRequest(productIdentifiers: [premiumAccessProductId])
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        product = response.products.first
        print("🍎 fetched product: = \(product?.price)")
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("🍎Error for request: \(error.localizedDescription)")
    }

    private func alreadyPremiumUser() -> Bool {
        UserDefaults.standard.bool(forKey: UserDefaults.Keys.alreadyPremiumUser.rawValue)
    }

    func buyPremium() {
        guard !alreadyPremiumUser() else {
            print("🍎 already a premium, no need to buy again")
            return
        }
        if let product = product {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }

    func restorePremium() {
        guard !alreadyPremiumUser() else {
            print("🍎 already a premium, no need to restore")
            return
        }
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState {
            case .purchasing:
                print("🍎 premium PURCHASING")
                queue.finishTransaction($0)
            case .deferred:
                print("🍎 premium DEFERRED")
                queue.finishTransaction($0)
            case .purchased:
                print("🍎 premium PURCHASED")
                updateAppForPremiumAccess()
                queue.finishTransaction($0)
            case .restored:
                updateAppForPremiumAccess()
                print("🍎 premium RESTORED")
                queue.finishTransaction($0)
            case .failed:
                print("🍎 premium FAILED")
                queue.finishTransaction($0)
            @unknown default:
                break
            }
        })
    }
    
    func havePremiumAccess() -> Bool {
        UserDefaults.standard.bool(forKey: UserDefaults.Keys.alreadyPremiumUser.rawValue)
    }

    func updateAppForPremiumAccess() {
        UserDefaults.standard.set(true, forKey: UserDefaults.Keys.alreadyPremiumUser.rawValue)
        setupForAlreadyBoughtPremium()
    }
}
