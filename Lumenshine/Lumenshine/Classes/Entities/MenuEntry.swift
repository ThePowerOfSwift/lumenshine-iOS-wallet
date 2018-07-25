//
//  MenuEntry.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 6/15/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation
import Rswift

enum MenuEntry {
    // Dashboard
    case avatar
    case home
    case wallets
    case transactions
    case currencies
    case contacts
    case extras
    case settings
    case help
    
    // Login
    case login
    case signOut
    case signUp
    case lostPassword
    case lost2FA
    case importMnemonic
    case fingerprint
    case faceRecognition
    case about
    
    var name: String {
        switch self {
        case .avatar:
            return R.string.localizable.not_logged_in()
        case .home:
            return R.string.localizable.home()
        case .wallets:
            return R.string.localizable.wallets()
        case .transactions:
            return R.string.localizable.transactions()
        case .currencies:
            return R.string.localizable.currencies()
        case .contacts:
            return R.string.localizable.contacts()
        case .extras:
            return R.string.localizable.extras()
        case .settings:
            return R.string.localizable.settings()
        case .help:
            return R.string.localizable.help()
        case .login:
            return R.string.localizable.login()
        case .signOut:
            return R.string.localizable.signout()
        case .signUp:
            return R.string.localizable.signup()
        case .lostPassword:
            return R.string.localizable.lost_password()
        case .lost2FA:
            return R.string.localizable.lost_2fa()
        case .importMnemonic:
            return R.string.localizable.import_mnemonic()
        case .about:
            return R.string.localizable.about()
        case .fingerprint:
            return R.string.localizable.fingerprint()
        case .faceRecognition:
            return R.string.localizable.face_recognition()
        }
    }
    
    var icon: ImageResource {
        switch self {
        case .avatar:
            return R.image.rocket
        case .home:
            return R.image.home
        case .wallets:
            return R.image.money1
        case .transactions:
            return R.image.top_list
        case .currencies:
            return R.image.money2
        case .contacts:
            return R.image.users
        case .extras:
            return R.image.puzzlePiece
        case .settings:
            return R.image.gear
        case .help:
            return R.image.question
        case .login:
            return R.image.signIn
        case .signOut:
            return R.image.signOut
        case .signUp:
            return R.image.pencil
        case .lostPassword:
            return R.image.compose
        case .lost2FA:
            return R.image.combination_lock
        case .importMnemonic:
            return R.image.user_add
        case .about:
            return R.image.star
        case .fingerprint:
            return R.image.fingerprint
        case .faceRecognition:
            return R.image.face_recognition
        }
        
    }
}