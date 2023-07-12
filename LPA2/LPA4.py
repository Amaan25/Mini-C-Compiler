import re
instruction_map = {
    '+':'add',
    '-':'sub',
    '*':'mul',
    '<=':'sle',
    '>=':'sge',
    '<':'slt',
    '>':'sgt',
}
def parse_3addr_instr(instr):
    var = r'[a-zA-Z_][a-zA-Z0-9_]*'
    num = r'[0-9]+'
    b_op = r'<=|>=|<|>|\+|-|\*|/'
    label = r'L\d+'
    temp = r't\d+'
    instr = instr.strip()
    binary_pattern = re.compile(r'^(%s) = (%s|%s|%s) (%s) (%s|%s|%s)$' % (temp, var,num,temp, b_op, var,num,temp))
    assign_pattern = re.compile(r'^(%s) = (%s|%s|%s)$' % (var,num,temp,var))
    label_pattern = re.compile(r'^(%s):$' % label)
    if_pattern = re.compile(r'if (%s) goto (%s)' %(temp,label))
    unary_pattern = re.compile(r'^(%s) = not (%s)'%(temp,temp))
    jmp_pattern = re.compile(r'goto (%s)'%label)
    if binary_pattern.match(instr):
        groups = binary_pattern.match(instr).groups()
        print('#',[groups, 'binary_op'])
        if groups[1].isnumeric():
            print(f'addi $s0 $0 {groups[1]}')
        else:
            print(f'lw $s0 {groups[1]}')
        if groups[3].isnumeric():
            print(f'addi $s1 $0 {groups[3]}')
        else:
            print(f'lw $s1 {groups[3]}')
        if(instruction_map.get(groups[2])):
            print(f'{instruction_map[groups[2]]} ${groups[0]} $s0 $s1')
        elif groups[2]=='/':
            print(f'div $s0 $s1')
            print(f'mflo ${groups[0]}')
    elif assign_pattern.match(instr):
        groups = assign_pattern.match(instr).groups()
        print('#',[groups, 'assign'])
        if(groups[1].isnumeric()):
            print(f'addi $s0 $0 {groups[1]}\nsw $s0 {groups[0]}')
        else:
            print(f'lw $s0 ${groups[1]}\nsw $s0 {groups[0]}')
    elif label_pattern.match(instr):
        groups = label_pattern.match(instr).groups()
        print('#',[groups, 'label'])
        print(f'{groups[0]}:')
    elif if_pattern.match(instr):
        groups = if_pattern.match(instr).groups()
        print('#',[groups,'cond_jump'])
        print(f'bne ${groups[0]} $0 {groups[1]}')
    elif unary_pattern.match(instr):
        groups = unary_pattern.match(instr).groups()
        print('#',[groups, 'negate'])
        print(f'xori ${groups[0]} ${groups[1]} 1')
    elif jmp_pattern.match(instr):
        groups = jmp_pattern.match(instr).groups()
        print('#',[groups,'jump'])
        print(f'j {groups[0]}')

# Parse 3-address code and convert to MIPS instructions
with open('output.txt', 'r') as f3:
    code = f3.read()

lines = code.split('\n')
for line in lines:
    parse_3addr_instr(line)