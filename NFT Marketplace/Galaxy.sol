// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.8.0/security/Pausable.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC20/extensions/draft-ERC20Permit.sol";

/**
  @title ERC20 contract having ability to pause, unpause, and initial minting of tokens.
  * initial mint = 10 * (10 ** 18)
  @author Ritwik Rohitashwa
 */
contract Galaxy is ERC20, Pausable, Ownable, ERC20Permit {
    uint256 constant INITIAL_SUPPLY = 100 * (10**18);

    constructor() ERC20("Galaxy", "GLX") ERC20Permit("Galaxy") {
        _mint(msg.sender, INITIAL_SUPPLY); //fixed initial supply
    }

    // this will pause the transfer function
    function pause() public onlyOwner {
        _pause();
    }

    // this will unpause the transfer function
    function unpause() public onlyOwner {
        _unpause();
    }

    // only the contract owner has right to mint tokens for others, it will increase the totalsupply
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // this will reward minter 10 tokens and increase the total supply by 10
    function _mintMinerReward() internal {
        _mint(block.coinbase, 10);
    }

    /**
     * this function will be called by the minter before they mint and it will call internally _mintMinerReward
     * and add increase the total supply by 10
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (!(from == address(0) && to == block.coinbase)) {
            _mintMinerReward();
        }
        super._beforeTokenTransfer(from, to, value);
    }
}
