import pytest
from enum import IntFlag
from utils import WEEK, MAX_INT


class ROLES(IntFlag):
    STRATEGY_MANAGER = 1
    DEBT_MANAGER = 2
    EMERGENCY_MANAGER = 4
    ACCOUNTING_MANAGER = 8


@pytest.fixture(scope="session")
def gov(accounts):
    return accounts[0]


@pytest.fixture(scope="session")
def strategist(accounts):
    return accounts[1]


@pytest.fixture(scope="session")
def user(accounts):
    return accounts[9]


@pytest.fixture
def asset(create_token):
    return create_token("asset")


# use this to create other tokens
@pytest.fixture
def create_token(project, gov):
    def create_token(name, decimals=18):
        return gov.deploy(project.Token, name, decimals)

    yield create_token


@pytest.fixture
def create_vault(project, gov):
    def create_vault(
        asset,
        governance=gov,
        deposit_limit=MAX_INT,
        max_profit_locking_time=WEEK,
    ):
        vault = gov.deploy(
            project.dependencies["yearn-vaults"]["master"].VaultV3,
            asset,
            "VaultV3",
            "AV",
            governance,
            max_profit_locking_time,
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
def create_strategy(project, strategist):
    def create_strategy(vault):
        strategy = strategist.deploy(project.Strategy, vault.address, "strategy_name")
        return strategy

    yield create_strategy


@pytest.fixture
def strategy(vault, create_strategy):
    strategy = create_strategy(vault)
    yield strategy


@pytest.fixture
def amount(asset, vault):
    # Always work with 1_000
    return 10 ** (18 + vault.decimals())
