//
//  DynamicFilteredView.swift
//  Ptc
//
//  Created by CHRISTOPHE LEHOUSSINE on 04/01/2023.
//
//["Ce jour","A venir","Tâches faites","Non faites"]
import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View,T>: View where T: NSManagedObject {
    @FetchRequest var request: FetchedResults<T>
    let content: (T)->Content
    
    init(currentTab: String,@ViewBuilder content: @escaping (T)->Content){
    
        let calendar = Calendar.current
        var predicate: NSPredicate!
        if currentTab == "Ce jour"{
            let today = calendar.startOfDay(for: Date())
            let tommorow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            // Filter Key
            let filterKey = "deadline"
            
            // This will fetch task between today and tommorow which is 24 HRS
            // 0-false, 1-true
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today,tommorow,0])
        }else if currentTab == "A venir"{
            let today = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            let tommorow = Date.distantFuture
            
   
            let filterKey = "deadline"
       
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today,tommorow,0])
        }else if currentTab == "Non faites"{
            let today = calendar.startOfDay(for: Date())
            let past = Date.distantPast
            
            // Filter Key
            let filterKey = "deadline"
            
            // This will fetch task between today and tommorow which is 24 HRS
            // 0-false, 1-true
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [past,today,0])
        }
        else{
            // 0-false, 1-true
            predicate = NSPredicate(format: "isCompleted == %i", argumentArray: [1])
        }
        // Intializing Request With NSPredicate
        // Adding Sort
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [.init(keyPath: \Task.deadline, ascending: false)], predicate: predicate)
        self.content = content
    }
    
    var body: some View {
        
        Group{
            if request.isEmpty{
                Text("Tu n'as pas de tâche ! Enjoy")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(y: 100)
            }
            else{
                
                ForEach(request,id: \.objectID){object in
                    self.content(object)
                }
            }
        }
    }
    
}
