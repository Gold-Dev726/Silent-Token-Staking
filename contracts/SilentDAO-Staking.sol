// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SilentStaking is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;

    /**
     * @notice Stores the ERC-20 token that will
     *         be staked and paid out.
     */
    IERC20 public erc20;

    /**
     * @notice Amount of tokens earned for each
     *         day (24 hours) the token was staked for
     *
     * @dev Can be changed by contract owner via setDailyRewards()
     */
    uint128 public dailyRewards;

    /**
     * @notice The tiers of stake period.
     *  Tier must be bigger than 0.
     */
    uint256[] public periodTiers = [0, 30 days, 60 days, 90 days];

    /**
     * @notice The tiers of stake amount for each period.
     *  Tier must be bigger than 0.
     */
    uint256[] public amountTiers = [0, 500, 5000, 50000];

    /**
     * @notice Informations for each staking.
     */
    struct stakeInfo {
        address owner;
        uint256 stakedAt;
        bool isExpired;
        uint8 tier;
    }

    mapping(address => stakeInfo[]) public stakedArrayByUser;


    /**
     * @dev Stores the staked tokens of an address
     */
    mapping(address => EnumerableSet.UintSet) private stakedTokens;

    /**
     * @dev Sets initialization variables which cannot be
     *      changed in the future
     *
     * @param _erc20Address address of erc20 rewards token
     * @param _dailyRewards daily amount of tokens to be paid to stakers for every day
     *                       they have staken
     */
    constructor(address _erc20Address, uint128 _dailyRewards) {
        erc20 = IERC20(_erc20Address);
        setDailyRewards(_dailyRewards);
    }

    /**
     * @dev Emitted every time a token is staked
     *
     * Emitted in stake()
     *
     * @param by address that staked the tokens
     * @param time block timestamp the tokens were staked at
     * @param tier tier number
     */
    event Staked(address indexed by, uint256 indexed tier, uint256 time);

    /**
     * @dev Emitted every time a token is unstaked
     *
     * Emitted in unstake()
     *
     * @param by address that unstaked the tokens
     * @param reward how many tokens user got for the
     *               staking
     */
    event Unstaked(
        address indexed by,
        uint256 reward
    );

    /**
     * @dev Emitted when the daily reward is changed
     *
     * Emitted in setDailyReward()
     *
     * @param by address that changed the daily reward
     * @param oldDailyRewards old daily reward
     * @param newDailyRewards new daily reward in effect
     */
    event DailyRewardsChanged(
        address indexed by,
        uint128 oldDailyRewards,
        uint128 newDailyRewards
    );

    /**
     * @notice Changes the daily reward in erc20 tokens received
     *
     * @dev Restricted to contract owner
     *
     * @param _newDailyRewards the new daily reward in erc20 tokens
     */
    function setDailyRewards(uint128 _newDailyRewards) public onlyOwner {
        // Emit event
        emit DailyRewardsChanged(msg.sender, dailyRewards, _newDailyRewards);

        // Change storage variable
        dailyRewards = _newDailyRewards;
    }

    /**
     * @notice Calculates all the tokens currently staken by
     *         an address
     *
     * @dev This is an auxiliary function to help with integration
     *      and is not used anywhere in the smart contract login
     *
     * @param _owner address to search staked tokens of
     * @return an array of tokens that are currently staken
     */
    function tokensStakedByOwner(address _owner)
        external
        view
        returns (stakeInfo[] memory)
    {
        // Return array result
        return stakedArrayByUser[_owner];
    }

    // function currentRewardsOf(uint256 _tokenId) public view returns (uint256) {
    //     require(stakedAt[_tokenId] != 0, "not staked");

    //     // Get current token ID staking time by calculating the
    //     // delta between the current block time(`block.timestamp`)
    //     // and the time the token was initially staked(`stakedAt[tokenId]`)
    //     uint256 stakingTime = block.timestamp - stakedAt[_tokenId];

    //     // `stakingTime` is the staking time in seconds
    //     // Calculate the staking time in days by:
    //     //   * dividing by 60 (seconds in a minute)
    //     //   * dividing by 60 (minutes in an hour)
    //     //   * dividing by 24 (hours in a day)
    //     // This will yield the (rounded down) staking
    //     // time in days
    //     uint256 stakingDays = stakingTime / 60 / 60 / 24;

    //     // Calculate reward for token by multiplying
    //     // rounded down number of staked days by daily
    //     // rewards variable
    //     uint256 reward = stakingDays * dailyRewards;

    //     // Return reward
    //     return reward;
    // }

    /**
     * @notice Stake native token to start earning ERC-20
     *         token rewards
     *
     * The ERC-20 token rewards will be paid out
     * when the native tokens are unstaken
     *
     * @dev Sender must first approve this contract
     *      to transfer native tokens on his behalf.
     *
     * @param tier The tier to be staken
     */
    function stake(uint8 tier) public {
        require(tier > 0, "Invalid tier");
        uint256 tokenBalanceOfUser = erc20.balanceOf(msg.sender);
        require(
            tokenBalanceOfUser > amountTiers[tier],
            "You have not enough balance for this tier."
        );

        // Transfer token to staking contract
        // Will fail if the user does not own the
        // token or has not approved the staking
        // contract for transferring tokens on his
        // behalf
        erc20.transferFrom(
            msg.sender,
            address(this),
            amountTiers[tier] * 10**18
        );

        stakeInfo memory newStake = stakeInfo(
            msg.sender,
            block.timestamp,
            false,
            tier
        );
        stakedArrayByUser[msg.sender].push(newStake);
        // Emit event
        emit Staked(msg.sender, tier, newStake.stakedAt);
    }

    /**
     * @notice Unstake native tokens to receive ERC-20 token rewards
     *
     * @param tier The tier to be unstaken
     */
    function unstake(uint8 tier) public {
        require(tier > 0, "Invalid tier");
        stakeInfo[] memory stakedByUser = stakedArrayByUser[msg.sender];
        for (uint256 i = 0; i < stakedByUser.length; i++) {
            if (stakedByUser[i].tier == tier) {
                require(block.timestamp - stakedByUser[i].stakedAt >= periodTiers[tier], "Staking period is not finished yet");
                stakedByUser[i] = stakeInfo(address(0), 0, false, 0);

                // Create a variable to store the total rewards for all
                uint256 totalRewards = 0;

                // rewards mechanism will be go to here

                erc20.transfer(msg.sender, amountTiers[tier] * 10 ** 18);
                // Emit event
                emit Unstaked(msg.sender, totalRewards);
            }
        }
    }
}
