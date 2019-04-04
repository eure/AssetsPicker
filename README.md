# 📸 AssetsPicker

TODO

## Overview

TODO

## 🔶 Requirements

TODO

## 📱 Features

TODO

## 👨🏻‍💻 Usage

### Default value

```swift
let photoPicker = AssetPickerViewController()
photoPicker.pickerDelegate = self
        
present(photoPicker, animated: true, completion: nil)
```

### Customization

#### Use Custom Cell classes

```swift
let cellRegistrator = AssetPickerCellRegistrator()
cellRegistrator.register(cellClass: Demo2AssetCell.self, forCellType: .asset)
cellRegistrator.register(cellClass: Demo2AssetCollectionCell.self, forCellType: .assetCollection)

let photoPicker = AssetPickerViewController()
                    .setCellRegistrator(cellRegistrator)

photoPicker.pickerDelegate = self

present(photoPicker, animated: true, completion: nil)
```

#### Use Custom Nib classes

```swift
let assetNib = UINib(nibName: String(describing: Demo3AssetNib.self), bundle: nil)
let assetCollectionNib = UINib(nibName: String(describing: Demo3AssetCollectionNib.self), bundle: nil)

let cellRegistrator = AssetPickerCellRegistrator()
cellRegistrator.register(nib: assetNib, forCellType: .asset)
cellRegistrator.register(nib: assetCollectionNib, forCellType: .assetCollection)

let photoPicker = AssetPickerViewController()
                    .setCellRegistrator(cellRegistrator)

photoPicker.pickerDelegate = self

present(photoPicker, animated: true, completion: nil)
```

#### Add header view

```swift
let headerView = UIView()
headerView.backgroundColor = .orange
headerView.translatesAutoresizingMaskIntoConstraints = false
headerView.heightAnchor.constraint(equalToConstant: 120).isActive = true

let photoPicker = AssetPickerViewController()
                    .setHeaderView(headerView, isHeaderFloating: true)

photoPicker.pickerDelegate = self

present(photoPicker, animated: true, completion: nil)
```

#### Other customization

```swift
func setSelectionMode(_ selectionMode: SelectionMode)
func setSelectionMode(_ selectionColor: UIColor)
func setSelectionColor(_ tintColor: UIColor)
func setNumberOfItemsPerRow(_ numberOfItemsPerRow: Int)
func setHeaderView(_ headerView: UIView, isHeaderFloating: Bool)
func setCellRegistrator(_ cellRegistrator: AssetPickerCellRegistrator)
func setMediaTypes(_ supportOnlyMediaType: [PHAssetMediaType])
func disableOnLibraryScrollAnimation()
func localize(_ localize: LocalizedStrings)
```

## Installation

### CocoaPods

TODO

### Carthage

TODO

### What's using AssetsPicker


TODO
## Author

TODO

## Contributors

TODO

## License

AssetsPicker is released under the MIT license.
