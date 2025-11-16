import gdb

# ---- Display Many ----
class DisplayMany(gdb.Command):
    def __init__(self):
        super(DisplayMany, self).__init__("dm", gdb.COMMAND_DATA)

    def invoke(self, arg, from_tty):
        vars = [v.strip() for v in arg.split(",")]
        for v in vars:
            try:
                val = gdb.parse_and_eval(v)
                print("{} = {}".format(v, val))
            except:
                print("{} = <error>".format(v))

# ---- Object Members ----
class Members(gdb.Command):
    def __init__(self):
        super().__init__("mbr", gdb.COMMAND_USER, gdb.COMPLETE_SYMBOL)

    def invoke(self, arg, from_tty):
        args = arg.split()
        if not args:
            print("Usage: mbr <obj> [field1 field2 ...]")
            return

        obj = gdb.parse_and_eval(args[0])
        all_fields = {f.name for f in obj.type.fields()}
        requested = args[1:] or all_fields

        for name in requested:
            if name not in all_fields:
                print(f"{name} = <no such field>")
                continue
            try: print(f"{name} = {obj[name]}")
            except: print(f"{name} = <error>")

    def complete(self, text, word):
        if word is None: return gdb.COMPLETE_SYMBOL

        tokens = word.split()
        if len(tokens) <= 1:
            return gdb.COMPLETE_SYMBOL

        obj_name, prefix = tokens[0], tokens[-1]
        try:
            obj = gdb.parse_and_eval(obj_name)
            fields = [f.name for f in obj.type.fields()]
        except:
            return []

        return [f for f in fields if f.startswith(prefix)]
 

# ---- Init the functions ----
Members()
DisplayMany()
