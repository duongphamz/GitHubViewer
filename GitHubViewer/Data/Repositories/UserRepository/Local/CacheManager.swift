//
//  CacheManager.swift
//  GitHubViewer
//
//  Created by Duong Pham on 31/12/24.
//

import Foundation
import CryptoKit

// MARK: - CacheManagerProtocol
protocol CacheManagerProtocol {
    // Saves a Codable object to the cache with a specific key
    func save<T: Codable>(_ object: T, forKey key: String)
    
    // Loads a Codable object from the cache using a specific key and returns it as the specified type
    func load<T: Codable>(forKey key: String, as type: T.Type) -> T?
}

// MARK: - CacheManager
class CacheManager: CacheManagerProtocol {
    
    // MARK: - Persistent Key
    // Generate or load a symmetric key for encryption and decryption
    private static let persistentKey: SymmetricKey = {
        // Try to retrieve the previously stored key from UserDefaults
        if let storedKeyData = UserDefaults.standard.data(forKey: "encryptionKey") {
            return SymmetricKey(data: storedKeyData)
        } else {
            // If no key exists, generate a new symmetric key, store it in UserDefaults for future use
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data(Array($0)) }
            UserDefaults.standard.set(keyData, forKey: "encryptionKey")
            return newKey
        }
    }()
    
    // MARK: - Properties
    private let key = CacheManager.persistentKey // Symmetric key for encryption/decryption
    private let fileManager = FileManager.default // FileManager instance for file operations
    private let cacheDirectory: URL? // URL to the cache directory for storing encrypted files
    
    // MARK: - Initializer
    init() {
        // Determine the path for the cache directory
        let cachePath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        cacheDirectory = cachePath?.appendingPathComponent("EncryptedCache")
        
        // Create the directory if it doesn't already exist
        if let cacheDirectory = cacheDirectory, !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Methods
    
    // Saves an object to the cache, encrypted with the symmetric key
    func save<T: Codable>(_ object: T, forKey key: String) {
        // Ensure cache directory exists before proceeding
        guard let cacheDirectory else {
            return
        }
        
        // Construct the full file URL where the object will be stored
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        do {
            // Encode the object to JSON data
            let data = try JSONEncoder().encode(object)
            
            // Encrypt the data using AES-GCM encryption
            let sealedBox = try AES.GCM.seal(data, using: self.key)
            let encryptedData = sealedBox.combined
            
            // Write the encrypted data to the file
            try encryptedData?.write(to: fileURL, options: .atomic)
        } catch {
            // Print an error message if saving fails
            print("Failed to save encrypted data: \(error)")
        }
    }
    
    // Loads an object from the cache, decrypting it using the symmetric key
    func load<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        // Ensure cache directory exists before proceeding
        guard let cacheDirectory else {
            print("Encrypted data is missing or incomplete")
            return nil
        }
        
        // Construct the full file URL to fetch the encrypted data
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        // Try to read the encrypted data from the file
        guard let encryptedData = try? Data(contentsOf: fileURL), encryptedData.count >= 28 else {
            print("Encrypted data is missing or incomplete")
            return nil
        }
        
        do {
            // Decrypt the data using the stored key
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: self.key)
            
            // Decode the decrypted data back into the expected object type
            let object = try JSONDecoder().decode(T.self, from: decryptedData)
            return object
        } catch {
            // Print an error message if loading or decrypting fails
            print("Failed to load decrypted data: \(error)")
            return nil
        }
    }
}


