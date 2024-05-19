#[allow(unused_use)]

module deepbook::book {

    use sui::event;
    use sui::sui::SUI;
    use sui::url::{Self, Url};
    use std::string::{Self, String};
    use sui::{coin, balance::{Self, Balance}};

    const NOT_MANAGER: u64 = 1;
    const INVALID_PRICE: u64 = 2;
    const INVALID_SUPPLY : u64 = 3;
    const INVALID_ID : u64 = 4;
    const INVALID_QUANTITY : u64 = 5;
    const INSUFFICIENT_BALANCE: u64 = 6;
    const STOCK_OUT: u64 = 7;
    const INVALID_AMOUNT : u64 = 8;

    /**
     * Represents a Restaurant with a unique identifier, management ID, balance, and list of products.
     */
    public struct Restaurant has key {
        id: UID,
        managementId: ID,
        balance: Balance<SUI>,
        products: vector<Product>,
        product_count: u64
    }

    /**
     * Represents the Management of a restaurant with a unique identifier and a reference to the restaurant ID.
     */
    public struct Management has key {
        id: UID,
        restaurant: ID,
    }

    /**
     * Represents a Product with a unique identifier, title, description, price, stock status, category, total supply, and availability.
     */
    public struct Product has store {
        id: u64,
        title: String,
        description: String,
        price: u64,
        inStock: bool,
        category: u8,
        total_supply: u64,
        available: u64
    }

    /**
     * Represents an Invoice with a unique identifier, restaurant ID, and product ID.
     */
    public struct Invoice has key {
        id: UID,
        restaurant_id: ID,
        product_id: u64
    }

    /**
     * Creates a new restaurant and transfers ownership to the recipient address.
     * @param recipient - The address to which the restaurant is transferred.
     * @param ctx - The transaction context.
     */
    public fun create_restaurant(recipient: address, ctx: &mut TxContext) {
        let restaurantUID = object::new(ctx);
        let managerUID = object::new(ctx);

        let restaurantID = object::uid_to_inner(&restaurantUID);
        let managerID = object::uid_to_inner(&managerUID);

        transfer::transfer(Management {
            id: managerUID,
            restaurant: restaurantID
         }, recipient);

        transfer::share_object(Restaurant {
            id: restaurantUID,
            managementId: managerID,
            balance: balance::zero<SUI>(),
            products: vector::empty(),
            product_count: 0,
        });
    }

    /**
     * Adds a new product to the restaurant's product list.
     * @param restaurant - The restaurant to which the product is added.
     * @param manager - The management struct for the restaurant.
     * @param title - The title of the product.
     * @param description - The description of the product.
     * @param price - The price of the product.
     * @param supply - The supply quantity of the product.
     * @param category - The category of the product.
     */
    public fun add_product(
        restaurant: &mut Restaurant,
        manager: &Management,
        title: vector<u8>,
        description: vector<u8>,
        price: u64,
        supply: u64,
        category: u8
    ) {
        assert!(restaurant.managementId == object::uid_to_inner(&manager.id), NOT_MANAGER);
        assert!(price > 0, INVALID_PRICE);
        assert!(supply > 0, INVALID_SUPPLY);

        let item_id = restaurant.products.length();

        let product = Product {
            id: item_id,
            title: string::utf8(title),
            description: string::utf8(description),
            price: price,
            inStock: true,
            category: category,
            total_supply: supply,
            available: supply,
        };

        restaurant.products.push_back(product);
        restaurant.product_count = restaurant.product_count + 1;
    }

    /**
     * Removes a product from the restaurant's stock.
     * @param restaurant - The restaurant from which the product is removed.
     * @param manager - The management struct for the restaurant.
     * @param product_id - The identifier of the product to be removed.
     */
    public fun remove_product_from_stock(
        restaurant: &mut Restaurant,
        manager: &Management,
        product_id: u64
    ) {
        assert!(restaurant.managementId == object::uid_to_inner(&manager.id), NOT_MANAGER);
        assert!(product_id <= restaurant.products.length(), INVALID_ID);

        restaurant.products[product_id].inStock = false;
    }

