//
//  test_ollama_qwen2_5_coder_7bApp.swift
//  test-ollama-qwen2.5-coder-7b
//
//  Created by Olivier HO-A-CHUCK on 17/02/2026.
//

import SwiftUI
import CoreData

@main
struct test_ollama_qwen2_5_coder_7bApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
