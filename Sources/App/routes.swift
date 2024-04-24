import Vapor

func routes(_ app: Application) throws {
    
    let hashingService = HashingService()
    let fileHandlingService = FileHandlingService()

    app.get(":route") { req -> EventLoopFuture<String> in
        guard let route = req.parameters.get("route") else {
            throw Abort(.badRequest)
        }

        let hash = hashingService.generateSHA256Hash(for: route)
        print("Hashed URL: \(hash)")
        return fileHandlingService.retrieveFile(named: hash, on: req)
            .flatMapError { error in
                if let abortError = error as? Abort, abortError.status == .notFound {
                    return fileHandlingService.createOrUpdateFile(named: hash, content: "Initial content", on: req)
                        .flatMap { _ in fileHandlingService.retrieveFile(named: hash, on: req) }
                } else {
                    return req.eventLoop.makeFailedFuture(error)
                }
            }
    }
}