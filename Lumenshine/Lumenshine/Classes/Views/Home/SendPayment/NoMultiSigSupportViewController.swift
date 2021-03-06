//
//  NoMultiSigSupportViewController.swift
//  Lumenshine
//
//  Created by Soneso on 01/10/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class NoMultiSigSupportViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setup()
    }
    
    private func setup() {
        titleLabel.text = "No signer found!"
        descriptionLabel.text = "No signer found that has enough weight to sign the payment transaction. No multisig supported."
    }
    
    private func setupNavigationItem() {
        navigationItem.titleLabel.text = "Error"
        navigationItem.titleLabel.textColor = Stylesheet.color(.white)
        navigationItem.titleLabel.font = R.font.encodeSansSemiBold(size: 15)
    }
}
