//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Airbnb{

    struct Property{
        string name;
        string description;
        bool isActive;
        uint price;
        address payable owner;
        bool[] isBooked;
    }

    uint256 public propertyId;

    mapping(uint256 => Property) public properties;

    struct Booking {
        uint256 propertyId;
        uint256 checkInDate;
        uint256 checkoutDate;
        address user;
    }

    uint256 public bookingId;

    mapping(uint256 => Booking) public bookings;

    event NewProperty(
        uint256 indexed propertyId
    );

    event NewBooking(
        uint256 indexed propertyId,
        uint256 indexed bookingId
    );

    function rentOutProperty(string memory name,string memory description, uint256 price) public{
    
        Property memory property=Property(name,description,true,price,payable(msg.sender),new bool[](365));
    
        properties[propertyId]= property;

        //emit an event to notify the clients of website
        emit NewProperty(propertyId++);
    
    }

    function rentProperty(uint256 _propertyId,uint256 checkInDate,uint256 checkoutDate) public payable{
        Property storage property= properties[_propertyId];

        require(
            property.isActive==true,"property with this ID is not active"
        );

        for(uint i =checkInDate; i<checkoutDate; i++){
            if(property.isBooked[i] ==true){
                revert("property is not available for the selected dates");
            }
        }

        require(
            msg.value==property.price*(checkoutDate-checkInDate),
            "Sent insufficient funds"
        );
        
        _sendFunds(property.owner,msg.value);

        _createBooking(_propertyId,checkInDate,checkoutDate);
    }

    function _createBooking(uint256 _propertyId,uint256 checkInDate,uint256 checkoutDate) internal{

        bookings[bookingId] = Booking(_propertyId,checkInDate,checkoutDate,msg.sender);

        Property storage property= properties[_propertyId];

        for(uint256 i=checkInDate;i<checkoutDate; i++){
            property.isBooked[i] = true;
        }

        emit NewBooking(_propertyId,bookingId++);
    }

    function _sendFunds (address payable beneficiary, uint256 value) internal{
        payable(beneficiary).transfer(value);
    }

    function markPropertyAsInactive(uint256 _propertyId) public{
        require(
            properties[_propertyId].owner==msg.sender,
            "this is not your property"
        );
        properties[_propertyId].isActive=false;
    }

}