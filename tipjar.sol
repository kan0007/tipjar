// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;

contract tips {

    address owner;

    constructor() {
        owner = msg.sender;
    }

    function addtips() public payable {}

    function viewtips() public view returns (uint) {
        return address(this).balance;
    }

    struct Waitress {
        address payable walletAddress;
        string name;
        uint percent;
    }

    Waitress[] waitress;

    function viewWaitress() public view returns (Waitress[] memory) {
        return waitress;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    // ฟังก์ชันเช็ค percent รวม
    function _checkPercent(uint newPercent) internal view {
    uint sum = 0;

    for (uint i = 0; i < waitress.length; i++) {
        sum += waitress[i].percent;
    }

    require(sum + newPercent <= 100, "Total percent exceeds 100%");
}

    function addWaitress(
    address payable walletAddress,
    string memory name,
    uint percent
) public onlyOwner {

    require(percent > 0 && percent <= 100, "Percent must be 1-100");

    _checkPercent(percent); // เช็ครวมต้องไม่เกิน 100

    bool waitressExist = false;

    for (uint i = 0; i < waitress.length; i++) {
        if (waitress[i].walletAddress == walletAddress) {
            waitressExist = true;
        }
    }

    require(!waitressExist, "Waitress already exists");

    waitress.push(Waitress(walletAddress, name, percent));
}


    function removeWaitress(address walletAddress) public onlyOwner {

        uint length = waitress.length;
        require(length > 0, "No waitress");

        for (uint i = 0; i < length; i++) {
            if (waitress[i].walletAddress == walletAddress) {

                waitress[i] = waitress[length - 1];
                waitress.pop();

                return;
            }
        }

        revert("Waitress not found");
    }

    function distributeBalance() public onlyOwner {

        require(address(this).balance > 0, "No Money");

        uint totalamount = address(this).balance;

        for (uint j = 0; j < waitress.length; j++) {
            uint distributeAmount =
                (totalamount * waitress[j].percent) / 100;

            _transferFunds(waitress[j].walletAddress, distributeAmount);
        }
    }

    function _transferFunds(address payable recipient, uint amount) internal {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed.");
    }
}
