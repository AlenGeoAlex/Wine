//
//  KeychainHelper.swift
//  Wine
//
//  Created by Alen Alex on 21/06/25.
//
import Foundation
import Security

class KeychainHelper {
    
    static func saveJSON(_ json: [String: Any], forKey key: String) throws {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeyChainError.unExpectedError(status)
        }
    }
    
    static func loadJSON(forKey key: String) throws -> [String: Any] {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeyChainError.unExpectedError(status)
        }
        guard let data = result as? Data else {
            throw KeyChainError.noData
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw KeyChainError.decodingFailed
        }
        return json
    }
    
    static func loadSettings<T: Codable>(forService service: String) throws -> T {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : service,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { throw KeyChainError.unExpectedError(status) }
        guard let data = result as? Data else { throw KeyChainError.noData }

        return try JSONDecoder().decode(T.self, from: data)
    }
    
    static func saveSettings<T: Codable>(_ settings: T, forService service: String) throws {
        let data = try JSONEncoder().encode(settings)

        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : service,
            kSecValueData as String   : data
        ]

        // Remove existing entry if it exists
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeyChainError.unExpectedError(status)
        }
    }

}
