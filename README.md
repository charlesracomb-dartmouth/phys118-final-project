# phys118-final-project
Final Project for PHYS118 Computational Plasma Physics. This project uses GEMINI, a multifluid MHD model, to explore the relationship between ion temperature and electric field strength.

## Requirements
Per Aurora Gemini:
- MATLAB $\geq$ r2024a
- GEMINI requirements found here: \
https://github.com/317Lab/gemini3d/blob/main/Readme.md
<a/>

## Installation 
```sh
git clone --recursive-submodules https://github.com/charlesracomb-dartmouth/phys118-final-project.git
```

From the analysis/gemini3d directory
```sh
cmake -B build
cmake --build build --parallel
```

## Use
This repository is for analyising temperature data outputs for the GEMINI3D model. It is assumed output hdf5 data has already been generated as described in the aurora gemini repository.
