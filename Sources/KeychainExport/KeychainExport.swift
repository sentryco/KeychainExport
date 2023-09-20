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
            // Declare a variable to hold the result of the keychain query
      var copyResult: CFTypeRef?
      
      // Define the query to fetch all generic passwords from the keychain
      let query = [kSecClass: kSecClassGenericPassword, /*kSecReturnData: kCFBooleanTrue!,*/kSecReturnAttributes: kCFBooleanTrue!, kSecReturnRef: kCFBooleanTrue!, kSecMatchLimit: kSecMatchLimitAll] as NSDictionary
      
      // Execute the query
      let err = SecItemCopyMatching(query, &copyResult)
      
      // Check if the query was successful
      if err == errSecSuccess {
         // Cast the result to an array of dictionaries
         let keys = copyResult! as!  [[String: Any]]
         
         // Initialize an empty array to hold the results
         var results: [KeyChainItem] = []
         
         // Print the count of keys
         Swift.print("keys.count:  \(keys.count)")
         
         // Iterate over each key
         keys.forEach {
            // Print the current key
            Swift.print("$0:  \($0)")
            
            // Extract the description, account, label, and secure item from the key
            let desc: String? = $0[kSecAttrDescription as String] as? String
            let acct: String? = $0["acct"] as? String // normal password has this, note doesnt have this
            let labl: String? = desc == "secure note" ? $0["labl"] as? String : nil // note has this, normal password doesnt have this
            let secItem: SecKeychainItem = $0["v_Ref"] as! SecKeychainItem // all items has this
            
            // Create a KeyChainItem from the extracted values
            let result: KeyChainItem = (acct, labl, secItem)
            
            // Append the result to the results array
            results.append(result)
         }
         
         // Return the results
         return results
      } else {
         // If the query was not successful, print the error and return an empty array
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
            // Filter the keychain items by the specified type
      let filteredItems = getKeychainItemsByType(items: keyChainItems, type: type)
      
      // Get the count of the filtered items
      let end: Int = filteredItems.count
      
      // Create a subset of the filtered items from the start to the end
      let subset: [KeyChainItem] = Array(filteredItems[0..<end])
      
      // Map the subset of keychain items to exportable items
      let exportItems: [ExportItem] = subset.compactMap {
         // If the keychain item has an account, it's a password
         if let acct = $0.acct {
            // Try to get the password content for the account
            guard let content = generalPassword(account: acct) else { 
               Swift.print("unable to get pass content"); 
               return nil 
            }
            // Return a password export item
            return (type: .password, title: acct, password: content, note: "")
         } 
         // If the keychain item has a label, it's a note
         else if let labl = $0.labl {
            // Try to get the note content for the label
            guard let content = secureNoteContent(lable: labl) else { 
               Swift.print("unable to get note content"); 
               return nil 
            }
            // Return a note export item
            return (type: .note, title: labl, password: "", note: content)
         } 
         // If the keychain item is neither a password nor a note, it's not supported
         else {
            Swift.print("⚠️️ type not supported")
            return nil
         }
      }
      
      // Return the array of exportable items
      return exportItems
   }
   /**
    * exportToJSON
    */
   public static func exportToJSON(exportableItems: [ExportItem]) {
            // Check if there are any items to export
      guard !exportableItems.isEmpty else { Swift.print("Nothing to export, aborting"); return }
      
      // Map each exportable item to a dictionary
      let dictArr: [[String: Any]] = exportableItems.map {
         ["type": $0.type.rawValue, "title": $0.title, "password": $0.password, "note": $0.note]
      }
      
      // Convert the array of dictionaries to a JSON string
      guard let jsonStr: String = JSONParser.str(dictArr: dictArr) else { Swift.print("⚠️️ err Dict -> json-str"); return }
      
      // Print the count of exportable items
      Swift.print("exportItems.count:  \(exportableItems.count)")
      
      // Define a URL for a temporary file
      let url: URL = {
         var url = URL(fileURLWithPath: NSTemporaryDirectory())
         url.appendPathComponent("temp.txt")
         return url
      }()
      
      // Write the JSON string to the temporary file
      FileModifier.write(url.path, content: jsonStr)
      
      // Prompt the user to save the file
      WizardHelper.promptSaveFile(fromURL: url, fileName: "keychains.json")
      
      // Clear the contents of the temporary folder
      FileManager.clearTempFolderContent()
   }
   /**
    * Items by type
    * - Note: we return only items which are of type: note or general-password
    */
   public static func getKeychainItemsByType(items: [KeyChainItem], type: ExportItemType) -> [KeyChainItem] {
      // Filter the items array
      let filteredItems: [KeyChainItem] = items.filter {
         // Check if the item type is 'note' and the label is not nil
         let isNote: Bool = type == .note && $0.labl != nil
         // Check if the item type is 'password' and the account is not nil
         let isGeneralPassword: Bool = type == .password && $0.acct != nil
         // Return true if the item is either a note or a password
         return isNote || isGeneralPassword
      }
      // Return the filtered items
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
            // Declare a variable to hold the result of the keychain query
      var copyResult: CFTypeRef?
      
      // Define the query to fetch a secure note from the keychain by its label
      let query: NSDictionary = [
         kSecAttrLabel: lable, // The label of the secure note
         kSecClass: kSecClassGenericPassword, // The class of the keychain item
         kSecReturnData: kCFBooleanTrue!, // Request the data of the keychain item
         kSecMatchLimit: kSecMatchLimitOne  // Limit the query to one item
      ]
      
      // Execute the query
      let err = SecItemCopyMatching(query, &copyResult)
      
      // Check if the query was successful
      if err == errSecSuccess {
         // Cast the result to a Data object
         guard let data: Data = copyResult as? Data else { Swift.print("err getting data"); return nil }
         
         // Define a format for the property list serialization
         var format: PropertyListSerialization.PropertyListFormat = .xml // pull in the description that's really a functional plist <sigh>
         
         // Try to deserialize the data into a property list object
         guard let propertyListObject: [String: Any] = try? PropertyListSerialization.propertyList(from: data, options: [], format: &format) as? [String: Any] else { Swift.print("err cant make dict of xml"); return nil }
         
         // Extract the note content from the property list object
         guard let noteContent: String = propertyListObject["NOTE"] as? String else { return nil }
         
         // Print the note content
         Swift.print("noteContent:  \(noteContent)")
         
         // Return the note content
         return noteContent
      } else {
         // If the query was not successful, print the error and return nil
         Swift.print("Err finding match"); return nil 
      }
   }
   /**
    * Returns readable content from general password
    */
   private static func generalPassword(account: String) -> String? {
      // Declare a variable to hold the result of the keychain query
      var copyResult: CFTypeRef?
      
      // Define the query to fetch a generic password from the keychain by its account
      let query = [
         kSecAttrAccount: account, // The account of the generic password
         kSecClass: kSecClassGenericPassword, // The class of the keychain item
         kSecReturnData: kCFBooleanTrue!, // Request the data of the keychain item, not to be confused with: kSecReturnAttributes
         kSecMatchLimit: kSecMatchLimitOne  // Limit the query to one item
      ] as NSDictionary
      
      // Execute the query
      let err = SecItemCopyMatching(query, &copyResult)
      
      // Check if the query was successful
      if err == errSecSuccess {
         // Cast the result to a Data object
         guard let data: Data = copyResult as? Data else { Swift.print("err getting data"); return nil }
         
         // Convert the data to a string using UTF-8 encoding
         let content: String? = .init(data: data, encoding: .utf8)
         
         // Uncomment the following line to print the content
         // Swift.print("content:  \(String(describing: content))")
         
         // Return the content
         return content
      } else {
         // If the query was not successful, print the error and return nil
         Swift.print("Err finding match"); return nil 
      }
   }
}
