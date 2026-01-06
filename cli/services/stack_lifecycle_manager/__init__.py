from pydantic import validate_call
from cli.services.stack_lifecycle_manager.interface import StackLifecycleManagerABC

__all__ = ["StackLifecycleManager", "StackLifecycleManagerABC"]


class StackLifecycleManager(StackLifecycleManagerABC):
    @validate_call
    def execute(self, strategy):
        strategy.execute()
