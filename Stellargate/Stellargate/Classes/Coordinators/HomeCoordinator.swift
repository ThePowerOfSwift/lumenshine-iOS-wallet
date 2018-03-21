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
    
    init(service: HomeService) {
        let viewModel = HomeViewModel(service: service)
        let homeView = HomeViewController(viewModel: viewModel)
        
        self.baseController = homeView
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showHeaderMenu(let titles, let icons):
            showHeaderMenu(titles: titles, icons: icons)
        case .showOnWeb(let url):
            showOnWeb(url: url)
        case .showScan:
            showScan()
        default: break
        }
    }
}

fileprivate extension HomeCoordinator {
    func showHeaderMenu(titles: [String], icons: [UIImage?]) {
        let headerVC = HeaderMenuViewController(titles: titles, icons: icons)
        headerVC.delegate = self.baseController as! HomeViewController
        
        headerVC.modalPresentationStyle = .overCurrentContext
        
        self.baseController.present(headerVC, animated: true)
    }
    
    func showOnWeb(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showScan() {
        let scanVC = ScanViewController()
        scanVC.delegate = self.baseController as! HomeViewController
        self.baseController.navigationController?.pushViewController(scanVC, animated: true)
    }
}

