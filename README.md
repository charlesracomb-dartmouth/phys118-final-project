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
git clone --recurse-submodules https://github.com/charlesracomb-dartmouth/phys118-final-project.git
```

From the analysis/gemini3d directory
```sh
cmake -B build
cmake --build build --parallel
```

## Use
Aurora Gemini is a MATLAB/Python library designed to create GEMINI input files from ESA SWARM conjunctions with 3 color ground based imagery (This work used only the DASC found at Poker Flat Research Range). In order to generate data from a new conjunction, the first step install the GLOW model and asispectralinversion python library. This is done through 
```sh
git clone https://github.com/317Lab/glow.git
cd glow
make -f make_invert_tables.v3
make -f make_invert_airglow.v3
cd ../
git clone https://github.com/317Lab/asispectralinversion.git
cd asispectralinversion/src
pip install .
cd ../..
```
Next, in the aurora_gemini/data folder, create a new directory for the event being analyzed. Create an events.dat file with the structure with the format shown in the example below. 
```sh
TITLE		SAMPLE DATA
DATE		6/24/2025
CORRESPONDENCE	JULES.VAN.IRSEL.GR@DARTMOUTH.EDU

ID		EVENT INDEX
DATETIME	EVENT DATE AND TIME IN ISO 8601 UTC
SWARM		ESA SWARM MISSION SPACECRAFT (ONE PER EVENT ID)
GLAT		GEOGRAPHIC CENTER LATITUDE (Â°)
GLON		GEOGRAPHIC CENTER LONGITUDE (Â°)
XDIST		EAST-WEST GRID DISTANCE (m)
YDIST		NORTH-SOUTH GRID DISTANCE (m)
X2PARMS		PARAMATERS DEFINING EASTWARD CELL SIZES (SEE https://github.com/gemini3d/gemini3d/blob/main/docs/Readme_input.md)
X3PARMS		PARAMETERS DEFINING NORTHWARD CELL SIZES
CONTOURS	ISO VALUES OF ARC DEFINITION: CONDUCTANCE (S) OR ENERGY FLUX (mW/m^2)
SRCE		SOURCE REGION CHARACTERISTIC ENERGY (eV)
BNDSMTH		BOUNDARY SMOOTHING PARAMATER
SDARNBG		SUPERDARN BACKGROUND FLOW: EAST,NORTH (GEOMAGNETIC, m/s)
PFISRBG		PFISR BACKGROUND FLOW: EAST,NORTH (GEOMAGNETIC, m/s)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ID	DATETIME		SWARM	GLAT	GLON	XDIST	YDIST	X2PARMS			X3PARMS			ARC	CONTOURS	SRCE	BNDSMTH	SDARNBG		PFISRBG
02	2023-02-10T09:51:27Z	A	65.4	216.1	320e3	200e3	19000,900,18000,9000	14000,400,8000,7000	h	7,7		490	100	-14,29		-343,2
03	2023-02-10T09:51:27Z	C	65.4	216.1	320e3	200e3	19000,900,18000,9000	14000,400,8000,7000	h	7,7		490	100	-14,29		-343,2
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
```

Next, run GLOW for the events. This is done within the aurora_gemini directory and
```sh
matlab -nodisplay
init
```
Ensure that all paths for required GEMINI directories populated correctly, or change the paths if needed. Now run glow
```sh
aurogem.glow.setup("path/to/directory/phys-118-final-project/analysis/aurora_gemini/data/EVENT")
```

Now that GLOW's emission lookup tables are generated, the imagery inversion will be performed. To do this, copy the /data/sample/dasc/ folder into a similar dasc subfolder in your own directory. Then run
```sh
python3 asi_inversion.py
```
to generate the precipitation maps in the image.

To prepare ESA Swarm data for Aurora_gemini, copy the /data/sample/swarm into your event directory. Download either the EFI or FAC instrument data from the ESA Swarm website and run 
```sh
python3 add_apex_data.py
```

The data is now organized, and aurora_gemini is ready to setup a GEMINI run. To start this process, return to /aurora_gemini/ and
```sh
matlab -nodisplay
init
aurogem.swop.setup(data_direc, event_id, swarm_id)
```
where event_id is the id listed in the events.dat file, and swarm_id is A, B, or C. Once this is completed, a new directory will be generated in the simulation_directory defined during the init with a slurm.script formatted to be used on the Reaserch Computing Cluster at Dartmouth.
To analyze the temperature data, return to the /phys118-final-project/analysis directory and 
```sh
matlab -nodisplay
temp_plot(data_direc, plot_direc)
```
where data_direc points to the directory the simulation data is stored, and plot_direc is the directory you want the output plots saved to.
In addition, many other output pluts (such as currents, electric fields, density, etc) can be generated through
```sh
aurogem.sim.plot(data_direc)
```
