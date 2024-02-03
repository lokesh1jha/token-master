// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TokenMaster is ERC721 {
    address public owner;
    uint256 public totalOccasions;
    uint256 public totalSupply;

    struct Occasion {
        uint256 id;
        string name;
        uint256 cost;
        uint256 tickets;
        uint256 maxTickets;
        string date;
        string time;
        string location;
    }

    mapping(uint256 => Occasion) occasions;

    // this will record that the buyer has bought it or not
    mapping(uint256 => mapping(address => bool)) public hasBought;

    // complex mapping
    // key: occasion_id     value: Mapping of seats
    // Mapping of seats will show which seat is booked by whom
    mapping(uint256 => mapping(uint256 => address)) public seatTaken;

    // to maintain the seat taken in each occasion
    mapping(uint256 => uint256[]) public seatsTaken;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _; // this is the function body where OnlyOwner will be used
    }

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        owner = msg.sender;
    }

    function list(
        string memory _name,
        uint256 _cost,
        uint256 _maxTicket,
        string memory _date,
        string memory _time,
        string memory _location
    ) public onlyOwner {
        totalOccasions++;

        occasions[totalOccasions] = Occasion(
            totalOccasions,
            _name,
            _cost,
            _maxTicket,
            _maxTicket,
            _date,
            _time,
            _location
        );
    }

    function getOccasion(uint256 _id) public view returns (Occasion memory) {
        return occasions[_id];
    }

    function mint(uint256 _id, uint256 _seat) public payable {
        // Require that _id is not 0 or less than total occasions...
        require(_id != 0);
        require(_id <= totalOccasions);

        // Require that ETH sent is greater than cost...
        require(msg.value >= occasions[_id].cost);

        // Require that the seat is not taken, and the seat exists...
        require(seatTaken[_id][_seat] == address(0));
        require(_seat <= occasions[_id].maxTickets);

        occasions[_id].tickets -= 1; // Update the ticket count

        hasBought[_id][msg.sender] = true; // Update buying status
        seatTaken[_id][_seat] = msg.sender; // Assign buyer the seat number

        seatsTaken[_id].push(_seat); // Update taken seat array

        totalSupply++;
        _safeMint(msg.sender, totalSupply);
    }

    function getSeatsTaken(uint256 _id) public view returns (uint256[] memory){
        return seatsTaken[_id];
    }

    function withdraw() public onlyOwner {
    
        /*
        address(this) --> address of this contract 

        owner.call{value: address(this).balance}(""): This is the call function, 
        which is used to execute an external function call. In this case, 
        it's sending Ether to the owner address. The {value: address(this).balance} 
        part specifies that the call should include a transfer of the entire balance 
        of the current contract (address(this).balance). The empty string "" represents 
        the function signature (if any) of the function being called. Since we're not 
        calling any specific function, it's empty.
        */
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}
