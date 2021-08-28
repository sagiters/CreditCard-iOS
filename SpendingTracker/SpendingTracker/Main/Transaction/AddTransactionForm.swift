//
//  AddTransactionForm.swift
//  SpendingTracker
//
//  Created by Lien-Tai Kuo on 2021/8/28.
//

import SwiftUI

struct AddTransactionForm: View {

    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var photoData: Data?

    @State private var shouldPresentPhotoPicker = false

    var body: some View {
        NavigationView {
            Form {

                Section(header: Text("Information")) {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amount)
                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    NavigationLink(
                        destination:
                            Text("Many")
                            .navigationTitle("New Title"),
                        label: {
                            Text("Many to many")
                        })
                }

                Section(header: Text("Photo/Receipt")) {
                    Button(action: {
                        shouldPresentPhotoPicker.toggle()
                    }, label: {
                        Text("Select Photo")
                    })
                    .fullScreenCover(isPresented: $shouldPresentPhotoPicker, onDismiss: nil, content: {
                        PhotoPickerView(photoData: $photoData)
                    })

                    if let data = self.photoData,
                       let image = UIImage.init(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                }

            }
            .navigationTitle("Add Transaction")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)


        }
    }

    struct PhotoPickerView: UIViewControllerRepresentable {

        @Binding var photoData: Data?

        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

            private let parent: PhotoPickerView

            init(parent: PhotoPickerView) {
                self.parent = parent
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

                let image = info[.originalImage] as? UIImage
                let imageData = image?.jpegData(compressionQuality: 1)
                self.parent.photoData = imageData

                picker.dismiss(animated: true, completion: nil)
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true, completion: nil)
            }

        }

        func makeCoordinator() -> Coordinator {
            return Coordinator(parent: self)
        }

        func makeUIViewController(context: Context) -> some UIViewController {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = context.coordinator
            return imagePicker
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

        }
    }

    private var saveButton: some View {
        Button(action: {

            let context = PersistenceController.shared.container.viewContext

            let transaction = CardTransaction(context: context)
            transaction.name = self.name
            transaction.timestamp = self.date
            transaction.amount = Float(self.amount) ?? 0
            transaction.photoData = self.photoData

            do {
                try context.save()
                presentationMode.wrappedValue.dismiss()
            } catch let customError {
                print("Failed to save transaction: \(customError)")
            }

        }, label: {
            Text("Save")
        })
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }
}

struct AddTransactionForm_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionForm()
    }
}
