import Vapor

func routes(_ app: Application) throws {
    
    app.get("favicon.ico") { req in
        return("I don't have one ):")
    }
    
    let hashingService = HashingService()
    let fileHandlingService = FileHandlingService()

    app.get(":route") { req -> Response in
        let route: String = try req.parameters.require("route")
        let hash = hashingService.generateSHA256Hash(for: route)
        print("Hash: \(hash)")
        var content: String = ""

        do {
            content = try await fileHandlingService.retrieveFile(named: hash, on: req)
        } catch {
            try await fileHandlingService.createFile(named: hash, on: req)
            content = try await fileHandlingService.retrieveFile(named: hash, on: req)
        }
        return Response(status: .ok, body: Response.Body(string: content))
    }
}
