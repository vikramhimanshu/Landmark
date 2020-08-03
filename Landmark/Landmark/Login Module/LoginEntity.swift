//
//  LoginEntity.swift
//  Landmark
//
//  Created by Tantia, Himanshu on 23/7/20.
//  Copyright © 2020 Himanshu Tantia. All rights reserved.
//

import UIKit

struct LandmarkUser {
    let email : String
    let password : String
}

enum PasswordRule {
    enum ChatacterClass {
        case upper, lower, digits, special, asciiPrintable, unicode
        case custom(Set<Character>)
    }
    
    case required(ChatacterClass)
    case allowed(ChatacterClass)
    case maxConsecutive(UInt)
    case minLength(UInt)
    case maxLength(UInt)
}

extension PasswordRule: CustomStringConvertible {
    var description: String {
        switch self {
        case .required(let chatacterClass):
            return "required: \(chatacterClass)"
        case .allowed(let chatacterClass):
            return "allowed: \(chatacterClass)"
        case .maxConsecutive(let length):
            return "maxConsecutive: \(length)"
        case .minLength(let length):
            return "minLength: \(length)"
        case .maxLength(let length):
            return "maxLength: \(length)"
        }
    }
}

extension PasswordRule.ChatacterClass: CustomStringConvertible {
    var description: String {
        switch self {
        case .upper: return "upper"
        case .lower: return "lower"
        case .digits: return "digits"
        case .special: return "special"
        case .asciiPrintable: return "ascii-printable"
        case .unicode: return "unicode"
        case .custom(let characters):
            return "[" + String(characters) + "]"
        }
    }
}

extension UITextInputPasswordRules {
    convenience init(rules: [PasswordRule]) {
        let descriptor = rules.map{ $0.description }
                                .joined(separator: "; ")
        self.init(descriptor: descriptor)
    }
}
