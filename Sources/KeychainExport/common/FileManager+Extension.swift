import Foundation

extension FileManager {
   /**
    * Empties temp folder for files
    */
   internal static func clearTempFolderContent() {
      // Swift.print("clearTempFolderContent")
      // Create a URL for the temporary directory
      let tempFolderURL = URL(fileURLWithPath: NSTemporaryDirectory())

      // Try to get the contents of the temporary directory
      // If it fails, exit the function
      guard let filePaths: [URL] = try? FileManager.default.contentsOfDirectory(at: tempFolderURL, includingPropertiesForKeys: nil) else { return } 

      // Loop through each file in the directory
      filePaths.forEach {
         do {
            // Try to remove the file
            try FileManager.default.removeItem(at: $0)
         } catch {
            // If there's an error, print it
            Swift.print("Error:  \(error)")
         }
      }
   }
}
