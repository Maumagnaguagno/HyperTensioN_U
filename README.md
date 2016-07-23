# HyperTensioN ND
**ND Hierarchical Task Network planning in Ruby**

This is a modified version of [HyperTensioN](https://github.com/Maumagnaguagno/HyperTensioN) to work with probabilities and rewards.
A simpler version of this can be found [here](https://github.com/Maumagnaguagno/HyperTensioN/blob/2226edbd967f42cea63c986a4a0ed71415bdc5e6/old_versions/simple/Hypertension_simple.rb).
As always Hype can help you in the conversion process, from NDJSHOP to Ruby, but can ignore the Hype and use Hypertension as a standalone library.

```Shell
Usage:
    Hype domain problem output

  Output:
    rb    - generate Ruby files to Hypertension ND(default)
    run   - same as rb with execution
    debug - same as run with execution log
```

To execute the cookie example is simple:

```Shell
ruby Hype.rb examples/cookie/cookie.ndjshop examples/cookie/pb1.ndjshop run
```

## NDJSHOP

### Domain
TODO

### Problem
TODO

## ToDo's
- Add domain reward support to converter
- Add problem reward support to converter
- Add NDJSHOP documentation
- Add examples
- Add tests
- Rename to HyperTensioN_P, use probability instead of non-deterministic?
- Merge with HyperTensioN?