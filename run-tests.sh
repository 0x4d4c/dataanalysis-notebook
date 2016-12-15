#!/bin/bash -eu

docker run -it --rm -v $(pwd)/tests:/tests 0x4d4c/dataanalysis-notebook /tests/run-pytest.sh $@

