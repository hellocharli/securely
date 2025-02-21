import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) async throws {
    // Register Leaf provider
    app.views.use(.leaf)

    // Serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register routes
    try routes(app)
}
