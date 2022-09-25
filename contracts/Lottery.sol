// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LotteryNFT.sol";
import "./TicketNFT.sol";

contract Lottery is ERC20, Ownable {
    // winner
    address public winner;

    // nft sc address
    address public nft;

    constructor() ERC20("MOUSE", "MOU") {
        _mint(address(this), 1000);
        nft = address(new LotteryNFT());
    }

    // user contract
    mapping(address => address) user_contract;

    function balanceEthers(address address_) public view returns (uint256) {
        return address(address_).balance / 10**18;
    }

    // Mint
    function mint(uint256 _amount) public onlyOwner {
        _mint(address(this), _amount);
    }

    // Register user
    function registerUser() internal {
        address add_personal_contract = address(
            new TicketNFT(msg.sender, address(this), nft)
        );
        user_contract[msg.sender] = add_personal_contract;
    }

    // User info
    function userContract(address _account) public view returns (address) {
        return user_contract[_account];
    }

    // Total tokens price
    function getTotalPrice(uint256 _amount) internal pure returns (uint256) {
        return _amount * (1 ether);
    }

    // Mouse tokens balance of SC
    function getBalanceMouseTokensSC() internal view returns (uint256) {
        return balanceOf(address(this));
    }

    // Buy Mouse tokens with ether
    function buyMouseTokens(uint256 _amount) public payable {
        // register user
        if (user_contract[msg.sender] == address(0)) {
            registerUser();
        }
        // price of tokens
        uint256 totalPrice = getTotalPrice(_amount);
        require(msg.value >= totalPrice, "insuficient ether balance");
        // get balance of tokens mouse from sc
        uint256 balance = getBalanceMouseTokensSC();
        require(_amount <= balance, "insuficient SC's mouse tokens");
        // Calculate change
        uint256 change = msg.value - totalPrice;
        // Return change
        payable(msg.sender).transfer(change);
        // Send mouse tokens
        _transfer(address(this), msg.sender, _amount);
    }

    // Sell Mouse tokens
    function sellMouseTokens(uint256 _amount) public payable {
        require(_amount > 0, "Amount should be greater than zero");
        require(
            _amount <= balanceOf(msg.sender),
            "Insuficient balance of mouse tokens"
        );
        _transfer(msg.sender, address(this), _amount);
        payable(msg.sender).transfer(getTotalPrice(_amount));
    }

    // MANAGING LOTTERY
    uint256 public ticketPrice = 5;
    mapping(address => uint256[]) public address_ticketsId;
    // ticket who wins
    mapping(uint256 => address) ADNTicket;
    uint256 randNonce = 0;
    uint256[] purchasedTickets;

    function buyTicket(uint256 _amount) public {
        uint totalPrice = _amount * ticketPrice;
        require(
            totalPrice >= balanceOf(msg.sender),
            "You dont have enough tickets"
        );
        _transfer(msg.sender, address(this), totalPrice);
        for (uint i = 0; i < _amount; i++) {
            uint random = uint(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % 10000;
            randNonce++;
            address_ticketsId[msg.sender].push(random);
            purchasedTickets.push(random);
            ADNTicket[random] = msg.sender;
            TicketNFT(user_contract[msg.sender]).mintTicketNFT(
                msg.sender,
                random
            );
        }
    }

    function myTickets(address _account) public view returns (uint[] memory) {
        return address_ticketsId[_account];
    }

    function chooseWinner() public onlyOwner {
        uint length = purchasedTickets.length;
        require(length > 0, "0 tickets sold");
        uint random = uint(
            uint(keccak256(abi.encodePacked(block.timestamp))) % length
        );
        uint numberWinner = purchasedTickets[random];
        winner = ADNTicket[numberWinner];
        payable(winner).transfer((address(this).balance * 95) / 100);
        payable(owner()).transfer((address(this).balance * 5) / 100);
    }
}