    /**
     * Restocks a product in the restaurant.
     * @param restaurant - The restaurant to which the product is restocked.
     * @param manager - The management struct for the restaurant.
     * @param product_id - The identifier of the product to be restocked.
     */
    public fun restock_product(
        restaurant: &mut Restaurant,
        manager: &Management,
        product_id: u64
    ) {
        assert!(restaurant.managementId == object::uid_to_inner(&manager.id), NOT_MANAGER);
        assert!(product_id <= restaurant.products.length(), INVALID_ID);

        restaurant.products[product_id].inStock = true;
    }

    /**
     * Changes the category of a product in the restaurant.
     * @param restaurant - The restaurant in which the product category is changed.
     * @param manager - The management struct for the restaurant.
     * @param product_id - The identifier of the product whose category is changed.
     * @param category - The new category of the product.
     */
    public fun change_product_category(
        restaurant: &mut Restaurant,
        manager: &Management,
        product_id: u64,
        category: u8
    ) {
        assert!(restaurant.managementId == object::uid_to_inner(&manager.id), NOT_MANAGER);
        assert!(product_id <= restaurant.products.length(), INVALID_ID);

        restaurant.products[product_id].category = category;
    }

    /**
     * Buys a product from the restaurant.
     * @param restaurant - The restaurant from which the product is bought.
     * @param product_id - The identifier of the product to be bought.
     * @param quantity - The quantity of the product to be bought.
     * @param recipient - The address of the recipient.
     * @param coin - The coin used for the transaction.
     * @param ctx - The transaction context.
     */
    public fun buy_product(
        restaurant: &mut Restaurant,
        product_id: u64,
        quantity: u64,
        recipient: address,
        coin: &mut coin::Coin<SUI>,
        ctx: &mut TxContext
    ) {
        assert!(product_id <= restaurant.products.length(), INVALID_ID);

        let product = &mut restaurant.products[product_id];

        assert!(product.available >= quantity, INVALID_QUANTITY);

        let value = coin.value();
        let total_price = product.price * quantity;
        assert!(value >= total_price, INSUFFICIENT_BALANCE);

        assert!(product.inStock == true, STOCK_OUT);

        product.available = product.available - quantity;

        let payment = coin.split(total_price, ctx);

        coin::put(&mut restaurant.balance, payment);

        let mut i = 0_u64;

        while (i < quantity) {
            let product_uid = object::new(ctx);

            transfer::transfer(Invoice {
                id: product_uid,
                restaurant_id: object::uid_to_inner(&restaurant.id),
                product_id: product_id
            }, recipient);

            i = i + 1;
        };

        if (product.available == 0) {
            vector::borrow_mut(&mut restaurant.products, product_id).inStock = false;
        }
    }

    /**
     * Transfers an amount from the restaurant's balance to the recipient.
     * @param restaurant - The restaurant from which the amount is transferred.
     * @param manager - The management struct for the restaurant.
     * @param amount - The amount to be transferred.
     * @param recipient - The address of the recipient.
     * @param ctx - The transaction context.
     */
    public fun transfer_from_restaurant(
        restaurant: &mut Restaurant,
        manager: &Management,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        assert!(restaurant.managementId == object::uid_to_inner(&manager.id), NOT_MANAGER);
        assert!(amount > 0 && amount <= restaurant.balance.value(), INVALID_AMOUNT);

        let take_coin = coin::take(&mut restaurant.balance, amount, ctx);

        transfer::public_transfer(take_coin, recipient);
    }

    /**
     * Checks the availability of a product.
     * @param product - The product whose availability is checked.
     * @returns The available quantity of the product.
     */
    public fun check_product_availability(product: &Product): u64 {
        product.available
    }

    /**
     * Checks the stock status of a product.
     * @param product - The product whose stock status is checked.
     * @returns True if the product is in stock, false otherwise.
     */
    public fun check_product_stock(product: &Product): bool {
        product.inStock
    }

}