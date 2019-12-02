#!/bin/bash

sed '1d' $1 | ../_build/install/default/bin/replr java.replr
