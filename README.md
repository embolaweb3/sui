 This project helps in managing restaurant operations including product management, invoicing, and financial transactions. This project utilizes the Sui Move language to define and interact with restaurant data structures.

## Table of Contents

- [DeepBook Project](#deepbook-project)
  - [Table of Contents](#table-of-contents)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
  - [Usage](#usage)
    - [Creating a Restaurant](#creating-a-restaurant)
    - [Adding a Product](#adding-a-product)
    - [Removing a Product from Stock](#removing-a-product-from-stock)
    - [Restocking a Product](#restocking-a-product)
    - [Changing Product Category](#changing-product-category)
    - [Buying a Product](#buying-a-product)
    - [Transferring from Restaurant](#transferring-from-restaurant)
    - [Checking Product Availability](#checking-product-availability)
    - [Checking Product Stock](#checking-product-stock)
  - [Constants](#constants)
  - [Data Structures](#data-structures)
  - [Contributing](#contributing)
  - [License](#license)

## Getting Started


### Installation

Clone the repository:

```sh
git clone https://github.com/embolaweb3/sui
cd sui-move-deepbook
```

Build the project:

```sh
sui move build
```

## Usage

### Creating a Restaurant

To create a new restaurant:

```rust
public fun create_restaurant(recipient: address, ctx: &mut TxContext)
```

### Adding a Product

To add a product to a restaurant:

```rust
public fun add_product(
    restaurant: &mut Restaurant,
    manager: &Management,
    title: vector<u8>,
    description: vector<u8>,
    price: u64,
    supply: u64,
    category: u8
)
```

### Removing a Product from Stock

To remove a product from the restaurant's stock:

```rust
public fun remove_product_from_stock(
    restaurant: &mut Restaurant,
    manager: &Management,
    product_id: u64
)
```

### Restocking a Product

To restock a product in the restaurant:

```rust
public fun restock_product(
    restaurant: &mut Restaurant,
    manager: &Management,
    product_id: u64
)
```

### Changing Product Category

To change the category of a product:

```rust
public fun change_product_category(
    restaurant: &mut Restaurant,
    manager: &Management,
    product_id: u64,
    category: u8
)
```

### Buying a Product

To buy a product from the restaurant:

```rust
public fun buy_product(
    restaurant: &mut Restaurant,
    product_id: u64,
    quantity: u64,
    recipient: address,
    coin: &mut coin::Coin<SUI>,
    ctx: &mut TxContext
)
```

### Transferring from Restaurant

To transfer an amount from the restaurant's balance to a recipient:

```rust
public fun transfer_from_restaurant(
    restaurant: &mut Restaurant,
    manager: &Management,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext
)
```

### Checking Product Availability

To check the availability of a product:

```rust
public fun check_product_availability(product: &Product): u64
```

### Checking Product Stock

To check if a product is in stock:

```rust
public fun check_product_stock(product: &Product): bool
```

## Constants

The module defines several constants representing error codes:

- `NOT_MANAGER`: Error code 1
- `INVALID_PRICE`: Error code 2
- `INVALID_SUPPLY`: Error code 3
- `INVALID_ID`: Error code 4
- `INVALID_QUANTITY`: Error code 5
- `INSUFFICIENT_BALANCE`: Error code 6
- `STOCK_OUT`: Error code 7
- `INVALID_AMOUNT`: Error code 8

## Data Structures

The following data structures are defined in this module:

- `Restaurant`
- `Management`
- `Product`
- `Invoice`

Each data structure has a specific role in managing restaurant operations, from maintaining product information to handling financial transactions.

## Contributing

Contributions are welcome! Please fork this repository and submit pull requests for any features, bug fixes, or enhancements.


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
