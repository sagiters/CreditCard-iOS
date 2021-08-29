//
//  AddTransactionForm.swift
//  SpendingTracker
//
//  Created by Lien-Tai Kuo on 2021/8/28.
//

import SwiftUI

struct AddTransactionForm: View {

    let card: Card

    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var photoData: Data?

    @State private var shouldPresentPhotoPicker = false

    @State private var selectedCategories = Set<TransactionCategory>()

    var body: some View {
        NavigationView {
            Form {

                Section(header: Text("Information")) {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amount)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section(header: Text("Categories")) {
                    NavigationLink(
                        destination:
                            CategoriesListView(selectedCategories: $selectedCategories)
                            .navigationTitle("Categories")
                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext),
                        label: {
                            Text("Select categories")
                        })

                    let sortedByTimestampCategories = Array(selectedCategories).sorted(by: { $0.timestamp?.compare($1.timestamp ?? Date()) == .orderedDescending })

                    ForEach(Array(sortedByTimestampCategories)) { category in
                        HStack(spacing: 12) {
                            if let data = category.colorData,
                               let uiColor = UIColor.color(data: data) {
                                let color = Color(uiColor)

                                Spacer()
                                    .frame(width: 30, height: 10)
                                    .background(color)
                            }
                            Text(category.name ?? "")
                        }

                    }
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
                let resizeImage = image?.resized(to: .init(width: 500, height: 500))
                let imageData = resizeImage?.jpegData(compressionQuality: 0.5)
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

            transaction.card = card

            transaction.categories = self.selectedCategories as NSSet

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

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            let hScale = newSize.height / size.height
            let vScale = newSize.width / size.width
            let scale = max(hScale, vScale)
            let resizeSize = CGSize(width: size.width * scale, height: size.height * scale)
            var middle = CGPoint.zero
            if resizeSize.width > newSize.width {
                middle.x -= (resizeSize.width - newSize.width) / 2.0
            }
            if resizeSize.height > newSize.height {
                middle.y -= (resizeSize.height - newSize.height) / 2.0
            }

            draw(in: CGRect(origin: middle, size: resizeSize))
        }
    }
}

import CoreData
struct AddTransactionForm_Previews: PreviewProvider {

    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return try? context.fetch(request).first
    }()

    static var previews: some View {
        if let card = firstCard {
            AddTransactionForm(card: card)
        }
    }
}
