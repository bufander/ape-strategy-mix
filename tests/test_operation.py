def test_operation(asset, vault, strategy, user):
    initial_balance_user = asset.balanceOf(user)
    assert initial_balance_user == 0
