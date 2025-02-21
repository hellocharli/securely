import Vapor

struct Note {
    let content: String
}

extension Note: Content {}

func routes(_ app: Application) throws {
    let noteController = NoteController()
    app.get(":noteName", use: noteController.show)
    app.post(":noteName", use: noteController.save)
}

struct NoteController: Sendable {
    private let notesDirectory: String = DirectoryConfiguration.detect().workingDirectory + "Public/"
    
    @Sendable
    func show(req: Request) async throws -> View {
        let noteName = req.parameters.get("noteName") ?? "default"
        let hashedNoteName = try NoteEncryption.hashNoteName(noteName)
        let notePath = notesDirectory + hashedNoteName
        
        let noteContent: String
        if FileManager.default.fileExists(atPath: notePath) {
            do {
                let encryptedData = try Data(contentsOf: URL(fileURLWithPath: notePath))
                noteContent = try NoteEncryption.decrypt(encryptedData: encryptedData, noteName: noteName)
            } catch {
                req.logger.error("Failed to decrypt note: \(error)")
                noteContent = ""
            }
        } else {
            noteContent = ""
        }
        
        return try await req.view.render("note", [
            "noteName": noteName,
            "noteContent": noteContent,
            "showNoteContent": (!noteContent.isEmpty).description
        ])
    }
    
    @Sendable
    func save(req: Request) async throws -> Response {
        let noteName = req.parameters.get("noteName") ?? "default"
        let hashedNoteName = try NoteEncryption.hashNoteName(noteName)
        let notePath = notesDirectory + hashedNoteName
        
        let noteContent = try req.content.get(String.self, at: "noteContent")
        let encryptedData = try NoteEncryption.encrypt(noteContent: noteContent, noteName: noteName)
        try encryptedData.write(to: URL(fileURLWithPath: notePath))
        
        return req.redirect(to: "/\(noteName)")
    }
}

struct ErrorResponse: Content {
    let error: String
}

func renderErrorView(_ req: Request, error: Error) async throws -> View {
    req.logger.error("Application error: \(error)")
    return try await req.view.render("error", ["error": "Server error"])
}