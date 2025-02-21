import Crypto
import Foundation

enum NoteEncryptionError: Error {
    case invalidEncoding
    case decryptionFailed
}

struct NoteEncryption {
    private static let salt = "my-fixed-salt".data(using: .utf8)!
    
    static func encrypt(noteContent: String, noteName: String) throws -> Data {
        guard let contentData = noteContent.data(using: .utf8) else {
            throw NoteEncryptionError.invalidEncoding
        }
        let key = try generateKey(from: noteName)
        let sealedBox = try AES.GCM.seal(contentData, using: SymmetricKey(data: key))
        return sealedBox.combined!
    }
    
    static func decrypt(encryptedData: Data, noteName: String) throws -> String {
        let key = try generateKey(from: noteName)
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: SymmetricKey(data: key))
        
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw NoteEncryptionError.decryptionFailed
        }
        return decryptedString
    }
    
    static func hashNoteName(_ noteName: String) throws -> String {
        guard let noteData = noteName.data(using: .utf8) else {
            throw NoteEncryptionError.invalidEncoding
        }
        return SHA256.hash(data: noteData)
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
    
    private static func generateKey(from noteName: String) throws -> Data {
        guard let saltString = String(data: salt, encoding: .utf8),
              let inputData = (noteName + saltString).data(using: .utf8) else {
            throw NoteEncryptionError.invalidEncoding
        }
        
        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: inputData),
            salt: salt,
            outputByteCount: 32
        )
        return derivedKey.withUnsafeBytes { Data($0) }
    }
}