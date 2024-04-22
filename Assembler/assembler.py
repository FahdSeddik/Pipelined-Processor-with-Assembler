import argparse
import re
from enum import Enum


class OperandType(Enum):
    DEST = "dest"
    SRC1 = "src1"
    SRC2 = "src2"
    IMMEDIATE = "immediate"

def decimal_to_binary(n, size):
    res = bin(int(str(n), 10))[2:]
    assert(len(res) <= size)
    return res.zfill(size)

def hex_to_binary(n, size = 16):
    res = bin(int(str(n), 16))[2:]
    assert(len(res) <= 16)
    return res.zfill(size)

class Instruction:
    def __init__(self, name, opcode, num_operands, operand_types, regex) -> None:
        self.name = name
        self.opcode = opcode
        self.num_operands = num_operands
        self.operand_types = [tuple(OperandType(op) for op in ops_tuple) for ops_tuple in operand_types]
        self.regex = re.compile(regex) # to match operands

ISA = {
    "RET": Instruction("RET", "0001", 0, [], ""),
    "RTI": Instruction("RTI", "0011", 0, [], ""),
    "NOP": Instruction("NOP", "0000", 0, [], ""),
    # 1 reg
    "OUT":      Instruction("OUT",      "0000", 1, [(OperandType.SRC1,)], r" *R([0-9])"),
    "PUSH":     Instruction("PUSH",     "0001", 1, [(OperandType.SRC2,)], r" *R([0-9])"),
    "PROTECT":  Instruction("PROTECT",  "0010", 1, [(OperandType.SRC1,)], r" *R([0-9])"),
    "FREE":     Instruction("FREE",     "0011", 1, [(OperandType.SRC1,)], r" *R([0-9])"),
    "JZ":       Instruction("JZ",       "0100", 1, [(OperandType.SRC1,)], r" *R([0-9])"),
    "JMP":      Instruction("JMP",      "0101", 1, [(OperandType.SRC1,)], r" *R([0-9])"),
    "CALL":     Instruction("CALL",     "0110", 1, [(OperandType.SRC1,)], r" *R([0-9])"),
    "IN":       Instruction("IN",       "1000", 1, [(OperandType.DEST,)], r" *R([0-9])"),
    "POP":      Instruction("POP",      "1001", 1, [(OperandType.DEST,)], r" *R([0-9])"),
    "LDM":      Instruction("LDM",      "1010", 1, [(OperandType.DEST,), (OperandType.IMMEDIATE,)], r" *R([0-9]) *, *([0-9A-F][0-9A-F]?[0-9A-F]?[0-9A-F]?)"),
    # 2 reg
    "MOV":      Instruction("MOV",      "0000", 2, [(OperandType.DEST,), (OperandType.SRC1,)], r" *R([0-9]) *, *R([0-9])"),
    "SWAP":     Instruction("SWAP",     "0001", 2, [(OperandType.DEST, OperandType.SRC1), (OperandType.SRC2,)], r" *R([0-9]) *, *R([0-9])"),
    "ADDI":     Instruction("ADDI",     "0010", 2, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.IMMEDIATE,)], r" *R([0-9]) *, *R([0-9]) *, *([0-9A-F][0-9A-F]?[0-9A-F]?[0-9A-F]?)"),
    "SUBI":     Instruction("SUBI",     "0011", 2, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.IMMEDIATE,)], r" *R([0-9]) *, *R([0-9]) *, *([0-9A-F][0-9A-F]?[0-9A-F]?[0-9A-F]?)"),
    "LDD":      Instruction("LDD",      "0100", 2, [(OperandType.DEST,), (OperandType.IMMEDIATE,), (OperandType.SRC1,)], r" *R([0-9]) *, *([0-9A-F][0-9A-F]?) *\( *R([0-9]) *\)"),
    "CMP":      Instruction("CMP",      "0101", 2, [(OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-9]) *, *R([0-9])"),
    "STD":      Instruction("STD",      "0110", 2, [(OperandType.SRC1,), (OperandType.IMMEDIATE,), (OperandType.SRC2,)], r" *R([0-9]) *, *([0-9A-F][0-9A-F]?) *\( *R([0-9]) *\)"),
    "NOT":      Instruction("NOT",      "0111", 2, [(OperandType.DEST, OperandType.SRC1)], r" *R([0-9])"),
    "NEG":      Instruction("NEG",      "1000", 2, [(OperandType.DEST, OperandType.SRC1)], r" *R([0-9])"),
    "INC":      Instruction("INC",      "1001", 2, [(OperandType.DEST, OperandType.SRC1)], r" *R([0-9])"),
    "DEC":      Instruction("DEC",      "1010", 2, [(OperandType.DEST, OperandType.SRC1)], r" *R([0-9])"),
    # 3 reg
    "ADD":      Instruction("ADD",      "0000", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-9]) *, *R([0-9]) *, *R([0-9])"),
    "SUB":      Instruction("SUB",      "0001", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-9]) *, *R([0-9]) *, *R([0-9])"),
    "AND":      Instruction("AND",      "0010", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-9]) *, *R([0-9]) *, *R([0-9])"),
    "OR":       Instruction("OR",       "0011", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-9]) *, *R([0-9]) *, *R([0-9])"),
    "XOR":      Instruction("XOR",      "0100", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-9]) *, *R([0-9]) *, *R([0-9])"),
    # Special
    ".org":     Instruction(".org",     "", 0, [(OperandType.IMMEDIATE,)], r" *([0-9A-F][0-9A-F]?[0-9A-F]?[0-9A-F]?)")
}


