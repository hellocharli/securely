import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // Route to handle notes by name
    app.get(":noteName") { req async -> View in
        let noteName = req.parameters.get("noteName") ?? "default"
        do {
            let notesDirectory = app.directory.workingDirectory + "notes/"
            let hashedNoteName = try NoteEncryption.hashNoteName(noteName: noteName) // Hash the note name
            let notePath = notesDirectory + hashedNoteName // Use hashed name as filename (no extension)
            var noteContent = ""
            if FileManager.default.fileExists(atPath: notePath) {
                do {
                    let encryptedData = try Data(contentsOf: URL(fileURLWithPath: notePath))
                    noteContent = try NoteEncryption.decrypt(encryptedData: encryptedData, noteName: noteName)
                } catch {
                    noteContent = "Error decrypting note. It might be corrupted." // Handle decryption error
                }
            }

            let showNoteContent = !noteContent.isEmpty ? "true" : "false" // Pass "true" or "false" as String
            return try await req.view.render("note", ["noteName": noteName, "noteContent": noteContent, "showNoteContent": showNoteContent])
        } catch let error { // Capture the error
            print("Error in GET /:noteName route: \(error)") // Log the error
            return await renderErrorView(req, error: error)
        }
    }

    // Route to handle saving notes
    app.post(":noteName") { req async -> Response in
        let noteName = req.parameters.get("noteName") ?? "default"
        let notesDirectory = app.directory.workingDirectory + "notes/"
        do {
            let hashedNoteName = try NoteEncryption.hashNoteName(noteName: noteName) // Hash the note name
            let notePath = notesDirectory + hashedNoteName // Use hashed name as filename (no extension)
            let noteContent = try? req.content.get(String.self, at: "noteContent")

            let encryptedData = try NoteEncryption.encrypt(noteContent: noteContent ?? "", noteName: noteName)
            try encryptedData.write(to: URL(fileURLWithPath: notePath))
            return req.redirect(to: "/\(noteName)") // Redirect back to the note view
        } catch {
            return Response(status: .internalServerError)
        }
    }
}

// Helper function to render the error view
func renderErrorView(_ req: Request, error: Error) async -> View {
    return try! await req.view.render("error", ["error": "Server error"])
}
