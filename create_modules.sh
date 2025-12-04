#!/bin/bash
set -e

echo "🚀 MeloMeter 모듈 생성 시작"

BASE_DIR="$(pwd)/Projects"
MODULES=("Domain" "Data" "Presentation" "Core" "Shared")

mkdir -p "$BASE_DIR"

for MODULE in "${MODULES[@]}"; do
  echo "📁 $MODULE 생성 중..."
  mkdir -p "$BASE_DIR/$MODULE"
  cat > "$BASE_DIR/$MODULE/Project.swift" <<'EOF'
import ProjectDescription

let project = Project(
  name: "$MODULE",
  targets: [
    .target(
      name: "$MODULE",
      destinations: .iOS,
      product: .framework,
      bundleId: "com.teamMeloMeter.${MODULE,,}",
      deploymentTargets: .iOS("16.0"),
      sources: [],
      resources: [],
      dependencies: []
    )
  ]
)
EOF
done

echo "✅ 모든 모듈(Project.swift) 생성 완료!"

