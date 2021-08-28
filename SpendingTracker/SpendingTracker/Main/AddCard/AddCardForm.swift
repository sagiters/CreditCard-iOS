//
//  AddCardForm.swift
//  SpendingTracker
//
//  Created by Lien-Tai Kuo on 2021/8/28.
//

import SwiftUI

struct AddCardForm: View {

    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var cardNumber = ""
    @State private var limit = ""

    @State private var cardType = "Visa"

    @State private var month = 1
    @State private var year = Calendar.current.component(.year, from: Date())

    @State private var color = Color.blue

    let currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        NavigationView {
            Form {

                Section(header: Text("Card Info")) {
                    TextField("Name", text: $name)
                    TextField("Credit Card Number", text: $cardNumber)
                        .keyboardType(.numberPad)
                    TextField("Credit Limit", text: $limit)
                        .keyboardType(.numberPad)

                    Picker("Type", selection: $cardType) {
                        ForEach(["Visa", "Mastercard", "Discover", "Citybank"], id:\.self) { cardType in
                            Text(String(cardType)).tag(cardType)
                        }
                    }
                }

                Section(header: Text("Expiration")) {
                    Picker("Month", selection: $month) {
                        ForEach(0..<13, id:\.self) { num in
                            Text(String(num)).tag(num)
                        }
                    }

                    Picker("Year", selection: $year) {
                        ForEach(currentYear..<currentYear + 20, id:\.self) { num in
                            Text(String(num)).tag(num)
                        }
                    }
                }

                Section(header: Text("Color")) {
                    ColorPicker("Color", selection: $color)
                }

            }
            .navigationTitle("Add Cardit Card")
            .navigationBarItems(
                leading:
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                    })
            )
        }
    }
}

struct AddCardForm_Previews: PreviewProvider {
    static var previews: some View {
        AddCardForm()
    }
}
