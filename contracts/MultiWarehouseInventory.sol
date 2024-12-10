// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MultiWarehouseInventory {
    address public owner;
    mapping(address => uint) public stakes; // Stake mapping for access control
    uint public totalStaked; // Total tokens staked
    uint public maxInventoryCapacity = 1000; // Example inventory capacity limit

    struct Product {
        uint id;
        string name;
        uint quantity;
        uint expiryDate; // Timestamp for product expiry
        string manufacturer;
    }

    struct Inventory {
        uint id;
        string name;
        mapping(uint => Product) products; // Products in this inventory
        uint productCount; // Count of products
    }

    mapping(uint => Inventory) public inventories; // Track inventories by ID
    uint public inventoryCount; // Total inventories

    event InventoryCreated(uint indexed inventoryId, string name);
    event InventoryDeleted(uint indexed inventoryId);
    event ProductUpdated(
        uint indexed inventoryId,
        uint indexed productId,
        string action,
        uint change,
        uint newQuantity
    );
    event ProductDeleted(uint indexed inventoryId, uint indexed productId);
    event StakeWithdrawn(address indexed staker, uint amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyStaker() {
        require(stakes[msg.sender] > 0, "You must stake tokens to perform this action");
        _;
    }

    modifier checkCapacity(uint inventoryId, uint quantity) {
        require(
            inventories[inventoryId].productCount + quantity <= maxInventoryCapacity,
            "Exceeds inventory capacity"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Stake tokens to gain access
    function stakeTokens() public payable {
        require(msg.value > 0, "Stake must be a positive amount");
        stakes[msg.sender] += msg.value;
        totalStaked += msg.value;
    }

    // Withdraw staked tokens
    function withdrawStake() public {
        uint staked = stakes[msg.sender];
        require(staked > 0, "No tokens to withdraw");
        stakes[msg.sender] = 0;
        totalStaked -= staked;
        payable(msg.sender).transfer(staked);
        emit StakeWithdrawn(msg.sender, staked);
    }

    // Transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Create a new warehouse (inventory)
    function createInventory(string memory name) public onlyOwner {
        inventoryCount++;
        Inventory storage inventory = inventories[inventoryCount];
        inventory.id = inventoryCount;
        inventory.name = name;
        inventory.productCount = 0;
        emit InventoryCreated(inventoryCount, name);
    }

    // Delete an inventory
    function deleteInventory(uint inventoryId) public onlyOwner {
        require(inventories[inventoryId].id != 0, "Inventory does not exist");
        delete inventories[inventoryId];
        inventoryCount--;
        emit InventoryDeleted(inventoryId);
    }

    // Add a new product to a specific inventory
    function addProduct(
        uint inventoryId,
        uint productId,
        string memory productName,
        uint quantity,
        uint expiryDate,
        string memory manufacturer
    ) public onlyStaker checkCapacity(inventoryId, 1) {
        require(inventories[inventoryId].id != 0, "Inventory does not exist");
        require(inventories[inventoryId].products[productId].id == 0, "Product already exists");

        inventories[inventoryId].products[productId] = Product(
            productId,
            productName,
            quantity,
            expiryDate,
            manufacturer
        );
        inventories[inventoryId].productCount++;

        emit ProductUpdated(inventoryId, productId, "add", quantity, quantity);
    }

    // Update product quantity (add or remove)
    function updateProduct(
        uint inventoryId,
        uint productId,
        uint quantityChange,
        string memory action
    ) public onlyStaker {
        require(inventories[inventoryId].id != 0, "Inventory does not exist");
        require(inventories[inventoryId].products[productId].id != 0, "Product does not exist");

        if (keccak256(abi.encodePacked(action)) == keccak256(abi.encodePacked("add"))) {
            inventories[inventoryId].products[productId].quantity += quantityChange;
        } else if (keccak256(abi.encodePacked(action)) == keccak256(abi.encodePacked("remove"))) {
            require(
                inventories[inventoryId].products[productId].quantity >= quantityChange,
                "Insufficient product quantity"
            );
            inventories[inventoryId].products[productId].quantity -= quantityChange;
        } else {
            revert("Invalid action");
        }

        emit ProductUpdated(
            inventoryId,
            productId,
            action,
            quantityChange,
            inventories[inventoryId].products[productId].quantity
        );
    }

    // Delete a product from an inventory
    function deleteProduct(uint inventoryId, uint productId) public onlyStaker {
        require(inventories[inventoryId].id != 0, "Inventory does not exist");
        require(inventories[inventoryId].products[productId].id != 0, "Product does not exist");

        delete inventories[inventoryId].products[productId];
        inventories[inventoryId].productCount--;

        emit ProductDeleted(inventoryId, productId);
    }

    // Retrieve a product's details
    function getProduct(uint inventoryId, uint productId)
        public
        view
        returns (uint, string memory, uint, uint, string memory)
    {
        require(inventories[inventoryId].id != 0, "Inventory does not exist");
        require(inventories[inventoryId].products[productId].id != 0, "Product does not exist");

        Product memory product = inventories[inventoryId].products[productId];
        return (product.id, product.name, product.quantity, product.expiryDate, product.manufacturer);
    }
}
