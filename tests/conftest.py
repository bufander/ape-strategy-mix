import pytest
from ape import Contract
from enum import IntFlag

# this should be the address of the ERC-20 used by the strategy/vault
ASSET_ADDRESS = "0x6b175474e89094c44da98b954eedeac495271d0f"  # DAI

MAX_INT = 2**256 - 1
DAY = 86400
WEEK = 7 * DAY


class ROLES(IntFlag):
    STRATEGY_MANAGER = 1
    DEBT_MANAGER = 2
    EMERGENCY_MANAGER = 4
    ACCOUNTING_MANAGER = 8


@pytest.fixture(scope="session")
def gov(accounts):
    # TODO: can be changed to actual governance
    return accounts[0]


@pytest.fixture(scope="session")
def strategist(accounts):
    return accounts[1]


@pytest.fixture(scope="session")
def user(accounts):
    return accounts[9]


@pytest.fixture(scope="session")
def asset():
    yield Contract(ASSET_ADDRESS)


# TODO: deploying vault, as there is no vault yet on mainnet. To be deleted once vault v3 is deployed
@pytest.fixture(scope="session")
def create_vault(project, gov):
    def create_vault(
        asset,
        governance=gov,
        deposit_limit=MAX_INT,
        max_profit_locking_time=WEEK,
    ):
        vault = gov.deploy(
            project.VaultV3, asset, "VaultV3", "AV", governance, max_profit_locking_time
        )
        # set vault deposit
        vault.set_deposit_limit(deposit_limit, sender=gov)
        # set up fee manager
        # vault.set_fee_manager(fee_manager.address, sender=gov)

        vault.set_role(
            gov.address,
            ROLES.STRATEGY_MANAGER | ROLES.DEBT_MANAGER | ROLES.ACCOUNTING_MANAGER,
            sender=gov,
        )
        return vault

    yield create_vault


@pytest.fixture
def vault(gov, asset, create_vault):
    vault = create_vault(asset)
    yield vault


@pytest.fixture
def strategy(project, vault, strategist):
    strategist.deploy(project.Strategy, vault, "TestStrategy")
    yield strategy
