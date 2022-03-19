def possible_distributions(size):
    """
    possible_distributions(5)
    >> [
      [1, 1, 1, 2],
      [1, 1, 2, 1],
      [1, 2, 1, 1],
      [2, 1, 1, 1],
    ]
    """

    result = []

    for n1 in range(1, 4):
        for n2 in range(1, 4):
            for n3 in range(1, 4):
                for n4 in range(1, 4):
                    if n1 + n2 + n3 + n4 == size:
                        result.append([n1, n2, n3, n4])

    return result


def genIp(ambiguous_ip, distro):
    """
    genIp("55011859", [2, 1, 3, 2])
    >> ["55" , "0" , "118" , "59"]
    """

    result = []  # list of octet
    last = 0

    for n in distro:
        result.append(ambiguous_ip[last:last+n])
        last += n

    return result


def isValidIp(ip):
    """
    isValid(["55", "01", "18", "59"])
    >> false
    
    isValid(["55", "0", "118", "59"])
    >> true
    """

    for octet in ip:
        number = int(octet)

        if octet[0] == "0" and octet != "0":
            return False

        if not(number >= 0 and number <= 255):
            return False

    return True


def ipToString(ip):
    """
    ipToString(["55", "0", "118", "59"])
    >> "55.0.118.59"
    """

    return ip[0] + "." + ip[1] + "." + ip[2] + "." + ip[3]


def possibleIps(ambiguous_ip):
    result = []
    distros = possible_distributions(len(ambiguous_ip))

    for d in distros:
        ip = genIp(ambiguous_ip, d)
        if isValidIp(ip):
            result.append(ipToString(ip))

    
    return result


# run ---------------------


for s in possibleIps(input()):
    print(s)
