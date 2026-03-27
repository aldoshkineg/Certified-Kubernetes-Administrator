=== KUBERNETES + JQ EXAM CHEATSHEET ===

BASIC EXTRACTION:
  kubectl get <resource> -o json | jq '.items[].metadata.name'
  kubectl get pod <name> -o json | jq '.status'

FILTERING:
  jq 'select(.status.phase == "Running")'
  jq 'select(.spec.nodeName == "node-1")'
  jq 'select(.metadata.labels.app == "nginx")'

TRANSFORMATION:
  jq -r '.[] | "\(.name): \(.ip)"'      # String format
  jq 'map({name: .metadata.name})'       # Array of objects
  jq 'group_by(.node) | map({node: .[0].node, count: length})'

ERROR HANDLING:
  jq '.field // "default"'               # Default value
  jq 'try .field catch "error"'          # Try-catch

USEFUL FLAGS:
  -r          # Raw output (no quotes)
  -c          # Compact output
  -s          # Read all input into array
  --arg var value  # Pass variable

COMMON PATTERNS:
  # Get container images
  jq '.spec.containers[].image'

  # Check readiness
  jq '.status.conditions[] | select(.type=="Ready").status'

  # Find pods with restarts
  jq 'select(.status.containerStatuses[].restartCount > 0)'

  # Custom table
  jq -r '["NAME","STATUS"], (.items[] | [.metadata.name,.status.phase]) | @tsv'
