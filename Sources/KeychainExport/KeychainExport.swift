import Cocoa
import JSONSugar
import FileSugar
import WizardHelper

public final class KeychainExport {}
/**
 * - Fixme: ⚠️️ Refactor this class by splitting it up and writing documentation
 */
extension KeychainExport {
   public typealias KeyChainItem = (acct: String?, labl: String?, secItem: SecKeychainItem)
   /**
    * Finds all keychain passwords / secure notes / certificates etc
    * - Fixme: ⚠️️ It could be that we could avoid asking user for repated passwords if we look in to: SecKeychainSetUserInteractionAllowed and SecTrustedApplicationCreateFromPath
    * - Fixme: ⚠️️ Split this method up
    */
   public static func getKeyChainItems() -> [KeyChainItem] {
      var copyResult: CFTypeRef?
      let query = [kSecClass: kSecClassGenericPassword, /*kSecReturnData: kCFBooleanTrue!,*/kSecReturnAttributes: kCFBooleanTrue!, kSecReturnRef: kCFBooleanTrue!, kSecMatchLimit: kSecMatchLimitAll] as NSDictionary
      let err = SecItemCopyMatching(query, &copyResult)
      if err == errSecSuccess {
         let keys = copyResult! as!  [[String: Any]]
         var results: [KeyChainItem] = []
         Swift.print("keys.count:  \(keys.count)")
         keys.forEach {
            Swift.print("$0:  \($0)")
            let desc: String? = $0[kSecAttrDescription as String] as? String
            let acct: String? = $0["acct"] as? String // normal password has this, note doesnt have this
            let labl: String? = desc == "secure note" ? $0["labl"] as? String : nil // note has this, normal password doesnt have this
            let secItem: SecKeychainItem = $0["v_Ref"] as! SecKeychainItem // all items has this
            let result: KeyChainItem = (acct, labl, secItem)
            results.append(result)
         }
         return results
      } else {
         // - Fixme: ⚠️️ add readable error from Key.swift
         Swift.print("Err: \(err)")
         return []
      }
   }
   /**
    * Get generalPasswords or secureNotes
    * - Note: we have to iterate because each request asks user for master-password
    * - Fixme: ⚠️️ Split this method up
    * - Fixme: ⚠️️ Store key as well, export to json
    * - Fixme: ⚠️️ Write method that returns all regular password identifiers and all secure not identifiers
    * - Fixme: ⚠️️ Write method that grabs content of regular passwords
    * - Note: JSON format should be: [{"type":"Apple","title":"jasmine@apple.com","password":"abc123","note":""}]
    */
   public static func exportableItems(keyChainItems: [KeyChainItem], /*offset: Int = 0, limit: Int = 10,*/ type: ExportItemType = .note) -> [ExportItem] {
      let filteredItems = getKeychainItemsByType(items: keyChainItems, type: type)
      let end: Int = filteredItems.count// <= limit ? filteredItems.count :limit
      let subset: [KeyChainItem] = Array(filteredItems[0..<end])
      let exportItems: [ExportItem] = subset.compactMap {
         if let acct = $0.acct { // password
            // Swift.print("acct:  \(acct)")
            guard let content = generalPassword(account: acct) else { Swift.print("unable to get pass content"); return nil }
            return (type: .password, title: acct, password: content, note: "")
         } else if let labl = $0.labl { // note
            // Swift.print("labl:  \(labl)")
            guard let content = secureNoteContent(lable: labl) else { Swift.print("unable to get note content"); return nil }
            return (type: .note, title: labl, password: "", note: content)
         } else {
            Swift.print("⚠️️ type not supported")
            return nil
         }
      }
      return exportItems
   }
   /**
    * exportToJSON
    */
   public static func exportToJSON(exportableItems: [ExportItem]) {
      guard !exportableItems.isEmpty else { Swift.print("Nothing to export, aborting"); return }
      // exportItems.forEach { Swift.print("$0.title:  \($0.title)") }
      let dictArr: [[String: Any]] = exportableItems.map {
         ["type": $0.type.rawValue, "title": $0.title, "password": $0.password, "note": $0.note]
      }
      guard let jsonStr: String = JSONParser.str(dictArr: dictArr) else { Swift.print("⚠️️ err Dict -> json-str"); return }
      Swift.print("exportItems.count:  \(exportableItems.count)")
      let url: URL = {
         var url = URL(fileURLWithPath: NSTemporaryDirectory())
         url.appendPathComponent("temp.txt")
         return url
      }()
      FileModifier.write(url.path, content: jsonStr)
      WizardHelper.promptSaveFile(fromURL: url, fileName: "keychains.json") // Prompt user to save
      FileManager.clearTempFolderContent() // Remove temp files after user has saved the file else where
   }
   /**
    * Items by type
    * - Note: we return only items which are of type: note or general-password
    */
   public static func getKeychainItemsByType(items: [KeyChainItem], type: ExportItemType) -> [KeyChainItem] {
      let filteredItems: [KeyChainItem] = items.filter {
         let isNote: Bool = type == .note && $0.labl != nil
         let isGeneralPassword: Bool = type == .password && $0.acct != nil
         return isNote || isGeneralPassword
      }
      return filteredItems
   }
}
/**
 * Private static helper methods
 */
extension KeychainExport {
   /**
    * Returns readable content from secure note
    * - Fixme: ⚠️️ Find an id variable that is universal for all types of keys, name, id, type, lable, something
    * - Fixme: ⚠️️ Move the query to a static var
    */
   private static func secureNoteContent(lable: String) -> String? { // lable is name of secret, but probably use the type attr, as it seems unique
      var copyResult: CFTypeRef?
      let query: NSDictionary = [
         kSecAttrLabel: lable,
         kSecClass: kSecClassGenericPassword,
         kSecReturnData: kCFBooleanTrue!, // not to be confused with: kSecReturnAttributes
         kSecMatchLimit: kSecMatchLimitOne  // find only one item
      ]
      let err = SecItemCopyMatching(query, &copyResult)
      if err == errSecSuccess {
         guard let data: Data = copyResult as? Data else { Swift.print("err getting data"); return nil }
         var format: PropertyListSerialization.PropertyListFormat = .xml // pull in the description that's really a functional plist <sigh>
         guard let propertyListObject: [String: Any] = try? PropertyListSerialization.propertyList(from: data, options: [], format: &format) as? [String: Any] else { Swift.print("err cant make dict of xml"); return nil }
         guard let noteContent: String = propertyListObject["NOTE"] as? String else { return nil }
         Swift.print("noteContent:  \(noteContent)")
         return noteContent
      } else { Swift.print("Err finding match"); return nil }
   }
   /**
    * Returns readable content from general password
    */
   private static func generalPassword(account: String) -> String? {
      var copyResult: CFTypeRef?
      let query = [
         kSecAttrAccount: account,
         kSecClass: kSecClassGenericPassword,
         kSecReturnData: kCFBooleanTrue!, // not to be confused with: kSecReturnAttributes
         kSecMatchLimit: kSecMatchLimitOne  // find only one item
      ] as NSDictionary
      let err = SecItemCopyMatching(query, &copyResult)
      if err == errSecSuccess {
         guard let data: Data = copyResult as? Data else { Swift.print("err getting data"); return nil }
         let content: String? = .init(data: data, encoding: .utf8)
         // Swift.print("content:  \(String(describing: content))")
         return content
      } else { Swift.print("Err finding match"); return nil }
   }
}
