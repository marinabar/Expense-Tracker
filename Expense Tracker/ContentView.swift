//
//  ContentView.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 07/09/2024.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            NavigationStack {
                ExpenseLog()
            }
           .tabItem {
                Image(systemName: "pencil")
                Text("Add Expense")
            }.tag(0)
            NavigationStack {
                AnalysisView()
            }
            .tabItem {
                  Image(systemName: "list.bullet")
                  Text("Expenses")
            }.tag(1)
            NavigationStack {
                GraphicalAnalysisView()
            }
           .tabItem {
                  Image(systemName: "chart.bar")
                  Text("Analysis")
            }.tag(2)
            NavigationStack {
                PhotoAnalysisView()
            }
            .tabItem {
                    Label("Analyze Receipt", systemImage: "photo")
            }.tag(3)
        }
        .accentColor(Constants.appTintColor)
    }
}

#Preview() {
    ContentView()
}
