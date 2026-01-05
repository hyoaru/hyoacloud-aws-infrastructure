from abc import ABC, abstractmethod

from cli.services.stack_lifecycle_manager.strategies.interface import StackLifecycleStrategyABC


class StackLifecycleManagerABC(ABC):
    @abstractmethod
    def execute(self, strategy: StackLifecycleStrategyABC):
        pass
