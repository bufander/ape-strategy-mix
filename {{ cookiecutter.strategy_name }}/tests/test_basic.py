from utils import MAX_INT


def test_deploy(strategy, vault):
    assert strategy.name() == "strategy_name"
    assert strategy.vault() == vault.address

    assert vault.decimals() == 18


def test_max_deposit(strategy, vault):
    assert strategy.maxDeposit(vault) == MAX_INT


def test_deposit(strategy, vault, asset, gov, amount):
    # Note: vault deposits by using updateDebt method, this is just a strategy check
    assert asset.balanceOf(vault) == 0
    asset.mint(vault, amount, sender=gov)
    assert asset.balanceOf(vault) == amount

    asset.approve(strategy, amount, sender=vault)
    strategy.deposit(amount, vault, sender=vault)

    assert strategy.totalAssets() == amount
    assert asset.balanceOf(vault) == 0


def test_withdraw(strategy, vault, asset, gov, amount):
    # Note: vault withdraws by using _freeFunds method, this is just a strategy check
    assert asset.balanceOf(vault) == 0
    asset.mint(vault, amount, sender=gov)
    asset.approve(strategy, amount, sender=vault)
    strategy.deposit(amount, vault, sender=vault)

    strategy.withdraw(amount, vault, vault, sender=vault)

    assert strategy.totalAssets() == 0
    assert asset.balanceOf(vault) == amount
