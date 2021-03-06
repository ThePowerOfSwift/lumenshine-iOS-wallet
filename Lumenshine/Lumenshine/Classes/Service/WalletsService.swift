//
//  WalletsService.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 05/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

public enum GetWalletsEnum {
    case success(response: [WalletsResponse])
    case failure(error: ServiceError)
}

public enum ChangeWalletDataEnum {
    case success
    case failure(error: ServiceError)
}

public enum AddWalletEnum {
    case success
    case failure(error: ServiceError)
}

public enum SetWalletHomescreenEnum {
    case success
    case failure(error: ServiceError)
}

public typealias GetWalletsClosure = (_ response: GetWalletsEnum) -> (Void)
public typealias ChangeWalletDataClosure = (_ response: ChangeWalletDataEnum) -> (Void)
public typealias AddWalletClosure = (_ response: AddWalletEnum) -> (Void)
public typealias SetWalletHomescreenClosure = (_ response: SetWalletHomescreenEnum) -> (Void)

public class WalletsService: BaseService {
    
    override init(baseURL: String) {
        super.init(baseURL: baseURL)
    }
    
    open func getWallets(response: @escaping GetWalletsClosure) {
        GETRequestWithPath(path: "/portal/user/dashboard/get_user_wallets") { (result) -> (Void) in
            switch result {
            case .success(let data):
                do {
                    let userWalletsResponse = try self.jsonDecoder.decode(Array<WalletsResponse>.self, from: data)
                    response(.success(response: userWalletsResponse))
                } catch {
                    response(.failure(error: .parsingFailed(message: error.localizedDescription)))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    func changeWalletData(request: ChangeWalletRequest, response: @escaping ChangeWalletDataClosure) {
        POSTRequestWithPath(path: "/portal/user/dashboard/change_wallet_data", parameters: request.toDictionary()) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        }
    }
    
    func removeFederationAddress(walletId: Int, response: @escaping ChangeWalletDataClosure) {
        let params = ["id": walletId]
        
        POSTRequestWithPath(path: "/portal/user/dashboard/remove_wallet_federation_address", parameters: params) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    response(.success)
                case .failure(let error):
                    response(.failure(error: error))
                }
            }
        }
    }
    
    func addWallet(publicKey: String, name: String, federationAddress: String? = "", showOnHomescreen: Bool, completion: @escaping AddWalletClosure) {
        var params = Dictionary<String, Any>()
        params["public_key"] = publicKey
        params["wallet_name"] = name
        params["federation_address"] = federationAddress
        params["show_on_homescreen"] = showOnHomescreen
        
        POSTRequestWithPath(path: "/portal/user/dashboard/add_wallet", parameters: params) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(.success)
                case .failure(let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
    
    func setWalletHomescreen(walletID: Int, isVisible: Bool, completion: @escaping SetWalletHomescreenClosure) {
        var params = Dictionary<String, Any>()
        params["id"] = walletID
        params["visible"] = isVisible
        
        POSTRequestWithPath(path: "/portal/user/dashboard/wallet_set_homescreen", parameters: params) { (result) -> (Void) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(.success)
                case .failure(let error):
                    completion(.failure(error: error))
                }
            }
        }
    }
}
