# Alignment
**REQUIRES NLXUtilities (Provided in rep)**

Code to align NLX and Unity Data.

Currently tested to work with Color/Pseudo/Arnov Tasks

**Updates 07.27.2022**
- saves a matfile that shows runtime and session length in nlx timestamps

**Known Issues/Bugs (07.20.2022)**
1. Janky fix for when NEV file is read in as a string and not a number
2. 'MATLAB:badsubscript': 'Index in position 2 exceeds array bounds (must not exceed 8).
    - Haven't seen for color game tasks (07.20.2022)
3. 'MATLAB:unassignedOutputs': 'One or more output arguments not assigned during call to "Nlx2MatEV".'
    - Haven't seen for color game tasks (07.20.2022)
    - No header file in the actual NEV file???
4. 'MATLAB:subsassigndimmismatch': 'Unable to perform assignment because the indices on the left side are not compatible with the size of the right side.'
    - Seen in color game tasks, possible fix made (07.20.2022)
      - Brute forced the first value in the cell into a number rather than a string.
    - Problem with exporting from convertbehlog to [behdata(m), taskrng(m,:)]
