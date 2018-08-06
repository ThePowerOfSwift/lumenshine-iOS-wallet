//
//  HomeCoordinator.swift
//  jupiter
//
//  Created by Istvan Elekes on 3/5/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class HomeCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    init(service: HomeService, user: User) {
        let viewModel = HomeViewModel(service: service, user: user)
        let homeView = HomeViewController(viewModel: viewModel)
        
        self.baseController = homeView
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showHeaderMenu(let items):
            showHeaderMenu(items: items)
        case .showOnWeb(let url):
            showOnWeb(url: url)
        case .showScan(let wallet):
            showScan(wallet: wallet)
        case .showCardDetails(let wallet):
            showCardDetails(wallet: wallet)
        case .showWalletCardInfo:
            showWalletCardInfo()
        default: break
        }
    }
}

fileprivate extension HomeCoordinator {
    func showHeaderMenu(items: [(String, String)]) {
        let headerVC = HeaderMenuViewController(items: items)
        headerVC.delegate = self.baseController as! HomeViewController
        
        headerVC.modalPresentationStyle = .overCurrentContext
        
        self.baseController.present(headerVC, animated: true)
    }
    
    func showOnWeb(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showScan(wallet: Wallet?) {
        let foundViewController = FoundAccountViewController(nibName: "FoundAccountViewController", bundle: Bundle.main)
        foundViewController.wallet = wallet
        self.baseController.present(foundViewController, animated: true)
    }
    
    func showCardDetails(wallet: Wallet) {
        let foundViewController = AccountDetailsViewController(nibName: "AccountDetailsViewController", bundle: Bundle.main)
        foundViewController.flowDelegate = self
        foundViewController.wallet = wallet
        let navigationController = BaseNavigationViewController(rootViewController: foundViewController)
        self.baseController.present(navigationController, animated: true)
    }
    
    func showWalletCardInfo() {
        let infoViewController = WalletCardInfoViewController(nibName: "WalletCardInfoViewController", bundle: Bundle.main)
        self.baseController.present(infoViewController, animated: true)
    }
}

extension HomeCoordinator: AccountDetailsViewControllerFlow {

    func backButtonPressed(from viewController:UIViewController) {
        viewController.navigationController?.dismiss(animated: true)
    }
    
    func closeButtonPressed(from viewController:UIViewController) {
        
    }
    
}