def transpile(lines):
    """
        This will take lines and output a list of address-instruction pairs

    Args:
        lines (list[str]): lines in the .asm file
    """
    transpiled = []
    org = 0
    comment = re.compile(r"^ *#.*")
    for line in lines:
        # line is comment
        line = line.strip()
        if len(line) <= 5: continue
        if len(comment.findall(line)) >= 1: continue
        name = line.split()[0]
        assert(name in ISA)
        if ISA[name].name == ".org": # is org
            org = int(ISA[name].regex.findall(line)[0], 16)
            continue
        tr_line = decimal_to_binary(ISA[name].num_operands, 2)
        tr_line += ISA[name].opcode
        dest = "000"
        src1 = "000"
        src2 = "000"
        imm = "0000000000000000"
        isImm = "0"
        matches = ISA[name].regex.findall(line)[0]
        for i,match in enumerate(matches):
            for opType in ISA[name].operand_types[i]:
                if opType == OperandType.DEST:
                    dest = decimal_to_binary(match, 3)
                elif opType == OperandType.SRC1:
                    src1 = decimal_to_binary(match, 3)
                elif opType == OperandType.SRC2:
                    src2 = decimal_to_binary(match, 3)
                else:
                    isImm = "1"
                    imm = hex_to_binary(match, 16)
        tr_line += dest + src1 + src2 + isImm
        transpiled.append((org, tr_line))
        org += 1
        if isImm == "0": continue
        transpiled.append((org, imm))
        org += 1
    return transpiled

def parse_transpiled(transpiled):
    """
    Takes in transpiled lines and produces .mem file lines

    Args:
        transpiled (list[tuple]): list of transpiled lines
    """
    output = []
    output.append("// memory data file (do not edit the following line - required for mem load use)\n")
    output.append("// instance=/processor/F/instruction_memory/r_mem\n")
    output.append("// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1\n")
    code_lines = ["{:>{width}}: 0000000000000000\n".format(i, width=4) for i in range(4096)]
    for address,line in transpiled:
        splitted = code_lines[address].split(": ")
        code_lines[address] = splitted[0] + ": " + line + "\n"
    output.extend(code_lines)
    return output

def process_file(file_path, output_path):
    with open(file_path, "r") as file:
        lines = file.readlines()
    transpiled = transpile(lines)
    output = parse_transpiled(transpiled)
    with open(output_path, "w") as f:
        f.writelines(output)


def main():
    argparser = argparse.ArgumentParser()
    argparser.add_argument("--file", "-F", dest="file_path", default="./testCasesPhase1.asm", help="Path to the file to process")
    argparser.add_argument("--output", "-O", dest="output_file", default="./instructions.mem", help="Output path")
    args = argparser.parse_args()
    process_file(args.file_path, args.output_file)

if __name__ == "__main__":
    main()