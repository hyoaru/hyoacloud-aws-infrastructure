import json
from pathlib import Path
from typing import Annotated, Literal

import typer
from cli.services.stack_lifecycle_manager.strategies.destroy_space import DestroySpaceStackLifecycleStrategy
from rich.console import Console

from cli.services.stack_lifecycle_manager import StackLifecycleManager
from cli.settings import Settings

app = typer.Typer()
console = Console()
settings = Settings()
stack = StackLifecycleManager()


@app.callback(invoke_without_command=True)
def destroy_space(
    environment: Annotated[
        Literal["dev", "stage", "prod"],
        typer.Option(
            "-e",
            "--environment",
            help="Target environment (dev, stage, or prod)",
            show_default=False,
        ),
    ],
    target: Annotated[
        str,
        typer.Argument(help="Path or 'all'"),
    ] = "all",
):
    project_root = settings.PROJECT_ROOT

    if target.lower() == "all":
        console.print(f"Destroying all space stacks in {settings.AWS_REGION}...")
        space_tier_directory = project_root / "space"
        with open(space_tier_directory / "metadata.json", "r") as file:
            metadata = json.load(file)

        for item in metadata["order"]:
            template = space_tier_directory / item["group"] / f"{item['layer']}.yaml"
            stack.execute(
                strategy=DestroySpaceStackLifecycleStrategy(
                    region=settings.AWS_REGION,
                    environment=environment,
                    template=template,
                )
            )

        return

    template = Path(target)
    if not template.exists() or not template.is_file():
        console.print(f"[bold red]Error:[/bold red] File not found: [dim]{target}[/dim]")
        raise typer.Exit(code=1)

    stack.execute(
        strategy=DestroySpaceStackLifecycleStrategy(
            region=settings.AWS_REGION,
            environment=environment,
            template=template,
        )
    )
