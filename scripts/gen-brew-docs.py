import json
import subprocess
import os
import argparse


def run_command(command):
    """Run a shell command and return the JSON output."""
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        raise Exception(f"Command failed: {result.stderr}")
    return json.loads(result.stdout)


def load_json_file(file_path):
    """Load JSON data from a file."""
    with open(file_path, "r") as file:
        return json.load(file)


def generate_markdown_table(data, item_type):
    markdown_output = (
        f"| {'Name' if item_type == 'cask' else 'Formula'} | Description | Homepage |\n"
    )
    markdown_output += "|------|-----------|-------------|\n"
    for item in data:
        name = item["name"] if item_type == "cask" else item["name"]
        desc = item["desc"]
        homepage = item["homepage"]
        markdown_output += f"| {name} | {desc} | [Link]({homepage}) |\n"
    return markdown_output


def save_json_data(data, category, item_type):
    """Save JSON data to a file in the docs directory."""
    output_file_name = f"homebrew-{item_type}s-{category}.json"
    output_file_path = os.path.join("docs", output_file_name)

    os.makedirs(os.path.dirname(output_file_path), exist_ok=True)
    with open(output_file_path, "w") as file:
        json.dump(data, file, indent=4)
    print(f"JSON data saved to {output_file_path}")


def main(cask_json_path=None, formula_json_path=None, category=None):
    if cask_json_path is None:
        casks_command = "brew info --json=v2 --installed | jq '[.casks[] | {name: .full_token, desc: .desc, homepage: .homepage}]'"
        casks_data = run_command(casks_command)
    else:
        casks_data = load_json_file(cask_json_path)
    if formula_json_path is None:
        formulae_command = "brew info --json=v2 --installed | jq '[.formulae[] | {name: (select(any(.installed[]; .installed_on_request)).full_name), desc: .desc, homepage: .homepage}]'"
        formulae_data = run_command(formulae_command)
    else:
        formulae_data = load_json_file(formula_json_path)

    save_json_data(casks_data, category, "cask")
    save_json_data(formulae_data, category, "formula")

    markdown_casks = generate_markdown_table(casks_data, "cask")
    markdown_formulae = generate_markdown_table(formulae_data, "formula")

    markdown_output = "# Homebrew Cask and Formula Catalog\n\n"
    markdown_output += "## Installed Casks\n\n" + markdown_casks + "\n"
    markdown_output += "## Installed Formulae\n\n" + markdown_formulae

    output_file_name = f"homebrew-install-catalog-{category}.md"
    output_file_path = os.path.join("docs", output_file_name)
    output_file_path = os.path.join("docs", "homebrew-install-catalog-work.md")

    os.makedirs(os.path.dirname(output_file_path), exist_ok=True)
    with open(output_file_path, "w") as file:
        file.write(markdown_output)

    print(f"Markdown catalog saved to {output_file_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate a Markdown catalog of Homebrew casks and formulae."
    )
    parser.add_argument(
        "--cask-json", type=str, help="Path to the JSON file containing cask data."
    )
    parser.add_argument(
        "--formula-json",
        type=str,
        help="Path to the JSON file containing formula data.",
    )
    parser.add_argument(
        "--category",
        type=str,
        required=True,
        help="Specify category for the output file name. `work` for work packages or `personal` for personal packages",
    )

    args = parser.parse_args()

    main(
        cask_json_path=args.cask_json,
        formula_json_path=args.formula_json,
        category=args.category,
    )
