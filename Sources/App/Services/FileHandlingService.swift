import Vapor

struct FileHandlingService {
    let directory = DirectoryConfiguration.detect().workingDirectory
    let contentDirectory = "Pages"
    let templateName = "template.html"

    func retrieveFile(named hash: String, on req: Request) async throws -> String {
        let fileURL = URL(fileURLWithPath: directory)
                        .appendingPathComponent(contentDirectory)
                        .appendingPathComponent("\(hash).html")
        do {
            print("Attempting to retrieve file \(fileURL)")
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            print("File retrieved successfully.")
            return content
        } catch {
            print("Failed to retrieve the file: \(error)")
            throw Abort(.notFound)
        }
    }
    
    func createFile(named hash: String, on req: Request) async throws {
        let fileURL = URL(fileURLWithPath: directory)
                      .appendingPathComponent(contentDirectory)
                      .appendingPathComponent("\(hash).html")
        let templateURL = URL(fileURLWithPath: directory)
                          .appendingPathComponent(contentDirectory)
                          .appendingPathComponent(templateName)
        let fileManager = FileManager.default
        do {
            print("Attempting to create file \(fileURL)")
            let template = try Data(contentsOf: templateURL)
            if fileManager.createFile(atPath: fileURL.path(), contents: template) {
                print("File successfully created.")
            } else {
                throw Abort(.internalServerError)
            }
        } catch {
            print("Template not found.")
        }
    }
}
