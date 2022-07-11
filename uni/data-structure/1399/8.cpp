class PNode // Polynomial Node
{
public:
  int power, coefficient;
  PNode *next;
  PNode(int p, int c)
  {
    power = p;
    coefficient = c;
  }
};

PNode *sum(PNode *p1, PNode *p2)
{
  PNode *result = nullptr;
  while (true)
  {
    auto
        c1 = p1 != nullptr,
        c2 = p2 != nullptr;

    if (c1 && c2)
    {
      PNode *newNode;

      if (p1->power > p2->power)
      {
        newNode = new PNode(p1->power, p1->coefficient);
        p1 = p1->next;
      }
      else if (p1->power < p2->power)
      {
        newNode = new PNode(p2->power, p2->coefficient);
        p2 = p2->next;
      }
      else
      {
        newNode = new PNode(p1->power, p1->coefficient + p2->coefficient);
        p1 = p1->next;
        p2 = p2->next;
      }

      result->next = newNode;
    }
    else if (c1)
    {
      auto newNode = new PNode(p1->power, p1->coefficient);
      result->next = newNode;
      p1 = p1->next;
    }
    else if (c2)
    {
      auto newNode = new PNode(p2->power, p2->coefficient);
      result->next = newNode;
      p2 = p2->next;
    }
    else
      break;
  }

  return result;
}
