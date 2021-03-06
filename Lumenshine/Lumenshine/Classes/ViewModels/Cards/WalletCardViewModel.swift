//
//  WalletCardViewModel.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/20/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import stellarsdk

class WalletCardViewModel : CardViewModelType {
    weak var navigationCoordinator: CoordinatorType?
    
    fileprivate var card: Card?
    fileprivate let stellarSdk: StellarSDK
    fileprivate var funded: Bool = false
    fileprivate var needsRefresh: Bool = false
    
    var wallet: Wallet
    
    var receivePaymentAction: (() -> ())?
    var sendAction: (() -> ())?
    var reloadCardsClosure: (() -> ())?
    var reloadClosure: ((Bool) -> ())?
    
    init(userManager: UserManager, walletResponse: WalletsResponse) {
        self.stellarSdk = StellarSDK()
        
        self.wallet = Wallet(walletResponse: walletResponse)
        
        userManager.walletDetailsFor(wallets: [walletResponse]) { result in
            switch result {
            case .success(let wallets):
                guard let wallet = wallets.first else { return }
                self.wallet = wallet
                self.reloadClosure?(true)
            case .failure(let error):
                print("Account details failure: \(error)")
            }
        }
    }
    
    init(wallet: Wallet) {
        self.stellarSdk = StellarSDK()
        
        self.wallet = wallet
        funded = wallet.isFunded
    }
    
    func refreshContent(userManager: UserManager) {
        if needsRefresh == false { return }
        
        userManager.walletDetails(wallet: wallet) { [weak self] result in
            switch result {
            case .success(let wallets):
                guard let wallet = wallets.first else { return }
                self?.wallet = wallet
                
                if (wallet as? FundedWallet)?.showOnHomescreen == false {
                    self?.reloadCardsClosure?()
                }
                
                self?.reloadClosure?(false)
                
                self?.needsRefresh = false
            case .failure(let error):
                print("Account details failure: \(error)")
            }
        }
    }
    
    var type: CardType {
        return .wallet(status: wallet.status)
    }
    
    var imageURL: URL? {
        guard let urlString = card?.imgUrl else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var image: UIImage? {
        return nil
    }
    
    var linkURL: URL? {
        guard let urlString = card?.link else { return nil }
        guard let url = URL(string: urlString) else { return nil}
        return url
    }
    
    var title: String? {
        return wallet.name
    }
    
    var detail: String? {
        return card?.detail
    }
    
    var nativeBalance: CoinUnit? {
        return wallet.nativeBalance
    }
    
    var bottomTitles: [String]? {
        if !funded {
            return [R.string.localizable.fund_wallet()]
        } else {
            return [R.string.localizable.send(),
                    R.string.localizable.receive(),
                    R.string.localizable.details()]
        }
    }
    
    func barButtonSelected(at index: Int) {
        switch type {
        case .web:
            guard let url = linkURL else { return }
            navigationCoordinator?.performTransition(transition: .showOnWeb(url))
        default:
            break
        }
    }
    
    @objc func didTapSendButton() {
        sendAction?()
        needsRefresh = true
    }
    
    @objc func didTapReceiveButton() {
        receivePaymentAction?()
        needsRefresh = true
    }
    
    @objc func didTapDetailsButton() {
        navigationCoordinator?.performTransition(transition: .showCardDetails(wallet))
        needsRefresh = true
    }
    
    @objc func didTapHelpButton() {
        navigationCoordinator?.performTransition(transition: .showWalletCardInfo)
    }
    
    @objc func didTapFundButton() {
        navigationCoordinator?.performTransition(transition: .showScan(wallet))
        needsRefresh = true
    }
}

fileprivate extension WalletCardViewModel {
    func showBalances(_ balances: [AccountBalanceResponse]) {
        
    }
}
