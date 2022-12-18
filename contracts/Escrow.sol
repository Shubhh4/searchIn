//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IERC721{ //the skeleton of the smartcontract which tell the functions are in the sc.
    function transferFrom(
        address _from,
        address _in,
        uint256 _id
    ) external;
}
contract Escrow{
    address public nftAddress; //to store the smart contract address nft for the transaction
    address payable public seller; //the seller will get the cryptocurrency in his transaction, for ether transfer
    address public inspector;
    address public lender;

     modifier onlyBuyer(uint256 _nftID){
        require(msg.sender==buyer[_nftID],"Only buyer can call this method");
        _;
    }

    modifier onlySeller(){
        require(msg.sender==seller,"Only seller can call this method");
        _;
    }

    modifier onlyInspector(){
        require(msg.sender==inspector,"Only inpector can call this method");
        _;
    }

    //the key value pair
    mapping(uint256 => bool) public isListed; //the property listed of no. will give true or false
    mapping(uint256 => uint256) public purchasePrice;  //crypto currency and ethers price
    mapping(uint256 => uint256) public escrowAmount;
    mapping(uint256 => address) public buyer; //nftID and the buyer adrresss
    mapping(uint256 => bool) public inspectionPassed; //for the inspection to be passed if not the default will be false
    mapping(uint256 => mapping(address => bool)) public approval; //key of the nft approval with the adresss of the person who is proved it 

    constructor(address _nftAddress, address payable _seller, address _inspector, address _lender){  //track the seting of sc.
      nftAddress = _nftAddress; //to set the address
      seller = _seller; //to set the address
      inspector = _inspector; //to set the address
      lender = _lender; //to set the address
    }

    function list(
        uint256 _nftID,
        address _buyer,
        uint256 _purchasePrice, 
        uint256 _escrowAmount
        ) public payable onlySeller{ //moving the nft from user wallet and add to escrow
    //Transfer NFT from seller to this contract
    IERC721(nftAddress).transferFrom(msg.sender , address(this), _nftID);

    isListed[_nftID] = true;
    purchasePrice[_nftID] = _purchasePrice;
    escrowAmount[_nftID] = _escrowAmount;
    buyer[_nftID] = _buyer;
    }

    //put under contract(only buyer --payable escrow) => only buyer can do these
    function depositEarnest(uint256 _nftID) public payable onlyBuyer(_nftID){
        require(msg.value >= escrowAmount[_nftID]);
    }

    //to update the inspection status (only inspection)
    function updateInspectionStatus(uint256 _nftID, bool _passed)
    public onlyInspector{
        inspectionPassed[_nftID] = _passed;
    }

    //approve sale
    function approveSale(uint256 _nftID) public {
        approval[_nftID][msg.sender] = true;
    }

   
    
    //to finalize the sale
    // require inspection status(add more items here, like appraisal)
    //require sale to be authorised
    //require fund to be correct amount
    //transfer the nft to the buyer
    //transfer funds to the seller
    function finaliseSale(uint256 _nftID) public{
        require(inspectionPassed[_nftID]);
        require(approval[_nftID][buyer[_nftID]]);
        require(approval[_nftID][seller]);
        require(approval[_nftID][lender]);

        require(address(this).balance >= purchasePrice[_nftID]);

        isListed[_nftID] = false;

        (bool success,) = payable(seller).call{value: address(this).balance}("");
        require(success);

    IERC721(nftAddress).transferFrom(address(this) , buyer[_nftID], _nftID);
    }

    // Cancel Sale (handle earnest deposit)
    // -> if inspection status is not approved, then refund, otherwise send to seller
    function cancelSale(uint256 _nftID) public {
        if (inspectionPassed[_nftID] == false) {
            payable(buyer[_nftID]).transfer(address(this).balance);
        } else {
            payable(seller).transfer(address(this).balance);
        }
    }

     receive() external payable{}  //the smart contract receive the ethers

    function getBalance() public view returns(uint256){
        return address(this).balance; //to return the current address balance
    }

    

}