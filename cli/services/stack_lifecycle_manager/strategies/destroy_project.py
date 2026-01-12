import json
import subprocess
from pathlib import Path
from typing import Literal

from pydantic import validate_call
from rich import box
from rich.console import Console
from rich.markup import escape
from rich.table import Table

from cli.services.stack_lifecycle_manager.strategies.interface import StackLifecycleStrategyABC

console = Console()


class DestroyProjectStackLifecycleStrategy(StackLifecycleStrategyABC):
    @validate_call
    def __init__(
        self,
        region: str,
        project: str,
        environment: Literal["dev", "stage", "prod"],
        template: Path,
    ):
        self.project = project
        self.region = region
        self.group = template.parent.name
        self.layer = template.stem
        self.environment = environment
        self.template = template
        self.stack = f"project-{self.project}-{self.environment}-{self.group}-{self.layer}"
        parameter_file = template.parents[2] / "parameters" / self.environment / self.group / f"{self.layer}.json"
        with open(parameter_file, "r") as file:
            self.parameters = [f"{k}={v}" for k, v in json.load(file).items()]

    @validate_call
    def execute(self):
        console.print(f"\n[bold]Destroying Project: {self.project}[/bold] [dim]→ {self.group}/{self.layer}[/dim]")
        table = Table(box=box.ASCII2, show_header=False, padding=(0, 2))
        table.add_column(style="dim")
        table.add_column()
        table.add_row("stack", self.stack)
        table.add_row("environment", f"[blue]{self.environment}[/blue]")
        table.add_row("project", f"[blue]{self.project}[/blue]")
        table.add_row("region", f"[blue]{self.region}[/blue]")
        table.add_row("path", f"[dim]{self.layer}.yaml[/dim]")
        console.print(table)

        try:
            subprocess.run(
                [
                    "aws",
                    "cloudformation",
                    "delete-stack",
                    "--stack-name",
                    self.stack,
                    "--region",
                    self.region,
                ],
                check=True,
                capture_output=True,
                text=True,
            )

            console.print(f"[bold]Success[/bold] [green]✓[/green] [dim]| Stack {self.stack} has been deleted[/dim]")

        except subprocess.CalledProcessError as e:
            console.print(f"[bold]Failed[/bold] [red]✗[/red] [dim]| {self.stack} deletion crashed[/dim]")
            console.print(f"[dim]{escape(e.stderr.strip())}[/dim]\n")
