import os
import re

# We will walk through lib/ and apply some regex replacements.

dart_files = []
for root, dirs, files in os.walk('lib'):
    for f in files:
        if f.endswith('.dart'):
            dart_files.append(os.path.join(root, f))

# Regexes
# Replace Colors.white with AppColors.getSurfaceColor(context) if it seems like a background
# Actually, a safer generalized approach:
# Colors.white -> AppColors.getSurfaceColor(context) 
# Colors.grey[xxx] -> AppColors.getTextSecondaryColor(context)
# color: const Color(0xFFFBFBFB) -> color: AppColors.getBackgroundColor(context)

replacements = [
    (r'Colors\.white', r'AppColors.getSurfaceColor(context)'),
    (r'Colors\.black', r'AppColors.getTextPrimaryColor(context)'),
    (r'Colors\.grey\[[0-9]+\]\!?', r'AppColors.getTextSecondaryColor(context)'),
    (r'Colors\.grey', r'AppColors.getTextSecondaryColor(context)'),
    (r'const Color\(0xFFFBFBFB\)', r'AppColors.getBackgroundColor(context)'),
    (r'const Color\(0xFFF3F3F5\)', r'AppColors.getBackgroundColor(context)'),
]

# We need to compute the relative path to lib/core/theme/app_colors.dart for the import
def get_relative_import(filepath):
    # lib/features/pme/presentation/screens/foo.dart
    # depth = count of '/' after lib/
    parts = filepath.split('/')
    # parts[0] is 'lib'
    depth = len(parts) - 2 # e.g. lib/foo.dart -> depth 0
    if depth == 0:
        return "import 'core/theme/app_colors.dart';"
    else:
        prefix = '../' * depth
        return f"import '{prefix}core/theme/app_colors.dart';"

for filepath in dart_files:
    if 'app_colors.dart' in filepath or 'app_theme.dart' in filepath:
        continue
        
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content

    for pat, rep in replacements:
        content = re.sub(pat, rep, content)

    # Some false replacements: 'const AppColors.getSurfaceColor(context)' -> 'AppColors.getSurfaceColor(context)'
    content = content.replace('const AppColors', 'AppColors')
    # Because of context, we can't have const TextStyle(color: AppColors.getTextSecondaryColor(context))
    content = re.sub(r'const\s+(TextStyle|BoxDecoration|Divider|Icon|BorderSide)', r'\1', content)
    # Also remove const if there's a const before it in a list, but that's hard to regex perfectly.
    
    # If the content changed, ensure AppColors is imported
    if content != original_content and 'app_colors.dart' not in content:
        import_stmt = get_relative_import(filepath)
        # add import after other imports
        lines = content.split('\n')
        import_idx = 0
        for i, line in enumerate(lines):
            if line.startswith('import '):
                import_idx = i
        
        lines.insert(import_idx + 1, import_stmt)
        content = '\n'.join(lines)

    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)

print("Refactoring complete.")
