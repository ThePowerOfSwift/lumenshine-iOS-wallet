//
//  WalletCardContentView.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 11/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class WalletCardContentView: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var stellarAddressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var balanceDescriptionLabel: UILabel!
    @IBOutlet weak var availableDescriptionLabel: UILabel!
    @IBOutlet weak var balanceBackgroundView: UIView!
    @IBOutlet weak var balanceStackView: UIStackView!
    @IBOutlet weak var availableStackView: UIStackView!
    @IBOutlet weak var currencyInfoButton: CurrencyInfoButton!
}
