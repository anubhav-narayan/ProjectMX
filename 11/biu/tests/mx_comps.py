from types import coroutine
from cocotb.triggers import RisingEdge
from cocotb_bus.bus import Bus
from cocotb_bus.drivers import BusDriver


class MXBus(Bus):
    _signals = ["txn_start", "txn_ack", "txn_cpl"]


class MXBaseBus(BusDriver):
    _signals = ["txn_start", "txn_ack", "txn_cpl"]
    
    def __init__(self, entity, name, clock, **kwargs):
        BusDriver.__init__(self, entity, name, clock, **kwargs)


class MXHost(MXBaseBus):
    def __init__(self, entity, name, clock, **kwargs):
        MXBaseBus.__init__(self, entity, name, clock, **kwargs)
        self.clock = clock

    @coroutine
    async def txn(self, address):
        await self._acquire_lock()
        await RisingEdge(self.clock)
        self.bus.txn_start.value = 1
        while self.bus.txn_ack.value != 1:
            await RisingEdge(self.clock)
        while self.bus.txn_cpl.value != 1:
            await RisingEdge(self.clock)
        self._release_lock()
