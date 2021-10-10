import Foundation

public enum ExportItemType: String { case password, note }
/**
 * - Fixme: ⚠️️ Maybe add AccountCommon lib for access to account-item?
 * - Fixme: ⚠️️ Maybe make this struct?
 */
public typealias ExportItem = (type: ExportItemType, title: String, password: String, note: String)
