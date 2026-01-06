import typer

from cli.commands import deploy_core, deploy_space, destroy_core, destroy_space

app = typer.Typer(help="Cloud Infrastructure Management Tool")

# Create intermediate groups
deploy_app = typer.Typer(help="Deploy infrastructure resources")
destroy_app = typer.Typer(help="Destroy infrastructure resources")

# Add the callback commands
deploy_app.add_typer(deploy_core.app, name="core", help="Deploy core resources")
destroy_app.add_typer(destroy_core.app, name="core", help="Destroy core resources")
deploy_app.add_typer(deploy_space.app, name="space", help="Deploy space resources")
destroy_app.add_typer(destroy_space.app, name="space", help="Destroy space resources")

# Add the groups to the main app
app.add_typer(deploy_app, name="deploy")
app.add_typer(destroy_app, name="destroy")


def run():
    app()
