//
//  ProvideInflationDestinationViewController.swift
//  Lumenshine
//
//  Created by Soneso on 05/09/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum SetButtonTitles: String {
    case set = "SET"
    case validating = "validating & setting"
}

fileprivate enum PublicKeyValidationErrors: String {
    case mandatory = "Public key of destination account needed"
    case notFound = "Public key not found"
}

class ProvideInflationDestinationViewController: UIViewController {
    @IBOutlet weak var publicKeyValidationView: UIView!
    @IBOutlet weak var passwordViewContainer: UIView!
    
    @IBOutlet weak var publicKeyTextField: UITextField!
    
    @IBOutlet weak var publicKeyValidationLabel: UILabel!
    
    @IBOutlet weak var setButton: UIButton!
    
    var wallet: FundedWallet!
    
    private let passwordManager = PasswordManager()
    private let walletManager = WalletManager()
    private let inflationManager = InflationManager()
    private var passwordView: PasswordView!
    
    private var hasEnoughFunding: Bool {
        get {
            return walletManager.hasWalletEnoughFunding(wallet: wallet)
        }
    }
    
    private var isAddressValid: Bool {
        get {
            if let address = publicKeyTextField.text, address.isMandatoryValid() {
                if address.isBase64Valid() {
                    return true
                }
                
                showValidationError(for: publicKeyValidationView)
                publicKeyValidationLabel.text = ValidationErrors.InvalidAddress.rawValue
                return false
                
            } else {
                showValidationError(for: publicKeyValidationView)
                publicKeyValidationLabel.text = PublicKeyValidationErrors.mandatory.rawValue
            }
            
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPasswordView()
        
        setButton.backgroundColor = Stylesheet.color(.green)
    }
    
    @IBAction func setButtonAction(_ sender: UIButton) {
        addInflation()
    }
    
    private func addInflation(biometricAuth: Bool = false) {
        passwordView.resetValidationErrors()
        setButton.setTitle(SetButtonTitles.validating.rawValue, for: UIControlState.normal)
        setButton.isEnabled = false
        
        if isInputDataValid(biometricAuth: biometricAuth) {
            guard self.hasEnoughFunding else {
                self.showFundingAlert()
                return
            }
            
            if let inflationDestination = publicKeyTextField.text {
                if passwordView.useExternalSigning {
                    self.setInflationDestination(inflationDestination: inflationDestination)
                } else {
                    validatePasswordAndAddInflation(inflationDestination: inflationDestination, biometricAuth: biometricAuth)
                }
            }
        } else {
            resetSetButtonToDefault()
        }
    }
    
    private func validatePasswordAndAddInflation(inflationDestination: String, biometricAuth: Bool) {
        passwordManager.getMnemonic(password: !biometricAuth ? passwordView.passwordTextField.text : nil) { (response) -> (Void) in
            switch response {
            case .success(_):
                self.setInflationDestination(inflationDestination: inflationDestination)
            case .failure(error: let error):
                print("Error: \(error)")
                self.passwordView.showInvalidPasswordError()
                self.resetSetButtonToDefault()
            }
        }
    }
    
    private func resetSetButtonToDefault() {
        setButton.setTitle(SetButtonTitles.set.rawValue, for: UIControlState.normal)
        setButton.isEnabled = true
    }
    
    private func showValidationError(for view: UIView) {
        view.isHidden = false
    }
    
    private func showFundingAlert() {
        self.displaySimpleAlertView(title: "Setting failed", message: "Insufficient funding. Please send lumens to your wallet first.")
    }
    
    private func setInflationDestination(inflationDestination: String) {
        let signer = passwordView.useExternalSigning ? passwordView.signersTextField.text : nil
        let seed = passwordView.useExternalSigning ? passwordView.seedTextField.text : nil
        inflationManager.setInflationDestination(inflationAddress: inflationDestination,
                                                 sourceAccountID: wallet.publicKey,
                                                 externalSigner: signer,
                                                 externalSignersSeed: seed,
                                                 completion: { (response) -> (Void) in
            switch response {
            case .success:
                break
            case .failure(error: let error):
                if error == InflationDestinationErrorCodes.accountNotFound {
                    self.showValidationError(for: self.publicKeyValidationView)
                    self.publicKeyValidationLabel.text = ValidationErrors.AddressNotFound.rawValue
                    self.resetSetButtonToDefault()
                    return
                }
                
                print("Error: \(error)")
            }
            
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    private func isInputDataValid(biometricAuth: Bool) -> Bool {
        let isAddressValid = self.isAddressValid
        let isPasswordValid = passwordView.validatePassword(biometricAuth: biometricAuth)

        return isAddressValid && isPasswordValid
    }
    
    private func setupPasswordView() {
        passwordView = Bundle.main.loadNibNamed("PasswordView", owner: self, options: nil)![0] as? PasswordView
        passwordView.neededSigningSecurity = .medium
        passwordView.hideTitleLabels = true
        passwordView.wallet = wallet
        
        passwordView.biometricAuthAction = {
            self.addInflation(biometricAuth: true)
        }
        
        passwordViewContainer.addSubview(passwordView)
        
        passwordView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
