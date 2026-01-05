import json
from pathlib import Path
from typing import Annotated

import typer
from rich.console import Console

from cli.services.stack_lifecycle_manager import StackLifecycleManager
from cli.services.stack_lifecycle_manager.strategies import DestroyCoreStackLifecycleStrategy
from cli.settings import Settings

app = typer.Typer()
console = Console()
settings = Settings()
stack = StackLifecycleManager()


@app.callback(invoke_without_command=True)
def destroy_core(target: Annotated[str, typer.Argument(help="Path or 'all'")] = "all"):
    project_root = settings.PROJECT_ROOT

    if target.lower() == "all":
        console.print(f"Destroying all core templates in {settings.AWS_REGION}...")
        core_tier_directory = project_root / "core"
        with open(core_tier_directory / "metadata.json", "r") as file:
            metadata = json.load(file)

        for item in metadata["order"][::-1]:
            stack.execute(
                strategy=DestroyCoreStackLifecycleStrategy(
                    region=settings.AWS_REGION,
                    template=core_tier_directory / item["group"] / item["layer"],
                )
            )

        return

    template = Path(target)
    if not template.exists() or not template.is_file():
        console.print(f"[bold red]Error:[/bold red] File not found: [dim]{target}[/dim]")
        raise typer.Exit(code=1)

    stack.execute(
        strategy=DestroyCoreStackLifecycleStrategy(
            region=settings.AWS_REGION,
            template=template,
        )
    )
