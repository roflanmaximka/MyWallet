import UIKit
import CoreData

class AddExpenseViewModel: ObservableObject {
    
    var expenseObj: ExpenseCD?
    
    @Published var title = ""
    @Published var amount = ""
    @Published var occuredOn = Date()
    @Published var note = ""
    @Published var typeTitle = "Доход"
    @Published var tagTitle = getTransTagTitle(transTag: TRANS_TAG_TRANSPORT)
    @Published var showTypeDrop = false
    @Published var showTagDrop = false
    
    @Published var selectedType = TRANS_TYPE_INCOME
    @Published var selectedTag = TRANS_TAG_TRANSPORT
    
    @Published var imageUpdated = false // When transaction edit, check if attachment is updated?
    @Published var imageAttached: UIImage? = nil
    
    @Published var alertMsg = String()
    @Published var showAlert = false
    @Published var closePresenter = false
    
    init(expenseObj: ExpenseCD? = nil) {
        
        self.expenseObj = expenseObj
        self.title = expenseObj?.title ?? ""
        if let expenseObj = expenseObj {
            self.amount = String(expenseObj.amount)
            self.typeTitle = expenseObj.type == TRANS_TYPE_INCOME ? "Доход" : "Расход"
        } else {
            self.amount = ""
            self.typeTitle = "Доход"
        }
        self.occuredOn = expenseObj?.occuredOn ?? Date()
        self.note = expenseObj?.note ?? ""
        self.tagTitle = getTransTagTitle(transTag: expenseObj?.tag ?? TRANS_TAG_TRANSPORT)
        self.selectedType = expenseObj?.type ?? TRANS_TYPE_INCOME
        self.selectedTag = expenseObj?.tag ?? TRANS_TAG_TRANSPORT
        if let data = expenseObj?.imageAttached {
            self.imageAttached = UIImage(data: data)
        }
        
        AttachmentHandler.shared.imagePickedBlock = { [weak self] image in
            self?.imageUpdated = true
            self?.imageAttached = image
        }
    }
    
    func getButtText() -> String {
        if selectedType == TRANS_TYPE_INCOME { return "\(expenseObj == nil ? "Добавить" : "Редактировать") операцию" }
        else if selectedType == TRANS_TYPE_EXPENSE { return "\(expenseObj == nil ? "Добавить" : "Редактировать") операцию" }
        else { return "\(expenseObj == nil ? "Добавить" : "Редактировать") операцию" }
    }
    
    func attachImage() { AttachmentHandler.shared.showAttachmentActionSheet() }
    
    func removeImage() { imageAttached = nil }
    
    func saveTransaction(managedObjectContext: NSManagedObjectContext) {
        
        let expense: ExpenseCD
        let titleStr = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let amountStr = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if titleStr.isEmpty || titleStr == "" {
            alertMsg = "Введите название"; showAlert = true
            return
        }
        if amountStr.isEmpty || amountStr == "" {
            alertMsg = "Введите сумму"; showAlert = true
            return
        }
        guard let amount = Double(amountStr) else {
            alertMsg = "Введите корректное число"; showAlert = true
            return
        }
        guard amount >= 0 else {
            alertMsg = "Сумма не может быть отрицательной"; showAlert = true
            return
        }
        guard amount <= 1000000000 else {
            alertMsg = "Введите сумму меньше"; showAlert = true
            return
        }
        
        if expenseObj != nil {
            
            expense = expenseObj!
            
            if let image = imageAttached {
                if imageUpdated {
                    if let _ = expense.imageAttached {
                        // Delete Previous Image from CoreData
                    }
                    expense.imageAttached = image.jpegData(compressionQuality: 1.0)
                }
            } else {
                if let _ = expense.imageAttached {
                    // Delete Previous Image from CoreData
                }
                expense.imageAttached = nil
            }
            
        } else {
            expense = ExpenseCD(context: managedObjectContext)
            expense.createdAt = Date()
            if let image = imageAttached {
                expense.imageAttached = image.jpegData(compressionQuality: 1.0)
            }
        }
        expense.updatedAt = Date()
        expense.type = selectedType
        expense.title = titleStr
        expense.tag = selectedTag
        expense.occuredOn = occuredOn
        expense.note = note
        expense.amount = amount
        do {
            try managedObjectContext.save()
            closePresenter = true
        } catch { alertMsg = "\(error)"; showAlert = true }
    }
    
    func deleteTransaction(managedObjectContext: NSManagedObjectContext) {
        guard let expenseObj = expenseObj else { return }
        managedObjectContext.delete(expenseObj)
        do {
            try managedObjectContext.save(); closePresenter = true
        } catch { alertMsg = "\(error)"; showAlert = true }
    }
}
