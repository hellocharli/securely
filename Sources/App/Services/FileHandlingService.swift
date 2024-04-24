import Vapor

struct FileHandlingService {
    let directory = DirectoryConfiguration.detect().workingDirectory

    func retrieveFile(named hash: String) throws -> String {
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent("Files").appendingPathComponent(hash)
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw Abort(.notFound)
        }
    }

    func createOrUpdateFile(named hash: String, content: String) throws {
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent("Files").appendingPathComponent(hash)
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            throw Abort(.internalServerError)
        }
    }
}