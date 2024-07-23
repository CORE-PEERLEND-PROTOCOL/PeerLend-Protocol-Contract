// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {PeerToken} from "../src/PeerToken.sol";
import {Protocol} from "../src/Protocol.sol";
import {Governance} from "../src/Governance.sol";
// import {IProtocolTest} from "../IProtocolTest.sol";
import "../src/Libraries/Errors.sol";


contract DeployScript is Script {
    PeerToken peerToken;
    Protocol protocol;
    Governance governance;

    ERC1967Proxy proxy;

    bytes32[] priceFeeds;
    address[] tokens;
    address pythAddr = 0xA2aa501b19aff244D90cc15a4Cf739D2725B5729;

    address benjamineAddr = 0xb2b2130b4B83Af141cFc4C5E3dEB1897eB336D79;

    bytes32 public DAIUSD =
        bytes32(
            0x87a67534df591d2dd5ec577ab3c75668a8e3d35e92e27bf29d9e2e52df8de412
        );
    bytes32 public LINKUSD =
        bytes32(
            0x83be4ed61dd8a3518d198098ce37240c494710a7b9d85e35d9fceac21df08994
        );
    bytes32 public WBTCUSD =
        bytes32(
            0xea0459ab2954676022baaceadb472c1acc97888062864aa23e9771bae3ff36ed
        );
    bytes32 public USDCUSD =
        bytes32(
            0x41f3625971ca2ed2263e78573fe5ce23e13d2558ed3f2e47ab0f84fb9e7ae722
        );
    address public DAI = 0x57a8f8b6eD04e92f053C19EFbF1ab8C0314Fe7b0;
    address public LINK = 0x1Fb9EEe6DF9cf79968D2b558AeDE454384498e2a;
    address public WBTC = 0x45d341D33624Cc53B1E61f73C076f8A545DA191D;
    address public USDC = 0x1Fb9EEe6DF9cf79968D2b558AeDE454384498e2a;
    address public USDT = 0x3786495F5d8a83B7bacD78E2A0c61ca20722Cce3;



    function setUp() public {
         priceFeeds.push(DAIUSD);
        priceFeeds.push(LINKUSD);
        priceFeeds.push(WBTCUSD);
        priceFeeds.push(USDCUSD);
        priceFeeds.push(USDCUSD);

        tokens.push(DAI);
        tokens.push(LINK);
        tokens.push(WBTC);
        tokens.push(USDC);
        tokens.push(USDT);

    }

    function run() public {
        vm.startBroadcast();
        peerToken = new PeerToken(msg.sender);

        governance = new Governance(address(peerToken));

        Protocol implementation = new Protocol();
        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(
                implementation.initialize,
                (
                    msg.sender,
                    tokens,
                    priceFeeds,
                    address(peerToken), 
                    pythAddr
                )
            )
        );
        // Attach the MyToken interface to the deployed proxy
        console.log("$PEER address", address(peerToken));
        console.log("Governance address", address(governance));
        console.log("Proxy Address", address(proxy));
        console.log("Protocol address", address(implementation));

        Protocol(address(proxy)).addLoanableToken(
            address(peerToken),
            DAIUSD
        );
         

        console.log("Loanable Token Added");

        peerToken.mint(benjamineAddr, 10000 * 10 ** 18);

        console.log("MINTED SUCCESSFUL");


        vm.stopBroadcast();
    }
}
