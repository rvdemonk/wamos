# experiments for WamoMath library

WORD = 78541660797044910968829902406342334108369226379826116161446442989268089806461
NUMBER = 53964

# goal is to extract individual digits from number


def split_digits(number):
    digits = []
    while number > 0:
        last_digit = number % 10
        digits.append(last_digit)
        number = number // 10
    return digits


def test_split_digits(number):
    digits = split_digits(number)
    string = str(number)
    length = len(string)
    for i in range(length):
        assert string[length - i - 1] == str(digits[i])
    return True


def main():
    success = test_split_digits(NUMBER)
    print(f"Sucess? {success}")


if __name__ == "__main__":
    main()
