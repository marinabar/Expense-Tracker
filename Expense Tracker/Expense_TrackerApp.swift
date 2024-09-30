//
//  Expense_TrackerApp.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 07/09/2024.
//

import SwiftUI

@main
struct Expense_TrackerApp: App {    
    init() {
    RealmHelper.setupRealm()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
