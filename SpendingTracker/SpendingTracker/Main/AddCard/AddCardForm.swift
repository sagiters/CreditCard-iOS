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

    var body: some View {
        NavigationView {
            Form {
                Text("Add card form")

                TextField("Name", text: $name)
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
