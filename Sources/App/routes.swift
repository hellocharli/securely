import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get(":route") { req async throws -> String in

        guard let route = req.parameters.get("route")
        else {
            throw Abort(.badRequest)
        }

        return "Your route is: \(route)"

    }
}