import Cocoa
import With

class AppDelegate: NSObject, NSApplicationDelegate {
   /**
    * - Fixme: ⚠️️ Add Do you want to continue popup with 10 of 54 progress text (every 10th password, your informed about progress)
    */
   func applicationDidFinishLaunching(_ aNotification: Notification) {
      Wizard.beginExport()
   }
   func applicationWillTerminate(_ aNotification: Notification) {}
}
