// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

/// @title StarlinkPlanetManager
/// @notice A contract for planets in the virtual space
/// @dev Used in StarlinkSateNFT.sol
contract StarlinkPlanetManager is Ownable {
    using SafeMath for uint256;

    event StarlinkPlanetAdded(
        uint256 indexed planetId,
        string name,
        uint256 radius
    );

    /// @dev A structure for planet info
    struct PlanetInfo {
        string name;
        uint256 radius;
    }

    /// @dev Array for onchain virtual planets
    PlanetInfo[] public planets;

    /// @dev Last planet id pointer
    uint256 public indexPointer;

    constructor() public {
        _addPlanet("Mercury", 2439);
        _addPlanet("Venus", 6051);
        _addPlanet("Earth", 6378);
        _addPlanet("Mars", 3396);
        _addPlanet("Jupiter", 71492);
        _addPlanet("Saturn", 60268);
        _addPlanet("Uranus", 25559);
        _addPlanet("Neptune", 24764);
    }

    /// @dev Method for adding governed planets
    function addPlanet(string memory _name, uint256 _radius) external onlyOwner {
        _addPlanet(_name, _radius);
    }

    /// @dev Internal method for adding planet
    function _addPlanet(string memory _name, uint256 _radius) internal {
        planets.push(
            PlanetInfo(_name, _radius)
        );

        emit StarlinkPlanetAdded(indexPointer, _name, _radius);
        indexPointer = indexPointer.add(1);
    }
}