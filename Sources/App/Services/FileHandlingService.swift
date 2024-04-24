import Vapor

struct FileHandlingService {
    let directory = DirectoryConfiguration.detect().workingDirectory
    let contentDirectory = "Content"

    func retrieveFile(named hash: String, on req: Request) -> EventLoopFuture<String> {
        let fileURL = URL(fileURLWithPath: directory)
                        .appendingPathComponent(contentDirectory)
                        .appendingPathComponent(hash)
        do {
            print("Attempting to retrieve file \(fileURL)")
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            print("Retrieved successfully")
            return req.eventLoop.makeSucceededFuture(content)
        } catch {
            return req.eventLoop.makeFailedFuture(Abort(.notFound))
        }
    }

    func createOrUpdateFile(named hash: String, content: String, on req: Request) -> EventLoopFuture<Void> {
        let fileURL = URL(fileURLWithPath: directory)
                      .appendingPathComponent(contentDirectory)
                      .appendingPathComponent(hash)
        
        let fileManager = FileManager.default
        let directoryPath = fileURL.deletingLastPathComponent()

        do {
            if !fileManager.fileExists(atPath: directoryPath.path) {
                print("Attempting to create filepath \(directoryPath.path)")
                try fileManager.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: true, attributes: nil)
                print("Filepath successfully created")
            }
            print("Attempting to write to file...")
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Write successful")
            return req.eventLoop.makeSucceededFuture(())
        } catch {
            return req.eventLoop.makeFailedFuture(error)
        }
    }
}