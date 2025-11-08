import json

def extract_themes(file_path, output_file):
  """
  Extracts theme names from a package.json file and stores them with numbers in a file.

  Args:
    file_path: Path to the package.json file.
    output_file: Path to the output file.
  """
  with open(file_path, "r") as f:
    data = json.load(f)

  themes = []
  for theme in data.get("contributes", {}).get("themes", []):
    themes.append(theme.get("label", ""))

  with open(output_file, "w") as f:
    for i, theme in enumerate(themes, 1):
      f.write(f"{i}. {theme}\n")

# Example usage
file_path = "package.json"
output_file = "extracted_themes.txt"

extract_themes(file_path, output_file)

print(f"Extracted themes saved to: {output_file}")
