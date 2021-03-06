//
//  ProvideCurrencyDataViewController.swift
//  Lumenshine
//
//  Created by Soneso on 24/08/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import UIKit
import stellarsdk

fileprivate enum AddButtonTitles: String {
    case add = "Add"
    case validating = "Validating & adding"
}

fileprivate enum AlphanumericTypesMaximumLength: Int {
    case alphanumeric4 = 4
    case alphanumeric12 = 12
}

class ProvideCurrencyDataViewController: UIViewController {
    @IBOutlet weak var currencyValidationStackView: UIStackView!
    @IBOutlet weak var issuerValidationStackView: UIStackView!
    @IBOutlet weak var passwordValidationStackView: UIStackView!
    
    @IBOutlet weak var assetCodeTextField: UITextField!
    @IBOutlet weak var publicKeyTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordValidationLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        resetValidationErrors()
        
        addButton.setTitle(AddButtonTitles.validating.rawValue, for: UIControlState.normal)
        addButton.isEnabled = false
        
        if self.isInputDataValid {
            guard self.hasEnoughFunding else {
                self.showFundingAlert()
                return
            }

            if let assetCode = assetCodeTextField.text, let issuer = publicKeyTextField.text {
                inputDataValidator.isPasswordAndDestinationAddresValid(address: issuer, password: !passwordTextField.isHidden ? passwordTextField.text : nil) { (passwordAndAddressResponse) -> (Void) in
                    switch passwordAndAddressResponse {
                    case .success(userMnemonic: let userMnemonic):
                        let transactionHelper = TransactionHelper()
                        
                        var assetType: Int32? = nil
                        
                        if assetCode.count <= AlphanumericTypesMaximumLength.alphanumeric4.rawValue {
                            assetType = AssetType.ASSET_TYPE_CREDIT_ALPHANUM4
                        } else {
                            assetType = AssetType.ASSET_TYPE_CREDIT_ALPHANUM12
                        }
                        
                        let issuerKeyPair = try? KeyPair(accountId: issuer)
                        
                        if let assetType = assetType,
                            let issuerKeyPair = issuerKeyPair,
                            let asset = Asset(type: assetType, code: assetCode, issuer: issuerKeyPair) {
                            
                            transactionHelper.addTrustLine(asset: asset, userMnemonic: userMnemonic, completion: { (status) -> (Void) in
                                switch status {
                                case .success:
                                    break
                                case .failure(let error):
                                    print("Error: \(error)")
                                    self.resetAddButtonToDefault()
                                }
                                
                                self.dismiss(animated: true)
                            })
                        }

                    case .failure(errorCode: let errorCode):
                        switch errorCode {
                        case .addressNotFound:
                            self.showValidationError(for: self.issuerValidationStackView)
                        case .incorrectPassword:
                            self.showValidationError(for: self.passwordValidationStackView)
                            self.passwordValidationLabel.text = ValidationErrors.InvalidPassword.rawValue
                        case .enterPasswordPressed:
                            self.passwordTextField.isHidden = false
                        }
                        
                        self.resetAddButtonToDefault()
                    }
                }
            }
        } else {
            resetAddButtonToDefault()
        }
    }
    
    var wallet: FoundedWallet!
    
    private let passwordManager = PasswordManager()
    
    private var walletManager = WalletManager()
    private var inputDataValidator = InputDataValidator()
    
    private var stellarSDK: StellarSDK {
        get {
            return Services.shared.stellarSdk
        }
    }
    
    private var authService: AuthService {
        get {
            return Services.shared.auth
        }
    }
    
    private func showValidationError(for stackView: UIStackView) {
        stackView.isHidden = false
    }
    
    private func resetValidationErrors() {
        currencyValidationStackView.isHidden = true
        issuerValidationStackView.isHidden = true
        passwordValidationStackView.isHidden = true
    }
    
    private func resetAddButtonToDefault() {
        self.addButton.setTitle(AddButtonTitles.add.rawValue, for: UIControlState.normal)
        self.addButton.isEnabled = true
    }
    
    private var isAddressValid: Bool {
        get {
            if let address = publicKeyTextField.text, address.isMandatoryValid(), address.isBase64Valid() {
                return true
            } else {
                showValidationError(for: issuerValidationStackView)
            }
            
            return false
        }
    }
    
    private var isAssetCodeValid: Bool {
        get {
            if let assetCode = assetCodeTextField.text, assetCode.isAssetCodeValid() {
                return true
            }
            
            showValidationError(for: currencyValidationStackView)
            return false
        }
    }
    
    private var isPasswordValid: Bool {
        get {
            if let password = passwordTextField.text, password.isValidPassword() {
                return true
            }
            
            showValidationError(for: passwordValidationStackView)
            passwordValidationLabel.text = ValidationErrors.MandatoryPassword.rawValue
            return false
        }
    }
    
    private var isInputDataValid: Bool {
        get {
            let isAssetCodeValid = self.isAssetCodeValid
            let isAddressValid = self.isAddressValid
            
            if passwordTextField.isHidden {
                if !isAssetCodeValid || !isAddressValid {
                    return false
                }
                
                return true
            }
            
            let isPasswordValid = self.isPasswordValid
            return isAssetCodeValid && isAddressValid && isPasswordValid
        }
    }
    
    private var hasEnoughFunding: Bool {
        get {
            return walletManager.hasWalletEnoughFunding(wallet: wallet)
        }
    }
    
    private func showFundingAlert() {
        self.displaySimpleAlertView(title: "Adding failed", message: "Insufficient funding. Please send lumens to your wallet first.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if BiometricHelper.isBiometricAuthEnabled {
            passwordTextField.isHidden = true
        }
    }
}
