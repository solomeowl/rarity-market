// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
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

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// RarityManifestedMarket
interface RarityManifestedToken {
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
        uint128 summonerType;
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

    function list(
        address buyer,
        uint256 tokenID,
        uint8 summonerType,
        uint256 price
    ) external {
        require(!s.paused, "Market is already paused");

        uint256 payout = price - ((price * s.fee) / 100);
        if (buyer == address(0)) {
            require(price >= s.minPrice, "Price too low");
        } else {
            payout = price - s.transferFee;
            require(payout >= 0, "Price too low");
        }

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
            buyer: buyer,
            summonerType: summonerType,
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

        if (item.buyer != address(0)) {
            require(item.buyer == msg.sender, "Wrong sender");
        }

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
