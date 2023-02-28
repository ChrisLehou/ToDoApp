//
//  Home.swift
//  Ptc
//
//  Created by CHRISTOPHE LEHOUSSINE on 04/01/2023.
//

import SwiftUI

struct Home: View {
    @Environment(\.managedObjectContext) private var viewContext
    let notificationManager: NotificationManager
    @StateObject var taskModel: TaskViewModel = .init()
    @Namespace var animation
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Task.deadline, ascending: false)], predicate: nil, animation: .easeInOut) var tasks: FetchedResults<Task>
    
    @Environment(\.self) var env
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack{
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Bonjour !")
                        .font(.title2.bold())
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                .padding(.vertical)
                
                CustomSegmentedBar()
                    .padding(.top,5)
                
                TaskView()
            }
            .padding()
        }
        .overlay(alignment: .bottom) {
            
            Button {
                taskModel.openEditTask.toggle()
            } label: {
                Label {
                    Text("Ajoute une tache")
                        .font(.callout)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "plus.app.fill")
                }
                .foregroundColor(.white)
                .padding(.vertical,12)
                .padding(.horizontal)
                .background(.black,in: Capsule())
            }
            
            .padding(.top,10)
            .frame(maxWidth: .infinity)
            .background{
                LinearGradient(colors: [
                    .white.opacity(0.05),
                    .white.opacity(0.4),
                    .white.opacity(0.7),
                    .white
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: $taskModel.openEditTask) {
            taskModel.resetTaskData()
        } content: {
            AddNewTask()
                .environmentObject(taskModel)
        }
    }
    
    @ViewBuilder
    func TaskView()->some View{
        LazyVStack(spacing: 20){
            
            DynamicFilteredView(currentTab: taskModel.currentTab) { (task: Task) in
                TaskRowView(task: task)
                
            }
        }
        
        .padding(.top,20)
    }
    
    @ViewBuilder
    func TaskRowView(task: Task)->some View{
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                Text(task.type ?? "")
                    .font(.callout)
                    .padding(.vertical,5)
                    .padding(.horizontal)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.3))
                    }
                
                Spacer()
                ShareLink(item: task.title!) {
                    Image(systemName: "square.and.arrow.up")
                }
                
                if !task.isCompleted && taskModel.currentTab != "Failed"{
                    Button {
                        taskModel.editTask = task
                        taskModel.openEditTask = true
                        taskModel.setupTask()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.black)
                    }
                }
            }
            
            Text(task.title ?? "")
                .font(.title2.bold())
                .foregroundColor(.black)
                .padding(.vertical,10)
                .onAppear {
                    print("\(task.deadline)")
                    scheduleNotification(date: task.deadline!, itemContent: "\(task.title!) le \(task.deadline!)")
                }
            
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Label {
                        Text((task.deadline ?? Date()).formatted(date: .long, time: .omitted))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    
                    Label {
                        Text((task.deadline ?? Date()).formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(.caption)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                
                if !task.isCompleted && taskModel.currentTab != "Failed"{
                    Button {
                        task.isCompleted.toggle()
                        try? env.managedObjectContext.save()
                    } label: {
                        Circle()
                            .strokeBorder(.black,lineWidth: 1.5)
                            .frame(width: 25, height: 25)
                            .contentShape(Circle())
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background{
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(task.color ?? "Yellow"))
            
        }
    }
    
    @ViewBuilder
    func CustomSegmentedBar()->some View{
        
        let tabs = ["Ce jour","A venir","Tâches faites","Non faites"]
        HStack(spacing: 0){
            ForEach(tabs,id: \.self){tab in
                Text(tab)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .scaleEffect(0.9)
                    .foregroundColor(taskModel.currentTab == tab ? .white : .black)
                    .padding(.vertical,6)
                    .frame(maxWidth: .infinity)
                    .background{
                        if taskModel.currentTab == tab{
                            Capsule()
                                .fill(.black)
                                .matchedGeometryEffect(id: "TAB", in: animation)
                        }
                    }
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation{taskModel.currentTab = tab}
                    }
            }
        }
    }
    private func scheduleNotification(date: Date, itemContent: String) {
        let notificationId = UUID()
        let content = UNMutableNotificationContent()
        content.body = "New notification \(itemContent) "
        content.sound = UNNotificationSound.default
        content.userInfo = [
            "notificationId": "\(notificationId)" // additional info to parse if need
        ]
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: NotificationHelper.getTriggerDate(triggerDate: date)!,
            repeats: false
        )
        
        notificationManager.scheduleNotification(
            id: "\(notificationId)",
            content: content,
            trigger: trigger)
    }
}



//struct Home_Previews: PreviewProvider {
//    static var previews: some View {
//        Home(notificationManager: <#NotificationManager#>).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
