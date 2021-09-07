//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenID
    ) external;
}

contract Market {
    struct Listing {
        address owner; // who owns the listed summon
        uint256 buyoutPrice; // price of the summon in ftm
    }

    address public admin; // admin
    address public feeRecipient; // address who receive fee
    address public pendingAdmin; // the pending admin in case admin transfers ownership
    uint256 private fee = 0; // trading fee
    uint256 private tradingVolume = 0; // total trading volume
    mapping(uint256 => Listing) public listings; // all listings

    IERC721 private RMTokens;

    constructor(address tokensAddress, address feeAddress) {
        admin = msg.sender;
        feeRecipient = feeAddress;
        RMTokens = IERC721(tokensAddress);
    }

    // sendValue from openZeppelin Address library https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function list(uint256 tokenID, uint256 price) external {
        listings[tokenID] = Listing({owner: msg.sender, buyoutPrice: price});

        RMTokens.transferFrom(msg.sender, address(this), tokenID);
    }

    // buying function. User input is the price they pay
    function buy(uint256 tokenID) external payable {
        Listing memory oldListing = listings[tokenID];

        listings[tokenID] = Listing({owner: address(0), buyoutPrice: 0});
        require(msg.value == oldListing.buyoutPrice, "wrong value");
        RMTokens.transferFrom(address(this), msg.sender, tokenID);
        uint256 feeTmp = (oldListing.buyoutPrice * fee) / 100;
        tradingVolume += oldListing.buyoutPrice;
        sendValue(payable(feeRecipient), feeTmp);
        sendValue(payable(oldListing.owner), oldListing.buyoutPrice - feeTmp);
    }

    // Unlist a token you listed
    // Useful if you want your tokens back
    function unlist(uint256 id) external {
        address holder = listings[id].owner;
        require(msg.sender == holder);

        listings[id] = Listing({owner: address(0), buyoutPrice: 0});

        RMTokens.transferFrom(address(this), holder, id);
    }

    function totalTradingVolume() public view virtual returns (uint256) {
        return tradingVolume;
    }

    // ADMIN
    function setFee(uint256 newFee) external {
        require(msg.sender == admin, "admin function only");
        require(newFee >= 0, "wrong value");
        require(newFee <= 20, "wrong value");
        fee = newFee;
    }

    function giveOwnership(address newOwner) external {
        require(msg.sender == admin, "admin function only");
        pendingAdmin = newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == pendingAdmin, "you are not the pending admin");
        admin = pendingAdmin;
    }
}
