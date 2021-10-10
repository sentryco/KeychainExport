import Foundation

extension FileManager {
   /**
    * Empties temp folder for files
    */
   internal static func clearTempFolderContent() {
      // Swift.print("clearTempFolderContent")
      let tempFolderURL = URL(fileURLWithPath: NSTemporaryDirectory())
      guard let filePaths: [URL] = try? FileManager.default.contentsOfDirectory(at: tempFolderURL, includingPropertiesForKeys: nil) else { return } // contentsOfDirectory(atPath: "\(tempFolderURL.path)")
      filePaths.forEach {
         do {
            try FileManager.default.removeItem(at: $0)
         } catch {
            Swift.print("Error:  \(error)")
         }
      }
   }
}
