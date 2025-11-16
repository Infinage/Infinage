set disassembly-flavor intel
set pagination off
set history save on
set history size 10000
set history filename ~/.gdb_history
set print repeats 0
set print elements 2000

# Load python helpers
python
import os, sys
home = os.path.expanduser("~/.gdb")
if os.path.isdir(home):
    sys.path.insert(0, home)
    import helpers
end
