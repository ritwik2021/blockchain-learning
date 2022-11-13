//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

/**
 * @dev This is the simple contract where we can do a transaction from one account to another
 */
contract Transactions {
    uint256 transactionCount;

    event Transfer(
        address from,
        address receiver,
        uint256 amount,
        string message,
        uint256 timestamp
    );

    struct TransferStruct {
        address sender;
        address receiver;
        uint256 amount;
        string message;
        uint256 timestamp;
    }

    TransferStruct[] transactions;

    // this function takes 3 arguement to make a transaction. this will transfer the funds from one account to another
    function makeTransaction(
        address payable receiver,
        uint256 amount,
        string memory message
    ) public {
        transactionCount += 1;
        transactions.push(
            TransferStruct(
                msg.sender,
                receiver,
                amount,
                message,
                block.timestamp
            )
        );

        emit Transfer(msg.sender, receiver, amount, message, block.timestamp);
    }

    // this function get the transaction list
    function getAllTransactions()
        public
        view
        returns (TransferStruct[] memory)
    {
        return transactions;
    }

    //this function prints the number of transactions
    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }
}
