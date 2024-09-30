//
//  RealmHelper.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 07/09/2024.
//

import Foundation
import RealmSwift

class RealmHelper {
    static func setupRealm() {
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
    }
}
