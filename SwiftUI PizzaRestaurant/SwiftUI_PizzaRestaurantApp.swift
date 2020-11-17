//
//  SwiftUI_PizzaRestaurantApp.swift
//  SwiftUI PizzaRestaurant
//
//  Created by elhajjaji on 17/11/2020.
//

import SwiftUI

@main
struct SwiftUI_PizzaRestaurantApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
