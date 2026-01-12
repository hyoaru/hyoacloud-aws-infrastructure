import json
from pathlib import Path
from typing import Annotated, Literal

import typer
from rich.console import Console

from cli.services.stack_lifecycle_manager import StackLifecycleManager
from cli.services.stack_lifecycle_manager.strategies.deploy_project import DeployProjectStackLifecycleStrategy
from cli.settings import Settings

app = typer.Typer()
console = Console()
settings = Settings()
stack = StackLifecycleManager()


@app.callback(invoke_without_command=True)
def deploy_project(
    project: Annotated[
        str,
        typer.Option(
            "-p",
            "--project",
            help="Target project",
            show_default=False,
        ),
    ],
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
    ],
):
    project_root = settings.PROJECT_ROOT

    if target.lower() == "all":
        console.print(f"Deploying all {project} templates in {settings.AWS_REGION}...")
        project_directory = project_root / "projects" / project
        with open(project_directory / "metadata.json", "r") as file:
            metadata = json.load(file)

        for item in metadata["order"]:
            template = project_directory / "infrastructure" / item["group"] / f"{item['layer']}.yaml"
            stack.execute(
                strategy=DeployProjectStackLifecycleStrategy(
                    project=project,
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
        strategy=DeployProjectStackLifecycleStrategy(
            project=project,
            region=settings.AWS_REGION,
            environment=environment,
            template=template,
        )
    )
