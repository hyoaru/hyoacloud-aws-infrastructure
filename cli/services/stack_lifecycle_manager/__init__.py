from cli.services.stack_lifecycle_manager.interface import StackLifecycleManagerABC

__all__ = ["StackLifecycleManager", "StackLifecycleManagerABC"]


class StackLifecycleManager(StackLifecycleManagerABC):
    def execute(self, strategy):
        strategy.execute()
