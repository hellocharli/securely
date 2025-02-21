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
            let notePath = notesDirectory + noteName + ".txt"
            var noteContent = ""
            if FileManager.default.fileExists(atPath: notePath) {
                let encryptedData = try Data(contentsOf: URL(fileURLWithPath: notePath))
                noteContent = try NoteEncryption.decrypt(encryptedData: encryptedData, noteName: noteName)
            } else {
                noteContent = "Start typing your note here..."
            }
            return try await req.view.render("note", ["noteName": noteName, "noteContent": noteContent])
        } catch {
            return await renderErrorView(req, error: error)
        }
    }

    // Route to handle saving notes
    app.post(":noteName") { req async -> Response in
        let noteName = req.parameters.get("noteName") ?? "default"
        let notesDirectory = app.directory.workingDirectory + "notes/"
        let notePath = notesDirectory + noteName + ".txt"

        let noteContent = try? req.content.get(String.self, at: "noteContent") ?? ""

        do {
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
