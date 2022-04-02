#!/bin/bash

make clean
cd src
flex golex.l
cd ..
make