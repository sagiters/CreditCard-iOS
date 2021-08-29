//
//  MainPadDeviceView().swift
//  SpendingTracker
//
//  Created by Lien-Tai Kuo on 2021/8/29.
//

import SwiftUI

struct MainPadDeviceView: View {

    @State var shouldShowAddCardForm = false

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>

    var body: some View {
        NavigationView {
            ScrollView {

                ScrollView(.horizontal) {
                    HStack {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .frame(width: 350)
                        }
                    }
                }

                TransactionGrid()
            }
            .navigationTitle("Money Tracker")
            .navigationBarItems(trailing: addCardButton)
            .sheet(isPresented: $shouldShowAddCardForm, onDismiss: nil, content: {
                AddCardForm(card: nil, didAddCard: nil)
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var addCardButton: some View {
        Button(action: {
            shouldShowAddCardForm.toggle()
        }, label: {
            Text("+ Card")
        })
    }
}

struct TransactionGrid: View {
    var body: some View {
        VStack {

            HStack {
                Text("Transactions")
                Spacer()

                Button(action: {

                }, label: {
                    Text("+ Transaction")
                })
            }

            let columns: [GridItem] = [
                .init(.fixed(100), spacing: 16, alignment: .leading),
                .init(.fixed(200), spacing: 16, alignment: .leading),
                .init(.adaptive(minimum: 300, maximum: 800), spacing: 16),
                .init(.flexible(minimum: 100, maximum: 450), spacing: 16, alignment: .trailing),
            ]

            LazyVGrid(columns: columns, content: {
                HStack {
                    Text("Date")
                    Image(systemName: "arrow.up.arrow.down")
                }

                Text("Photo / Receipt")

                HStack {
                    Text("Name")
                    Image(systemName: "arrow.up.arrow.down")
                    Spacer()
                }
//                .background(Color.red)

                HStack {
                    Text("Amount")
                    Image(systemName: "arrow.up.arrow.down")
//                    Spacer()
                }
//                .background(Color.blue)


            })
            .foregroundColor(Color(.darkGray))
        }
        .font(.system(size: 24, weight: .semibold))
        .padding()
    }
}

struct MainPadDeviceView___Previews: PreviewProvider {
    static var previews: some View {
        MainPadDeviceView()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
