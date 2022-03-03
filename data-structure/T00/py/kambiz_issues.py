"""
7151 => 7.1.5.1

55011859 => :8
  5.50.118.59
  55.0.118.59

0 .. 255  =[len]=>  1 .. 3
len: 4 .. 12
"""

# list_i: int "last index"
# IP: list[int]
# ip_n: nth index of IP [starts from 1]
# returns list[rest of IP]


def possible_ips_impl(ambiguous_ip, last_i, ip_n):
    acc = []

    for c in range(1, 4):  # stupic exclusive range :-/
        cut_i = last_i + c

        if cut_i <= len(ambiguous_ip):
            octet = ambiguous_ip[last_i:cut_i]

            # print(f"{ip_n} >>", (octet, last_i))
            if int(octet) in range(0, 256):
                if ip_n == 4:
                    if cut_i >= len(ambiguous_ip):
                        acc.append([octet])
                        break

                else:
                    results = possible_ips_impl(ambiguous_ip, cut_i, ip_n + 1)

                    for r in results:
                        acc.append([octet, *r])

            if octet == '0':
                break

    return acc


def possible_ips(ambiguous_ip):
    return ['.'.join(ip) for ip in possible_ips_impl(ambiguous_ip, 0, 1)]

# ---------------------------


if __name__ == "__main__":
    ambiguous_ip = input()

    for ip in possible_ips(ambiguous_ip):
        print(ip)
