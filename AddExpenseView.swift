import SwiftUI

struct AddExpenseView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // CoreData
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var confirmDelete = false
    @State var showAttachSheet = false
    
    @StateObject var viewModel: AddExpenseViewModel
    
    let typeOptions = [
        DropdownOption(key: TRANS_TYPE_INCOME, val: "Доход"),
        DropdownOption(key: TRANS_TYPE_EXPENSE, val: "Расход")
    ]
    
    let tagOptions = [
        DropdownOption(key: TRANS_TAG_TRANSPORT, val: "Транспорт"),
        DropdownOption(key: TRANS_TAG_FOOD, val: "Еда"),
        DropdownOption(key: TRANS_TAG_HOUSING, val: "Жильё"),
        DropdownOption(key: TRANS_TAG_INSURANCE, val: "Страховка"),
        DropdownOption(key: TRANS_TAG_MEDICAL, val: "Медицина"),
        DropdownOption(key: TRANS_TAG_SAVINGS, val: "Сбережения"),
        DropdownOption(key: TRANS_TAG_PERSONAL, val: "Личное"),
        DropdownOption(key: TRANS_TAG_ENTERTAINMENT, val: "Развлечения"),
        DropdownOption(key: TRANS_TAG_OTHERS, val: "Другое"),
        DropdownOption(key: TRANS_TAG_UTILITIES, val: "Коммунальные услуги")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primary_color.edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    Group {
                        if viewModel.expenseObj == nil {
                            ToolbarModelView(title: "Добавить операцию") { self.presentationMode.wrappedValue.dismiss() }
                        } else {
                            ToolbarModelView(title: "Редактирование операции", button1Icon: IMAGE_DELETE_ICON) { self.presentationMode.wrappedValue.dismiss() }
                                button1Method: { self.confirmDelete = true }
                        }
                    }.alert(isPresented: $confirmDelete,
                            content: {
                                Alert(title: Text(APP_NAME), message: Text("Вы уверены что хотите удалить операцию?"),
                                    primaryButton: .destructive(Text("Удалить")) {
                                        viewModel.deleteTransaction(managedObjectContext: self.managedObjectContext)
                                    }, secondaryButton: Alert.Button.cancel(Text("Отмена"), action: { confirmDelete = false })
                                )
                            })
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: 12) {
                            
                            TextField("Название", text: $viewModel.title)
                                .modifier(InterFont(.regular, size: 16))
                                .accentColor(Color.text_primary_color)
                                .frame(height: 50).padding(.leading, 16)
                                .background(Color.secondary_color)
                                .cornerRadius(4)
                            
                            TextField("Сумма", text: $viewModel.amount)
                                .modifier(InterFont(.regular, size: 16))
                                .accentColor(Color.text_primary_color)
                                .frame(height: 50).padding(.leading, 16)
                                .background(Color.secondary_color)
                                .cornerRadius(4).keyboardType(.decimalPad)
                            
                            DropdownButton(shouldShowDropdown: $viewModel.showTypeDrop, displayText: $viewModel.typeTitle,
                                           options: typeOptions, mainColor: Color.text_primary_color,
                                           backgroundColor: Color.secondary_color, cornerRadius: 4, buttonHeight: 50) { key in
                                let selectedObj = typeOptions.filter({ $0.key == key }).first
                                if let object = selectedObj {
                                    viewModel.typeTitle = object.val
                                    viewModel.selectedType = key
                                }
                                viewModel.showTypeDrop = false
                            }
                            
                            DropdownButton(shouldShowDropdown: $viewModel.showTagDrop, displayText: $viewModel.tagTitle,
                                           options: tagOptions, mainColor: Color.text_primary_color,
                                           backgroundColor: Color.secondary_color, cornerRadius: 4, buttonHeight: 50) { key in
                                let selectedObj = tagOptions.filter({ $0.key == key }).first
                                if let object = selectedObj {
                                    viewModel.tagTitle = object.val
                                    viewModel.selectedTag = key
                                }
                                viewModel.showTagDrop = false
                            }
                            
                            HStack {
                                DatePicker("Просмотр выбора", selection: $viewModel.occuredOn,
                                           displayedComponents: [.date, .hourAndMinute]).labelsHidden().padding(.leading, 16)
                                Spacer()
                            }
                            .frame(height: 50).frame(maxWidth: .infinity)
                            .accentColor(Color.text_primary_color)
                            .background(Color.secondary_color).cornerRadius(4)
                            
                            TextField("Заметка", text: $viewModel.note)
                                .modifier(InterFont(.regular, size: 16))
                                .accentColor(Color.text_primary_color)
                                .frame(height: 50).padding(.leading, 16)
                                .background(Color.secondary_color)
                                .cornerRadius(4)
                            
                            Button(action: { viewModel.attachImage() }, label: {
                                HStack {
                                    Image(systemName: "paperclip")
                                        .font(.system(size: 18.0, weight: .bold))
                                        .foregroundColor(Color.text_secondary_color)
                                        .padding(.leading, 16)
                                    TextView(text: "Прикрепить изображение", type: .button).foregroundColor(Color.text_secondary_color)
                                    Spacer()
                                }
                            })
                            .frame(height: 50).frame(maxWidth: .infinity)
                            .background(Color.secondary_color)
                            .cornerRadius(4)
                            .actionSheet(isPresented: $showAttachSheet) {
                                ActionSheet(title: Text("Вы уверены что хотите удалить изображение?"), buttons: [
                                    .default(Text("Удалить")) { viewModel.removeImage() },
                                    .cancel()
                                ])
                            }
                            
                            if let image = viewModel.imageAttached {
                                Button(action: { showAttachSheet = true }, label: {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 250).frame(maxWidth: .infinity)
                                        .background(Color.secondary_color)
                                        .cornerRadius(4)
                                })
                            }
                            
                            Spacer().frame(height: 150)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity).padding(.horizontal, 8)
                        .alert(isPresented: $viewModel.showAlert,
                               content: { Alert(title: Text(APP_NAME), message: Text(viewModel.alertMsg), dismissButton: .default(Text("ОК"))) })
                    }
                    
                }.edgesIgnoringSafeArea(.top)
                
                VStack {
                    Spacer()
                    VStack {
                        Button(action: { viewModel.saveTransaction(managedObjectContext: managedObjectContext) }, label: {
                            HStack {
                                Spacer()
                                TextView(text: viewModel.getButtText(), type: .button).foregroundColor(.white)
                                Spacer()
                            }
                        })
                        .padding(.vertical, 12).background(Color.main_color).cornerRadius(8)
                    }.padding(.bottom, 16).padding(.horizontal, 8)
                }
                
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onReceive(viewModel.$closePresenter) { close in
            if close { self.presentationMode.wrappedValue.dismiss() }
        }
    }
}

//struct AddExpenseView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddExpenseView()
//    }
//}
