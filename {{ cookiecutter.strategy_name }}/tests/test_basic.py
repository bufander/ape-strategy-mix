def test_deploy(strategy):
    assert strategy.name() == "strategy_name"
    assert strategy.symbol() == "strategy_symbol"
