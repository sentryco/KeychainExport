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
      let introTitle = "There are \(Self.keyChainItems.count) items in keychain"
      let introMSG = "Since you will have to authorize each key, we recomend pasting your admin-password to speed up the process"
      createAlert(title: introTitle, msg: introMSG, onOk: exportSecureNote)
   }
   /**
    * Begin export process for "secure note"
    */
   private static func exportSecureNote() {
      let introTitle = "SecureNote"
      let noteItems = KeychainExport.getKeychainItemsByType(items: Self.keyChainItems, type: .note)
      let introMSG = "Do you want to export \(noteItems.count) SecureNotes?"
      let ok = {
         let exportableSecureNoteItems = KeychainExport.exportableItems(keyChainItems: Self.keyChainItems, type: .note)
         Self.exportableItems += exportableSecureNoteItems
         exportGeneralPasswords()
      }
      let onCancel = { exportGeneralPasswords()/* ⚠️️ Close app here? ⚠️️ */ }
      createAlert(title: introTitle, msg: introMSG, onOk: ok, onCancel: onCancel)
   }
   /**
    * Begin export process for "general passwords"
    */
   private static func exportGeneralPasswords() {
      let introTitle = "GeneralPassword"
      let genPswItems = KeychainExport.getKeychainItemsByType(items: Self.keyChainItems, type: .password)
      let introMSG = "Do you want to export \(genPswItems.count) GeneralPasswords?"
      let onComplete = {
         KeychainExport.exportToJSON(exportableItems: Self.exportableItems)
         // - Fixme: ⚠️️ Close app here ?
      }
      let ok = {
         let exportablePasswordItems = KeychainExport.exportableItems(keyChainItems: Self.keyChainItems, type: .password)
         Self.exportableItems += exportablePasswordItems
         onComplete()
      }
      let onCancel = { onComplete() }
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
      with(NSAlert()) {
         $0.messageText = title
         $0.informativeText = msg
         $0.alertStyle = .warning
         $0.addButton(withTitle: "OK")
         $0.addButton(withTitle: "Cancel")
         let res = $0.runModal()
         switch res {
         case .alertFirstButtonReturn: // OK
            onOk()
         case .alertSecondButtonReturn: // Cancel
            onCancel()
         default:
            fatalError("Err not supported")
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
