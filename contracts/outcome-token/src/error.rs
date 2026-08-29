use soroban_sdk::contracterror;

#[contracterror]
#[derive(Copy, Clone, Debug, Eq, PartialEq, PartialOrd, Ord)]
#[repr(u32)]
pub enum ContractError {
    AlreadyInitialized = 1,
    NotInitialized = 2,
    Unauthorized = 3,
    InsufficientBalance = 4,
    InvalidAmount = 5,
    Overflow = 6,
    /// A peer-to-peer `transfer` was attempted before the associated market
    /// resolved. Outcome tokens are only transferable once the market they
    /// belong to has settled its outcome.
    MarketNotResolved = 7,
    /// The on-chain storage schema version does not match the version this
    /// contract build expects (Issue #696).
    UpgradeRequired = 8,
    /// A peer-to-peer `transfer` was attempted after the associated market
    /// resolved. Settlement uses `Position` records keyed to the original
    /// depositor's address, not outcome-token holders — transferring after
    /// resolution would allow the same claim to be settled twice (Issue #690).
    TransferBlockedAfterResolve = 9,
    /// The contract is administratively paused. `mint`, `burn`, and `transfer`
    /// are all rejected until the admin calls `unpause`.
    ContractPaused = 10,
    /// The pending market-contract rotation has no change to cancel.
    NoPendingMarketContractChange = 11,
    /// The market-contract rotation timelock has not yet elapsed.
    TimelockNotElapsed = 12,
}
