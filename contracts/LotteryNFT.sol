// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Lottery.sol";

contract LotteryNFT is ERC721 {

    address public lotteryAddress;

    constructor() ERC721("CHEESE", "CHE") {
        lotteryAddress = msg.sender;
    }

    modifier onlyLottery(address _account) {
        require(
            msg.sender == Lottery(lotteryAddress).userContract(_account),
            "Forbidden"
        );
        _;
    }

    function safeMint(address _account, uint256 _id)
        public
        onlyLottery(_account)
    {
        _safeMint(_account, _id);
    }
}
