//
//  ContentView.swift
//  Ptc
//
//  Created by CHRISTOPHE LEHOUSSINE on 04/01/2023.
//

import SwiftUI

struct ContentView: View {
    let notificationManager: NotificationManager
    var body: some View {
        NavigationView{
            Home(notificationManager: notificationManager)
                .navigationBarTitle("Coloc Manager")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
