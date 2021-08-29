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

                Text("TEST")
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

struct MainPadDeviceView___Previews: PreviewProvider {
    static var previews: some View {
        MainPadDeviceView()
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (3rd generation)"))
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
