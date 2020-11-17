//
//  ContentView.swift
//  SwiftUI PizzaRestaurant
//
//  Created by elhajjaji on 17/11/2020.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: Order.entity(), sortDescriptors: [], predicate: NSPredicate(format: "status != %@", Status.completed.rawValue))

    var orders: FetchedResults<Order>
    
    @State var showOrderSheet = false

    var body: some View {
       
        NavigationView {
            List {
                ForEach(orders) { order in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(order.pizzaType) - \(order.numberOfSlices) slices")
                                .font(.headline)
                            Text("Table \(order.tableNumber)")
                                .font(.subheadline)
                        }
                        Spacer()
                        Button(action: {
                            updateOrder(order: order)
                        }) {
                            Text(order.orderStatus == .pending ? "Prepare" : "Complete")
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(height: 50)
                }
                .onDelete { indexSet in
                            for index in indexSet {
                                viewContext.delete(orders[index])
                            }
                            do {
                                try viewContext.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
            }
                .listStyle(PlainListStyle())
                .navigationTitle("My Orders")
                .navigationBarItems(trailing: Button(action: {
                    print("Open order sheet")
                }, label: {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                }))
            
           
                .navigationTitle("My Orders")
            .navigationBarItems(trailing: Button(action: {
                showOrderSheet = true
            }, label: {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
            }))
            .sheet(isPresented: $showOrderSheet) {
                OrderSheet()
            }

        }
        
        
        }
    
    func updateOrder(order: Order) {
            let newStatus = order.orderStatus == .pending ? Status.preparing : .completed
            viewContext.performAndWait {
                order.orderStatus = newStatus
                try? viewContext.save()
            }
        }
    }

   
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}






struct OrderSheet: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment (\.presentationMode) var presentationMode


    let pizzaTypes = ["Pizza Margherita", "Greek Pizza", "Pizza Supreme", "Pizza California", "New York Pizza"]
    
    @State var selectedPizzaIndex = 1
    @State var numberOfSlices = 1
    @State var tableNumber = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pizza Details")) {
                    Picker(selection: $selectedPizzaIndex, label: Text("Pizza Type")) {
                        ForEach(0 ..< pizzaTypes.count) {
                                Text(self.pizzaTypes[$0]).tag($0)
                        }
                    }
                    
                    Stepper("\(numberOfSlices) Slices", value: $numberOfSlices, in: 1...12)
                }
                
                Section(header: Text("Table")) {
                    TextField("Table Number", text: $tableNumber)
                        .keyboardType(.numberPad)
                    
                }
                
                Button(action: {
                    guard self.tableNumber != "" else {return}
                       let newOrder = Order(context: viewContext)
                       newOrder.pizzaType = self.pizzaTypes[self.selectedPizzaIndex]
                       newOrder.orderStatus = .pending
                       newOrder.tableNumber = self.tableNumber
                       newOrder.numberOfSlices = Int16(self.numberOfSlices)
                       newOrder.id = UUID()
                    do {
                        try viewContext.save()
                        print("Order saved.")
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }) {
                    Text("Add Order")
                }
            }
                .navigationTitle("Add Order")
        }
    }
}

