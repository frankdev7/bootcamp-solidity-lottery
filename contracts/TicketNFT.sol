// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./LotteryNFT.sol";

contract TicketNFT {
    struct Owner {
        address ownerAddress;
        address scLottery;
        address scLotteryNFT;
        address scTicketNFT;
    }

    Owner public owner;

    constructor(
        address _owner,
        address _parent,
        address _nft
    ) {
        owner = Owner(_owner, _parent, _nft, address(this));
    }

    modifier onlyLottery(address _account) {
        require(msg.sender == owner.scLottery, "You arent Lottery SC");
        _;
    }

    function mintTicketNFT(address _account, uint256 id)
        public
        onlyLottery(_account)
    {
        LotteryNFT(owner.scLotteryNFT).safeMint(_account, id);
    }
}
