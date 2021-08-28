//
//  MainView.swift
//  SpendingTracker
//
//  Created by Lien-Tai Kuo on 2021/8/28.
//

import SwiftUI

struct MainView: View {

    @State private var shouldPresentAddCardForm = false
    @State private var shouldShowAddTransactionForm = false

    // amount of credit card variable
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>

    var body: some View {
        NavigationView {
            ScrollView {

                if !cards.isEmpty {
                    TabView {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .padding(.bottom, 50)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .id(UUID())
                    .frame(height: 280)
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))

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
                    .fullScreenCover(isPresented: $shouldShowAddTransactionForm, onDismiss: nil, content: {
                        AddTransactionForm()
                    })

                } else {

                    emptyPromptyMessage
                }

                Spacer()
                    .fullScreenCover(isPresented: $shouldPresentAddCardForm, onDismiss: nil, content: {
                        AddCardForm()
                    })

            }
            .navigationTitle("Credit Cards")
            .navigationBarItems(leading: HStack {
                addItemButton
                deleteAllButton
            },
                                trailing: addCardButton)
        }
    }

    private var emptyPromptyMessage: some View {
        VStack {
            Text("You currently have no cards in the system.")
                .padding(.horizontal, 48)
                .padding(.vertical)
                .multilineTextAlignment(.center)
            Button(action: {
                shouldPresentAddCardForm.toggle()
            }, label: {
                Text("+ Add Your First Card")
                    .foregroundColor(Color(.systemBackground))
            })
            .padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
            .background(Color(.label))
            .cornerRadius(5)
        }
        .font(.system(size: 22, weight: .semibold))
    }

    private var deleteAllButton: some View {
        Button(action: {
            cards.forEach { card in
                viewContext.delete(card)
            }

            do {
                try viewContext.save()
            } catch {

            }
        }, label: {
            Text("Delete All")
        })
    }

    var addItemButton: some View {
        Button(action: {
            withAnimation {
                let viewContext = PersistenceController.shared.container.viewContext

                let card = Card(context: viewContext)
                card.timestamp = Date()

                do {
                    try viewContext.save()
                } catch {
//                    let nsError = error as NSError
//                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }, label: {
            Text("Add Item")
        })
    }

    struct CreditCardView: View {

        let card: Card

        @State private var shouldShowActionSheet = false
        @State private var shouldShowEditForm = false

        @State var refreshId = UUID()

        private func handleDelete() {
            let viewContext = PersistenceController.shared.container.viewContext

            viewContext.delete(card)

            do {
                try viewContext.save()
            } catch {
                // error handling
            }
        }



        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(card.name ?? "")
                        .font(.system(size: 24, weight: .semibold))
                    Spacer()
                    Button(action: {
                        shouldShowActionSheet.toggle()
                    }, label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 28, weight: .bold))
                    })
                    .actionSheet(isPresented: $shouldShowActionSheet, content: {
                        .init(title: Text(self.card.name ?? ""), message: Text("Options"), buttons: [
                            .default(Text("Edit"), action: {
                                shouldShowEditForm.toggle()
                            }),
                            .destructive(Text("Delete Card"), action: handleDelete),
                            .cancel()
                        ])
                    })

                }

                HStack {
                    Image("visa")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                        .clipped()
                    Spacer()
                    Text("Balance: $5,000")
                        .font(.system(size: 18, weight: .semibold))
                }

                Text(card.number ?? "")

                HStack {
                    Text("Credit Limit: $\(card.limit)")
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Valid Thru")
                        Text("\(String(format: "%02d", card.expMonth))/\(String(card.expYear % 2000))")
                    }
                }

                HStack { Spacer() }
            }
            .foregroundColor(.white)
            .padding()
            .background(

                VStack {

                    if let colorData = card.color,
                       let uiColor = UIColor.color(data: colorData),
                       let actualColor = Color(uiColor) {

                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    actualColor.opacity(0.6),
                                    actualColor
                                ]),
                            startPoint: .center,
                            endPoint: .bottom)
                    } else {
                        Color.purple
                    }


                }

            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(8)
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
            .fullScreenCover(isPresented: $shouldShowEditForm, onDismiss: nil, content: {
                AddCardForm(card: card)
            })
        }
    }

    var addCardButton: some View {
        Button(action: {
            // trigger action
            shouldPresentAddCardForm.toggle()
        }, label: {
            Text("+ Card")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .background(Color.black)
                .cornerRadius(5)
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}
