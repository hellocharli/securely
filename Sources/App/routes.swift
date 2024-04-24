import Vapor

func routes(_ app: Application) throws {
    
    let hashingService = HashingService()
    let fileHandlingService = FileHandlingService()

    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get(":route") { req -> EventLoopFuture<String> in
        guard let route = req.parameters.get("route") else {
            throw Abort(.badRequest)
        }

        let hash = hashingService.generateSHA256Hash(for: route)
        return fileHandlingService.retrieveFile(named: hash, on: req)
            .flatMapError { error in
                if let abortError = error as? Abort, abortError.status == .notFound {
                    // Handle not found error by creating a new file with empty content
                    return fileHandlingService.createOrUpdateFile(named: hash, content: "Initial content", on: req)
                        .flatMap { _ in fileHandlingService.retrieveFile(named: hash, on: req) }
                } else {
                    // If the error is not a 'notFound', propagate it
                    return req.eventLoop.makeFailedFuture(error)
                }
            }
    }
}