// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// RarityManifestedMarket
interface RarityManifestedToken {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function transferFrom(
        address from,
        address to,
        uint256 tokenID
    ) external;
}

contract RarityManifestedMarket is Ownable {
    event Bought(uint256 blockNumber);
    event Listed(uint256 blockNumber);
    event Unlisted(uint256 blockNumber);
    event FeeChanged(uint256 fee);
    event MinPriceChanged(uint256 minPrice);
    event TransferFeeChanged(uint256 transferFee);

    enum Status {
        LISTED,
        UNLISTED,
        SOLD
    }

    struct Item {
        uint256 listId;
        uint256 tokenID;
        address owner; // who owns the listed summoner
        address buyer;
        uint256 price;
        uint256 payout; // price - price * fee / 100 or price - transferPrice
        Status status;
    }

    struct Storage {
        uint256 fee;
        uint256 minPrice;
        uint256 transferFee;
        uint256 feeBalance;
        uint256 listingCount;
        bool paused;
        mapping(uint256 => Item) listings; // all listings
        uint256[] listedIds;
        mapping(address => uint256) funds;
    }

    RarityManifestedToken private RMTokens;
    Storage private s;

    constructor(
        address tokensAddress,
        uint8 fee,
        uint256 minPrice,
        uint256 transferFee
    ) {
        RMTokens = RarityManifestedToken(tokensAddress);
        s.paused = false;
        s.fee = fee;
        s.minPrice = minPrice;
        s.transferFee = transferFee;
    }

    function list(uint256 tokenID, uint256 price) external {
        require(!s.paused, "Market is already paused");
        require(
            RMTokens.ownerOf(tokenID) == msg.sender,
            "Summoner is not yours"
        );

        uint256 payout = price - ((price * s.fee) / 100);
        require(price >= s.minPrice, "Price too low");

        uint256 listId = uint256(
            keccak256(
                abi.encodePacked(
                    tokenID,
                    msg.sender,
                    price,
                    block.timestamp,
                    block.difficulty
                )
            )
        );

        s.listings[listId] = Item({
            listId: listId,
            tokenID: tokenID,
            owner: msg.sender,
            buyer: address(0),
            price: price,
            payout: payout,
            status: Status.LISTED
        });

        s.listedIds.push(listId);
        s.listingCount++;

        RMTokens.transferFrom(msg.sender, address(this), tokenID);
        emit Listed(listId);
    }

    // buying function. User input is the price include fee
    function buy(uint256 listId) external payable {
        require(!s.paused, "Market is already paused");

        Item memory item = s.listings[listId];

        require(msg.value == item.price * 1e18, "wrong value");
        require(item.status == Status.LISTED, "summoner not listed");

        item.status = Status.SOLD;
        item.buyer = msg.sender;

        s.listings[listId] = item;
        s.funds[item.owner] += item.payout;
        s.listingCount--;
        s.feeBalance += item.price - item.payout;

        RMTokens.transferFrom(address(this), msg.sender, item.tokenID);

        emit Bought(listId);
    }

    function withdraw() external {
        uint256 amount = s.funds[msg.sender];
        if (amount > 0) {
            s.funds[msg.sender] = 0;
            Address.sendValue(payable(msg.sender), amount * 1e18);
        }
    }

    function getBalanceByAddress(address addr) public view returns (uint256) {
        return s.funds[addr];
    }

    function getMyBalance() public view returns (uint256) {
        return s.funds[msg.sender];
    }

    // Unlist a token you listed
    // Useful if you want your tokens back
    function unlist(uint256 listId) external {
        Item memory item = s.listings[listId];
        require(msg.sender == item.owner);

        item.status = Status.UNLISTED;

        s.listings[listId] = item;
        s.listingCount--;

        RMTokens.transferFrom(address(this), item.owner, item.tokenID);
        emit Unlisted(listId);
    }

    function getNListedSummoners() public view returns (uint256) {
        return s.listedIds.length;
    }

    function getSummoner(uint256 listId) public view returns (Item memory) {
        Item memory token = s.listings[listId];
        require(token.owner != address(0), "No summoner for that id");
        return token;
    }

    function bulkGetSummoners(uint256 startIdx, uint256 endIdx)
        public
        view
        returns (Item[] memory ret)
    {
        ret = new Item[](endIdx - startIdx);
        for (uint256 idx = startIdx; idx < endIdx; idx++) {
            ret[idx - startIdx] = getSummoner(s.listedIds[idx]);
        }
    }

    function getAllSummoners() public view returns (Item[] memory) {
        return bulkGetSummoners(0, s.listedIds.length);
    }

    function getSummonerPage(uint256 pageIdx, uint256 pageSize)
        public
        view
        returns (Item[] memory)
    {
        uint256 startIdx = pageIdx * pageSize;
        require(startIdx <= s.listedIds.length, "Page number too high");
        uint256 pageEnd = startIdx + pageSize;
        uint256 endIdx = pageEnd <= s.listedIds.length
            ? pageEnd
            : s.listedIds.length;
        return bulkGetSummoners(startIdx, endIdx);
    }

    function getNSummonersByOwner(address owner) public view returns (uint256) {
        uint256 cnt = 0;
        for (uint256 idx = 0; idx < s.listedIds.length; idx++) {
            if (getSummoner(s.listedIds[idx]).owner == owner) {
                cnt++;
            }
        }
        return cnt;
    }

    function getSummonersByOwner(address owner)
        public
        view
        returns (Item[] memory ret)
    {
        ret = new Item[](getNSummonersByOwner(owner));
        uint256 pos = 0;
        Item memory item;
        for (uint256 idx = 0; idx < s.listedIds.length; idx++) {
            item = getSummoner(s.listedIds[idx]);
            if (item.owner == owner) {
                ret[pos] = item;
                pos++;
            }
        }
    }

    function getNMySummoners() public view returns (uint256) {
        return getNSummonersByOwner(msg.sender);
    }

    function getMySummoners() public view returns (Item[] memory) {
        return getSummonersByOwner(msg.sender);
    }

    function getFee() public view returns (uint256) {
        return s.fee;
    }

    function getTransferFee() public view returns (uint256) {
        return s.transferFee;
    }

    function getMinPrice() public view returns (uint256) {
        return s.minPrice;
    }

    // ADMIN FUNCTIONS

    // Collect fees between rounds
    function collectFees() external onlyOwner {
        require(s.feeBalance > 0, "No fee left");
        Address.sendValue(payable(owner()), s.feeBalance * 1e18);
    }

    // change the fee
    function setFee(uint256 fee) external onlyOwner {
        require(fee <= 20, "don't be greater than 20%!");
        s.fee = fee;
        emit FeeChanged(s.fee);
    }

    function setTransferFee(uint256 transferFee) external onlyOwner {
        s.transferFee = transferFee;
        emit TransferFeeChanged(s.transferFee);
    }

    function setMinPrice(uint256 minPrice) external onlyOwner {
        s.minPrice = minPrice;
        emit MinPriceChanged(s.minPrice);
    }

    function pause() external onlyOwner {
        s.paused = true;
    }

    function unpause() external onlyOwner {
        require(s.paused, "Market is already unpaused");
        s.paused = false;
    }
}
