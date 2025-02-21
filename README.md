# Universal Notes

A simple, secure note-taking application built with Vapor that provides encrypted note storage. Notes are encrypted using AES-GCM encryption, with keys derived from the note names using HKDF.

## Features

- Create and edit notes via a web interface
- Notes are encrypted at rest using AES-GCM encryption
- Note names are hashed for privacy
- No database - notes are stored as files

## Requirements

- Swift 5.9+
- macOS or Linux

## Installation

1. Clone the repository:
```bash
git clone https://github.com/hellocharli/universal-notes.git
cd universal-notes
```

2. Build and run the project:
```bash
swift run
```

The server will start at `http://localhost:8080`

## Usage

1. Access a note by navigating to `http://localhost:8080/your-note-name`
2. Type your note content in the textarea
3. Click "Save Note" to save your changes
4. Return to your note anytime using the same URL

## Security Features

- Notes are encrypted using AES-GCM encryption
- Keys are derived using HKDF with SHA-256
- Note names are hashed using SHA-256 before being used as filenames
- Each note has its own encryption key derived from its name

## Project Structure

- `configure.swift`: Application configuration
- `routes.swift`: Route handlers and controllers
- `NoteEncryption.swift`: Encryption/decryption logic
- `Resources/Views/note.leaf`: Note template
- `Public/`: Where the encrypted notes are stored

## Contributing

Feel free to submit issues and pull requests!
