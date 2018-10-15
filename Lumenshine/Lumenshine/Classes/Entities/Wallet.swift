//
//  Wallet.swift
//  Lumenshine
//
//  Created by Razvan Chelemen on 11/07/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit
import stellarsdk

public enum WalletStatus {
    case none
    case funded
    case unfunded
}

public class Wallet {
    private let walletResponse: WalletsResponse
    
    var name: String
    var federationAddress: String
    var publicKey: String
    
    init(wallet: Wallet) {
        self.walletResponse = wallet.walletResponse
        self.name = wallet.name
        self.federationAddress = wallet.federationAddress
        self.publicKey = wallet.publicKey
    }
    
    init(walletResponse: WalletsResponse) {
        self.walletResponse = walletResponse
        
        name = walletResponse.walletName
        federationAddress = walletResponse.federationAddress
        publicKey = walletResponse.publicKey
    }
    
    public var id: Int {
        get {
            return walletResponse.id
        }
    }
    
    public var status: WalletStatus {
        get {
            return .none
        }
    }
    
    public var nativeBalance: CoinUnit {
        get {
            return 0
        }
    }
    
    public var isFunded: Bool {
        get {
            return false
        }
    }
}

public class FundedWallet: Wallet {
    
    var balances: [AccountBalanceResponse]
    var subentryCount: UInt!
    var masterKeyWeight: Int!
    
    init(walletResponse: WalletsResponse, accountResponse: AccountResponse) {
        self.balances = accountResponse.balances
        self.subentryCount = accountResponse.subentryCount
        self.masterKeyWeight = accountResponse.signers.first(where: { (signer) -> Bool in
            return signer.publicKey == accountResponse.accountId
        })?.weight
        super.init(walletResponse: walletResponse)
    }
    
    init(wallet: Wallet, accountResponse: AccountResponse) {
        self.balances = accountResponse.balances
        self.subentryCount = accountResponse.subentryCount
        self.masterKeyWeight = accountResponse.signers.first(where: { (signer) -> Bool in
            return signer.publicKey == accountResponse.accountId
        })?.weight
        super.init(wallet: wallet)
    }
    
    override public var status: WalletStatus {
        get {
            return .funded
        }
    }
    
    override public var nativeBalance: CoinUnit {
        get {
            var amount: CoinUnit = 0
            for balance in balances {
                switch balance.assetType {
                case AssetTypeAsString.NATIVE:
                    print("balance: \(balance.balance) XLM")
                    if let units = CoinUnit(balance.balance) {
                        amount += units
                    }
                default:
                    break
                }
            }
            
            return amount
        }
    }
    
    override public var isFunded: Bool {
        get {
            return nativeBalance != 0
        }
    }
}

extension FundedWallet {
    
    public var nativeAsset: AccountBalanceResponse? {
        get {
            return balances.first(where: { (balance) -> Bool in
                return balance.assetCode == nil
            })
        }
    }
    
    public var hasOnlyNative: Bool {
        get {
            for balance in balances {
                switch balance.assetType {
                case AssetTypeAsString.NATIVE:
                    continue
                default:
                    return false
                }
            }
            
            return true
        }
    }
    
    public var hasDuplicateNameCurrencies: Bool {
        get {
            for balance in balances {
                if balances.contains(where: { $0 !== balance && $0.assetCode == balance.assetCode }) {
                    return true
                }
            }
            
            return false
        }
    }
    
    func issuersFor(assetCode: String) -> [String] {
        var issuers = [String]()
        for balance in balances {
            if balance.assetCode == assetCode, let issuer = balance.assetIssuer {
                issuers.append(issuer)
            }
        }
        
        return issuers
    }
    
    var uniqueAssetCodeBalances: [AccountBalanceResponse] {
        get {
            var codes = [AccountBalanceResponse]()
            for balance in balances {
                if let assetCode = balance.assetCode, !codes.map({$0.assetCode}).contains(assetCode) {
                    codes.append(balance)
                }
                if balance.assetType == "native" {
                    codes.append(balance)
                }
            }
            
            return codes
        }
    }
    
    func getAvailableCurrencies() -> [String] {
        var availableCurrencies = [String]()
        for currency in self.uniqueAssetCodeBalances {
            if let balance = CoinUnit(currency.balance), let displayCode = currency.displayCode {
                if (balance != 0) {
                    if currency.displayCode == NativeCurrencyNames.xlm.rawValue {
                        availableCurrencies.insert(displayCode, at: 0)
                    } else {
                        availableCurrencies.append(displayCode)
                    }
                }
            }
        }
        
        return availableCurrencies
    }
    
    func isCurrencyDuplicate(withAssetCode assetCode: String) -> Bool {
        var alreadyFoundOnce: Bool = false
        
        for currency in balances {
            if currency.assetCode == assetCode {
                if !alreadyFoundOnce {
                    alreadyFoundOnce = true
                } else {
                    return true
                }
            }
        }
        
        return false
    }
    
    func isCurrencyDuplicateAndValid(withAssetCode assetCode: String) -> Bool {
        var alreadyFoundOnce: Bool = false
        
        for currency in balances {
            if currency.assetCode == assetCode && CoinUnit(currency.balance) != 0 {
                if !alreadyFoundOnce {
                    alreadyFoundOnce = true
                } else {
                    return true
                }
            }
        }
        
        return false

    }
}
    
public class UnfundedWallet: Wallet {
    override public var status: WalletStatus {
        get {
            return .unfunded
        }
    }
}
