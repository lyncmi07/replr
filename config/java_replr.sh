#!/bin/bash

sed '1d' $1 | replr /usr/local/share/replr/java.replr
