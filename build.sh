#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ -n "${JAVA_HOME:-}" ]]; then export PATH="$JAVA_HOME/bin:$PATH"; fi
mkdir -p build/classes build/test-classes
javac --release 17 -encoding UTF-8 -d build/classes src/main/java/br/com/torresmo/*.java
javac --release 17 -encoding UTF-8 -cp build/classes -d build/test-classes src/test/java/br/com/torresmo/*.java
java -Djava.awt.headless=true -cp build/classes:build/test-classes br.com.torresmo.CalculadoraHorarioTest
jar --create --file build/torresmo.jar --main-class br.com.torresmo.TorresmoApp -C build/classes .
