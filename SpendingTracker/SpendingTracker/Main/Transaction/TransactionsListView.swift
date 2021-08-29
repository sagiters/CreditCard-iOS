//
//  TransactionsListView.swift
//  SpendingTracker
//
//  Created by Lien-Tai Kuo on 2021/8/28.
//

import SwiftUI

struct TransactionsListView: View {

    let card: Card

    init(card: Card) {
        self.card = card

        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [
            .init(key: "timestamp", ascending: false)
        ], predicate: .init(format: "card == %@", self.card))

    }

    @State private var shouldShowAddTransactionForm = false
    @State private var shouldShowFilterSheet = false

    @Environment(\.managedObjectContext) private var viewContext

    var fetchRequest: FetchRequest<CardTransaction>

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \CardTransaction.timestamp, ascending: false)],
//        animation: .default)
//    private var transactions: FetchedResults<CardTransaction>

    var body: some View {
        VStack {

            if fetchRequest.wrappedValue.isEmpty {
                Text("Get started by adding your first transaction")

                Button(action: {
                    shouldShowAddTransactionForm.toggle()
                }, label: {
                    Text("+ Transaction")
                        .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
                        .background(Color(.label))
                        .foregroundColor(Color(.systemBackground))
                        .font(.headline)
                        .cornerRadius(5)
                })

            } else {

                HStack {
                    Spacer()
                    addTransactionButton
                    filterButton
                        .sheet(isPresented: $shouldShowFilterSheet, onDismiss: nil, content: {
                            FilterSheet(selectedCategories: self.selectedCategories, didSaveFilters: { categories in
                                self.selectedCategories = categories
                            })
                        })
                }
                .padding(.horizontal)

                ForEach(filterTransactions(selectedCategories: self.selectedCategories)) { transaction in
                    CardTransactionView(transaction: transaction)

                }


            }
        }
        .fullScreenCover(isPresented: $shouldShowAddTransactionForm, onDismiss: nil, content: {
            AddTransactionForm(card: self.card)
        })
    }

    @State var selectedCategories = Set<TransactionCategory>()

    private func filterTransactions(selectedCategories: Set<TransactionCategory>) -> [CardTransaction] {

        if selectedCategories.isEmpty {
            return Array(fetchRequest.wrappedValue)
        }

        // fetchRequest.wrappedVale: n transactions
        // selectedCategories: m categories
        // n x m
        // fine if your n amd m values are small

        return fetchRequest.wrappedValue.filter { transaction in

            var shouldKeep = false

            if let categories = transaction.categories as? Set<TransactionCategory> {
                categories.forEach({ category in
                    if selectedCategories.contains(category) {
                        shouldKeep = true
                    }
                })
            }

            return shouldKeep
        }
    }

    private var filterButton: some View {
        Button(action: {
            shouldShowFilterSheet.toggle()
        }, label: {
            HStack {
                Image(systemName: "line.horizontal.3.decrease.circle")
                Text("+ Filter")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(Color(.systemBackground))
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.label))
            .cornerRadius(5)
        })
    }

    private var addTransactionButton: some View {
        Button(action: {
            shouldShowAddTransactionForm.toggle()
        }, label: {
            Text("+ Transaction")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.systemBackground))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.label))
                .cornerRadius(5)
        })
    }

}

struct FilterSheet: View {

    @State var selectedCategories: Set<TransactionCategory>
    let didSaveFilters: (Set<TransactionCategory>) -> ()

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories: FetchedResults<TransactionCategory>

//    @State var selectedCategories = Set<TransactionCategory>()

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                ForEach(categories) { category in
                    Button(action: {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }, label: {
                        HStack (spacing: 12){
                            if let data = category.colorData,
                               let uiColor = UIColor.color(data: data) {
                                let color = Color(uiColor)

                                Spacer()
                                    .frame(width: 30, height: 10)
                                    .background(color)
                            }
                            Text(category.name ?? "")
                                .foregroundColor(.black)
                            Spacer()

                            if selectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                            }
                        }
                    })

                }
            }
            .navigationTitle("Select filters")
            .navigationBarItems(trailing: saveButton)
        }
    }

    private var saveButton: some View {
        Button(action: {
            didSaveFilters(selectedCategories)
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Save")
        })
    }
}

struct CardTransactionView: View {

    let transaction: CardTransaction

    @State var shouldPresentActionSheet = false
    @Environment(\.colorScheme) var colorScheme

    private func handleDelete() {
        withAnimation {
            do {

                let context = PersistenceController.shared.container.viewContext

                context.delete(transaction)

                try context.save()
            } catch {
                print("Failed to delete transaction: ", error)
            }
        }
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.name ?? "")
                        .font(.headline)
                    if let date = transaction.timestamp {
                        Text(dateFormatter.string(from: date))
                    }
                }
                Spacer()

                VStack(alignment: .trailing) {
                    Button(action: {
                        shouldPresentActionSheet.toggle()
                    }, label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24))
                    })
                    .padding(EdgeInsets(top: 6, leading: 8, bottom: 4, trailing: 0))
                    .actionSheet(isPresented: $shouldPresentActionSheet, content: {
                        .init(title: Text(transaction.name ?? ""), message: nil, buttons: [
                            .destructive(Text("Delete"), action: handleDelete),
                            .cancel()
                        ])
                    })

                    Text(String(String(format: "$%.2f", transaction.amount)))


                }
            }

            if let categories = transaction.categories as? Set<TransactionCategory> {
//                let array = Array(categories)

                let sortedByTimestampCategories = Array(categories).sorted(by: { $0.timestamp?.compare($1.timestamp ?? Date()) == .orderedDescending })
                
                HStack {
                    ForEach(sortedByTimestampCategories) { category in
                        HStack {
                            if let data = category.colorData,
                               let uiColor = UIColor.color(data: data) {
                                let color = Color(uiColor)

                                Text(category.name ?? "")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                    .background(color)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)

                            }

                        }
                    }

                    Spacer()
                }

            }



            if let photoData = transaction.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        }
        .foregroundColor(Color(.label))
        .padding()
//        .background(colorScheme == .dark ? Color.gray : .white)
        .background(Color.cardTransactionBackground)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

import CoreData
struct TransactionsListView_Previews: PreviewProvider {

    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return try? context.fetch(request).first
    }()

    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        NavigationView {
            ScrollView {
                if let card = firstCard {
                    TransactionsListView(card: card)
                }

            }
        }
        .colorScheme(.light)
        .environment(\.managedObjectContext, context)
    }
}
