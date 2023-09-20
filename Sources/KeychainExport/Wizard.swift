import Cocoa
import With

final class Wizard {
   static let keyChainItems = KeychainExport.getKeyChainItems() // get raw keychain types, with meta data, no secret content
   static var exportableItems: [ExportItem] = [] // collect keychain items to save to json here
}
/**
 * Extension
 */
extension Wizard {
   /**
    * begin export process
    */
   public static func beginExport() {
      // Set the title for the introduction alert. The title displays the total number of items in the keychain.
      let introTitle = "There are \(Self.keyChainItems.count) items in keychain"

      // Set the message for the introduction alert. The message advises the user to paste their admin password to expedite the authorization process.
      let introMSG = "Since you will have to authorize each key, we recommend pasting your admin-password to speed up the process"

      // Create an alert with the specified title and message. If the user clicks "OK", the exportSecureNote function is called.
      createAlert(title: introTitle, msg: introMSG, onOk: exportSecureNote)
   }
   /**
    * Begin export process for "secure note"
    */
   private static func exportSecureNote() {
      // Set the title for the alert as "SecureNote"
      let introTitle = "SecureNote"
      
      // Get all the secure note items from the keychain
      let noteItems = KeychainExport.getKeychainItemsByType(items: Self.keyChainItems, type: .note)
      
      // Set the message for the alert, indicating the number of secure notes to be exported
      let introMSG = "Do you want to export \(noteItems.count) SecureNotes?"
      
      // Define the action to be taken when "OK" is clicked on the alert
      let ok = {
         // Get all the exportable secure note items from the keychain
         let exportableSecureNoteItems = KeychainExport.exportableItems(keyChainItems: Self.keyChainItems, type: .note)
         
         // Add the exportable secure note items to the list of items to be exported
         Self.exportableItems += exportableSecureNoteItems
         
         // Begin the process to export general passwords
         exportGeneralPasswords()
      }
      
      // Define the action to be taken when "Cancel" is clicked on the alert
      let onCancel = { 
         // Begin the process to export general passwords
         exportGeneralPasswords()/* ⚠️️ Close app here? ⚠️️ */ 
      }
      
      // Create the alert with the specified title, message, and actions for "OK" and "Cancel"
      createAlert(title: introTitle, msg: introMSG, onOk: ok, onCancel: onCancel)
   }
   /**
    * Begin export process for "general passwords"
    */
   private static func exportGeneralPasswords() {
            // Set the title for the alert as "SecureNote"
      let introTitle = "SecureNote"
      
      // Get all the secure note items from the keychain
      let noteItems = KeychainExport.getKeychainItemsByType(items: Self.keyChainItems, type: .note)
      
      // Set the message for the alert, indicating the number of secure notes to be exported
      let introMSG = "Do you want to export \(noteItems.count) SecureNotes?"
      
      // Define the action to be taken when "OK" is clicked on the alert
      let ok = {
         // Get all the exportable secure note items from the keychain
         let exportableSecureNoteItems = KeychainExport.exportableItems(keyChainItems: Self.keyChainItems, type: .note)
         
         // Add the exportable secure note items to the list of items to be exported
         Self.exportableItems += exportableSecureNoteItems
         
         // Begin the process to export general passwords
         exportGeneralPasswords()
      }
      
      // Define the action to be taken when "Cancel" is clicked on the alert
      let onCancel = { 
         // Begin the process to export general passwords
         exportGeneralPasswords()/* ⚠️️ Close app here? ⚠️️ */ 
      }
      
      // Create the alert with the specified title, message, and actions for "OK" and "Cancel"
      createAlert(title: introTitle, msg: introMSG, onOk: ok, onCancel: onCancel)
   }
}
/**
 * Helper
 */
extension Wizard {
   typealias OKClosure = () -> Void
   static let defaultOK: OKClosure = { Swift.print("ok") }
   typealias CancelClosure = () -> Void
   static let defaultCancel: CancelClosure = { Swift.print("Cancel") }
   /**
    * create alert
    * - Fixme: ⚠️️ Make this more dynamic etc, write a template etc
    * ## Examples:
    * NSAlert.createAlert(title: "Hello", msg: "Do something", onOk: { ... }, onCancel: { ... })
    */
   internal static func createAlert(title: String, msg: String, onOk: OKClosure = defaultOK, onCancel: CancelClosure = defaultCancel) {
      with(NSAlert()) { // Initialize an NSAlert instance
         $0.messageText = title // Set the title of the alert
         $0.informativeText = msg // Set the message of the alert
         $0.alertStyle = .warning // Set the alert style to warning
         $0.addButton(withTitle: "OK") // Add an "OK" button to the alert
         $0.addButton(withTitle: "Cancel") // Add a "Cancel" button to the alert
         let res = $0.runModal() // Display the alert and store the user's response
         switch res { // Handle the user's response
         case .alertFirstButtonReturn: // If the user clicked "OK"
            onOk() // Execute the onOk closure
         case .alertSecondButtonReturn: // If the user clicked "Cancel"
            onCancel() // Execute the onCancel closure
         default: // If the user's response is not supported
            fatalError("Err not supported") // Throw a fatal error
         }
      }
   }
}
/**
 * Do you want to continue popup with 10 of 54 progress text (every 10th password, your informed about progress)
 */
//func itermediatePopup(curIdx: Int, numOfItems: Int, type: String, doContinue: (Bool) -> Void) {
//   let title = "You are at: \(curIdx) of \(numOfItems)"
//   let msg = "Do you want to continue exporting \(type)" // type is SecureNotes / GeneralPasswords etc
//   createAlert(title: title, msg: msg, onOk: { doContinue(true) }, onCancel: { doContinue(false) })
//}
