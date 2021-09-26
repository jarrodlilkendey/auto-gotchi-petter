// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

import { PokeMeReady } from "./PokeMeReady.sol";
import { Ownable } from "./Ownable.sol";

interface AavegotchiFacet {
  function tokenIdsOfOwner(address _owner) external view returns (uint32[] memory tokenIds_);
}

interface AavegotchiGameFacet {
  function interact(uint256[] calldata _tokenIds) external;
}

contract LazyPetter is PokeMeReady, Ownable {
  uint256 public lastExecuted;
  address private gotchiOwner;
  uint256[] private gotchis;
  AavegotchiFacet private af;
  AavegotchiGameFacet private agf;

  constructor(address payable _pokeMe, address gotchiDiamond, address _gotchiOwner) PokeMeReady(_pokeMe) {
    af = AavegotchiFacet(gotchiDiamond);
    agf = AavegotchiGameFacet(gotchiDiamond);
    gotchiOwner = _gotchiOwner;
    gotchis = af.tokenIdsOfOwner(gotchiOwner);
  }

  function resetGotchis(address _gotchiOwner) external onlyOwner {
    gotchiOwner = _gotchiOwner;
    gotchis = af.tokenIdsOfOwner(gotchiOwner);
  }

  function petGotchis() external onlyPokeMe {
    require(
      ((block.timestamp - lastExecuted) > 43200),
      "LazyPetter: pet: 12 hours not elapsed"
    );

    agf.interact(gotchis);

    lastExecuted = block.timestamp;
  }
}
