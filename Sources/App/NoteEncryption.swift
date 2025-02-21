import Crypto
import Foundation

struct NoteEncryption {
    static let salt = "my-fixed-salt".data(using: .utf8)! // Fixed salt for simplicity

    static func encrypt(noteContent: String, noteName: String) throws -> Data {
        let key = try generateKey(from: noteName)
        let sealedBox = try AES.GCM.seal(noteContent.data(using: .utf8)!, using: SymmetricKey(data: key))
        return sealedBox.combined!
    }

    static func decrypt(encryptedData: Data, noteName: String) throws -> String {
        let key = try generateKey(from: noteName)
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: SymmetricKey(data: key))
        return String(data: decryptedData, encoding: .utf8) ?? ""
    }

    private static func generateKey(from noteName: String) throws -> Data {
        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: (noteName + String(data: salt, encoding: .utf8)! ).data(using: .utf8)!),
            salt: salt,
            outputByteCount: 32
        )
        return Data(derivedKey.withUnsafeBytes { Data($0) })
    }

    static func hashNoteName(noteName: String) throws -> String {
        let digest = SHA256.hash(data: noteName.data(using: .utf8)!)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
