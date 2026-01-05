import subprocess
from pathlib import Path

from rich import box
from rich.console import Console
from rich.markup import escape
from rich.table import Table

from cli.services.stack_lifecycle_manager.strategies.interface import StackLifecycleStrategyABC

console = Console()


class DeployCoreStackLifecycleStrategy(StackLifecycleStrategyABC):
    def __init__(self, region: str, template: Path):
        self.region = region
        self.group = template.parent.name
        self.layer = template.stem
        self.stack = f"core-{self.group}-{self.layer}"
        self.template = template

    def execute(self):
        console.print(f"\n[bold]Deploying Core[/bold] [dim]→ {self.group}/{self.layer}[/dim]")
        table = Table(box=box.ASCII2, show_header=False, padding=(0, 2))
        table.add_column(style="dim")
        table.add_column()
        table.add_row("stack", self.stack)
        table.add_row("region", f"[blue]{self.region}[/blue]")
        table.add_row("path", f"[dim]{self.layer}.yaml[/dim]")
        console.print(table)

        try:
            subprocess.run(
                [
                    "aws",
                    "cloudformation",
                    "deploy",
                    "--template-file",
                    self.template.resolve(),
                    "--stack-name",
                    self.stack,
                    "--region",
                    self.region,
                    "--capabilities",
                    "CAPABILITY_NAMED_IAM",
                    "CAPABILITY_AUTO_EXPAND",
                    "--no-fail-on-empty-changeset",
                ],
                check=True,
                capture_output=True,
                text=True,
            )

            console.print(f"[bold]Success[/bold] [green]✓[/green] [dim]| {self.stack} is active[/dim]")

        except subprocess.CalledProcessError as e:
            console.print(f"[bold]Failed[/bold] [red]✗[/red] [dim]| {self.stack} deployment crashed[/dim]")
            console.print(f"[dim]{escape(e.stderr.strip())}[/dim]\n")
