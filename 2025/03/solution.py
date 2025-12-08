def parse(filename):
    with open(filename) as f:
        lines = [[int(c) for c in list(s)] for s in f.read().splitlines()]
    return lines

def solve_part1(banks):
    jc = JoltageCalculator(banks)
    return jc.get_sum()

class JoltageCalculator:
    def __init__(self, banks):
        self.banks = banks
        self.bank_lengths = [len(b) for b in self.banks]

    def get_sum(self):
        joltage_sum = 0
        for n in range(0, len(self.banks)):
            joltage = self.largest_joltage_of_bank(n)
            joltage_sum += joltage
        return joltage_sum

    def get_joltage(self, which, index_tens, index_ones):
        return 10 * self.banks[which][index_tens] + self.banks[which][index_ones]

    def largest_joltage_of_bank(self, which):
        current_largest_joltage = 0
        for index_tens in range(0, self.bank_lengths[which] - 1):
            for index_ones in range(index_tens + 1, self.bank_lengths[which]):
                joltage = self.get_joltage(which, index_tens, index_ones) # potential optimization: don't construct this value if the index_tens value is less than current_largest_joltage first digit...
                if joltage > current_largest_joltage:
                    current_largest_joltage = joltage
        return current_largest_joltage

if __name__ == '__main__':
    # TODO add a testing framework?
    print('\npart 1...')
    print('\n\tsample...')
    print('should be 357 => ', solve_part1(parse('./sample.txt')))
    print('\n\tfull input...')
    print('should be 17694 => ', solve_part1(parse('./input.txt')))
