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

    app.get(":route") { req -> String in
        guard let route = req.parameters.get("route") else {
            throw Abort(.badRequest)
        }

        let hash = hashingService.generateSHA256Hash(for: route)
        do {
            return try fileHandlingService.retrieveFile(named: hash)
        } catch {
            return "File not found for hash: \(hash)"
        }
    }
}