
import UIKit

struct CategoryCellViewModel {
    let title: String
    let isSelected: Bool
}

final class CategoriesViewModel {

    var categoryArrayDidChange: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?

    private var categoryStore: TrackerCategoryStoreProtocol

    private(set) var selectedCategory: String?

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        self.categoryStore.delegate = self
    }

    var categories: [TrackerCategory] {
        categoryStore.categories
    }

    func numberOfCategories() -> Int {
        categories.count
    }

    func cellViewModel(at indexPath: IndexPath) -> CategoryCellViewModel? {
        guard categories.indices.contains(indexPath.row) else {
            return nil
        }

        let category = categories[indexPath.row]

        return CategoryCellViewModel(
            title: category.title,
            isSelected: category.title == selectedCategory
        )
    }

    func selectCategory(at index: Int) {
        guard categories.indices.contains(index) else {
            return
        }

        let category = categories[index]
        selectedCategory = category.title

        categoryArrayDidChange?()
        onCategorySelected?(category.title)
    }

    func loadCategories() {
        try? categoryStore.fetchCategories()
        categoryArrayDidChange?()
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {

    func categoryStoreDidUpdate(_ store: TrackerCategoryStoreProtocol) {
        categoryArrayDidChange?()
    }
}
