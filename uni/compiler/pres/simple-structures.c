#include <stdio.h>

struct DateTime
{
  int year, month, day;
  int hour, minute, second;
};

typedef int DateTimeFlat[6];

struct URL
{
  char *protocol;
  char **domain;
  int port;
  char *filePath;
  char **queryParams;
  char *fragment;
};

struct DateTime parseDateTime(char *str)
{
  struct DateTime dt;

  sscanf(str, "%i-%i-%i %i:%i:%i", &dt.year, ... &dt.month, &dt.day, &dt.hour, &dt.minute, &dt.second);

  return dt;
}

int main()
{
  "dddd-dd-dd dd:dd:dd";

  struct DateTime d =
      parseDateTime("2024-05-23 07:18:09");
      // {2024, 5, 23, 7, 18, 9}
  printf("%i", d.year);
}
