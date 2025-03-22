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
                Image(systemName: "plus.app")
                Text("Add")
            }.tag(0)
            NavigationStack {
                AnalysisView()
            }
            .tabItem {
                  Image(systemName: "list.bullet")
                  Text("List")
            }.tag(1)
            NavigationStack {
                CombinedView()
            }
            .tabItem {
                    Label("Overview", systemImage: "chart.bar")
            }.tag(2)
            NavigationStack {
                MistralPhotoView()
            }
            .tabItem {
                    Label("Scan", systemImage: "photo")
            }.tag(3).labelStyle(.iconOnly)
            NavigationStack {
                ChatView()
            }
            .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.text.bubble.right")
            }.tag(4)
            
        }
        .accentColor(Constants.appTintColor)
    }
}

#Preview() {
    ContentView()
}
