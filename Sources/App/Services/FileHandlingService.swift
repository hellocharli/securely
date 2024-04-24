import Vapor

struct FileHandlingService {
    let directory = DirectoryConfiguration.detect().workingDirectory

    func retrieveFile(named hash: String, on req: Request) -> EventLoopFuture<String> {
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent("Files").appendingPathComponent(hash)
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            return req.eventLoop.makeSucceededFuture(content)
        } catch {
            return req.eventLoop.makeFailedFuture(Abort(.notFound))
        }
    }

    func createOrUpdateFile(named hash: String, content: String, on req: Request) -> EventLoopFuture<Void> {
        let fileURL = URL(fileURLWithPath: directory).appendingPathComponent("Files").appendingPathComponent(hash)
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return req.eventLoop.makeSucceededFuture(())
        } catch {
            return req.eventLoop.makeFailedFuture(error)
        }
    }
}
