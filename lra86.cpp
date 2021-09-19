/*
  Copyright (c) 2021, Alexey Frunze
  2-clause BSD license.
*/
#include <string>
#include <vector>
#include <iostream>

#include "check.h"

#define OCO << ", " <<

// Lower this from 6 to 4 to see occasional spills.
#define USE_REGS 6

enum HReg : int
{
  // Specific regs begin
  HReg0, HRegAX = HReg0,
  HReg1, HRegCX = HReg1,
  HReg2, HRegDX = HReg2,
  HReg3, HRegBX = HReg3,
#if USE_REGS >= 5
  HReg4, HRegSI = HReg4,
#endif
#if USE_REGS >= 6
  HReg5, HRegDI = HReg5,
#endif
  // Specific regs end
  HRegCnt,
  // Constants representing multiple-choice desired regs:
  HRegAny = HRegCnt, // unspecified, any reg at all is OK
  HRegNotCX, // prefer regs other than cx (for shifts)
  HRegNotDXNotAX, // prefer regs other than dx and ax (for (i)div)
  HRegNotDXNotCXNotAX, // prefer regs other than dx, cx and ax
  HRegByte, // prefer those with individual byte components: ax, cx, dx, bx
  HRegByteNotCX, // prefer those with individual byte components except cx: ax, dx, bx
  HRegAddr, // prefer those that can be a memory operand: bx, si, di
};

struct Node;
// The only global variables of the allocator.
Node* NodeFromHReg[HRegCnt];
Node* CurrentOutputNode;

// For HRegAny, HRegByte
static const HReg alloc_order_normal[HRegCnt] =
{
  HRegAX, HRegCX, HRegDX, HRegBX,
#if USE_REGS >= 5
  HRegSI,
#endif
#if USE_REGS >= 6
  HRegDI,
#endif
};

// For HRegNotCX
static const HReg alloc_order_not_cx[HRegCnt] =
{
  HRegAX, HRegDX, HRegBX,
#if USE_REGS >= 5
  HRegSI,
#endif
#if USE_REGS >= 6
  HRegDI,
#endif
  HRegCX,
};

// For HRegNotDXNotAX
static const HReg alloc_order_not_dx_not_ax[HRegCnt] =
{
  HRegCX, HRegBX,
#if USE_REGS >= 5
  HRegSI,
#endif
#if USE_REGS >= 6
  HRegDI,
#endif
  HRegAX, HRegDX,
};

// For HRegNotDXNotCXNotAX
static const HReg alloc_order_not_dx_not_cx_not_ax[HRegCnt] =
{
  HRegBX,
#if USE_REGS >= 5
  HRegSI,
#endif
#if USE_REGS >= 6
  HRegDI,
#endif
  HRegAX, HRegCX, HRegDX,
};

// For HRegByteNotCX
static const HReg alloc_order_byte_not_cx[HRegCnt] =
{
  HRegAX, HRegDX, HRegBX, HRegCX,
#if USE_REGS >= 5
  HRegSI,
#endif
#if USE_REGS >= 6
  HRegDI,
#endif
};

// For HRegAddr
static const HReg alloc_order_addr[HRegCnt] =
{
  HRegBX,
#if USE_REGS >= 5
  HRegSI,
#endif
#if USE_REGS >= 6
  HRegDI,
#endif
  HRegAX, HRegCX, HRegDX,
};

const HReg* RegsOrderedForAllocSearch(HReg desired)
{
  const HReg* ordered_regs;
  switch (desired)
  {
  case HRegNotCX:
    ordered_regs = alloc_order_not_cx;
    break;
  case HRegNotDXNotAX:
    ordered_regs = alloc_order_not_dx_not_ax;
    break;
  case HRegNotDXNotCXNotAX:
    ordered_regs = alloc_order_not_dx_not_cx_not_ax;
    break;
  case HRegByteNotCX:
    ordered_regs = alloc_order_byte_not_cx;
    break;
  case HRegAddr:
    ordered_regs = alloc_order_addr;
    break;
  default:
    ordered_regs = alloc_order_normal;
  }
  return ordered_regs;
}

bool SpecificHReg(HReg hr)
{
  return (hr >= HReg0) && (hr < HRegCnt);
}

// Whether the register has 8-bit subregisters.
bool ByteHReg(HReg hr)
{
  switch(hr)
  {
  case HRegAX: case HRegCX: case HRegDX: case HRegBX:
    return true;
  default:
    return false;
  }
}

// Whether the register can be used as a memory address for a load or store.
bool AddrHReg(HReg hr)
{
  switch(hr)
  {
  case HRegBX:
#if USE_REGS >= 5
  case HRegSI:
#endif
#if USE_REGS >= 6
  case HRegDI:
#endif
    return true;
  default:
    return false;
  }
}

std::ostream &operator<<(std::ostream &os, HReg hr)
{
  switch(hr)
  {
  case HRegAX:
    return os << "ax";
  case HRegCX:
    return os << "cx";
  case HRegDX:
    return os << "dx";
  case HRegBX:
    return os << "bx";
#if USE_REGS >= 5
  case HRegSI:
    return os << "si";
#endif
#if USE_REGS >= 6
  case HRegDI:
    return os << "di";
#endif
  default:
    CHECK(0);
    return os << "r?";
  }
}

const char* HRegHi(HReg hr)
{
  switch(hr)
  {
  case HRegAX:
    return "ah";
  case HRegCX:
    return "ch";
  case HRegDX:
    return "dh";
  case HRegBX:
    return "bh";
  default:
    CHECK(0);
    return "?h";
  }
}

const char* HRegLo(HReg hr)
{
  switch(hr)
  {
  case HRegAX:
    return "al";
  case HRegCX:
    return "cl";
  case HRegDX:
    return "dl";
  case HRegBX:
    return "bl";
  default:
    CHECK(0);
    return "?l";
  }
}

struct Node
{
  Node() : Node(nullptr, nullptr) {}
  Node(Node* left) : Node(left, nullptr) {}
  Node(Node* left, Node* right) :
    child_ { left, right },
    first_(-1),
    vr_(-1),
    user_vr_(-1),
    loc_(LocNowhere),
    loc_hr_(HRegAny),
    hr_ { HRegAny, HRegAny, HRegAny },
    val_(0) {}

  virtual ~Node() { delete child_[0]; delete child_[1]; }

  virtual bool IsSymmetric() const { return false; } // some override
  virtual bool PrefersRight() const { return false; } // shifts override
  virtual int MinRegCnt() const { return 0; } // (i)div, (i)rem override
  virtual std::string PrintOperation() const = 0; // all override
  virtual std::string PrintInstruction() const // (i)rem, loads, stores override
  {
    return PrintOperation();
  }

  int SelectFirst();
  void AssignVReg(int vr) { vr_ = vr; }
  void SetUserVReg(int user_vr) { user_vr_ = user_vr; }
  void AssignVRegs(int* p_vr_cnt = nullptr);

  virtual void Eval() = 0; // all override

  virtual void GenMemValue() {} // loads override
  void GenMemValues();

  virtual void GenMemCheck() {} // stores override
  void GenMemChecks();

  void GenRegCheck();

  void SetLocNowhere() { loc_ = LocNowhere; loc_hr_ = HRegAny; }
  void SetLocReg(HReg hr)
  {
    CHECK(SpecificHReg(hr));
    loc_ = LocReg; loc_hr_ = hr;
  }
  void SetLocSpilled() { loc_ = LocSpilled; loc_hr_ = HRegAny; }
  bool IsNowhere() const { return loc_ == LocNowhere; }
  bool InReg() const { return loc_ == LocReg; }
  bool IsSpilled() const { return loc_ == LocSpilled; }

  virtual void AllocHRegs(HReg desired = HRegAny); // some override

  void PrintExprTree(std::ostream& os, int level = 0);
  void PrintInstructions(std::ostream& os);

  Node* child_[2];
  int first_; // which child_[] to handle first to minimize register usage

  int vr_; // "virtual" register holding the output value from this node
  int user_vr_; // vr_ of the parent node that uses this node as input

  enum : int { LocNowhere, LocReg, LocSpilled } loc_; // location of vr_
  HReg loc_hr_; // Register for LocReg

  HReg hr_[3]; // AllocHRegs() sets these

  unsigned short val_; // Expected value in test

  std::vector<std::string> instructions; // Generated instructions
};

// Recursively selects which node to generate code for first
// (sets this->first_ to 0 (left's 1st), 1 (right's 1st) or
// -1 (either can be 1st)), returns the number of registers
// needed for the node.
// This number is known as Ershov number.
// See also Strahler number and Sethi-Ullman algorithm.
int Node::SelectFirst()
{
  if (!child_[0])
  {
    // Leaf.
    return 1;
  }
  int nl = child_[0]->SelectFirst();
  if (!child_[1])
  {
    // Unary.
    return nl;
  }
  // Binary.
  int nr = child_[1]->SelectFirst();
  first_ = (nl == nr) ? -1 : ((nl > nr) ? 0 : 1);
  int lrmax = (nl == nr) ? (nl + 1) : ((nl > nr) ? nl : nr);
  // (i)div uses ax, another register for the divisor and also clobbers dx
  // (not just by way of producing a remainder in dx, but also by requiring
  // the dividend zero- or sign-extended from ax into dx before (i)div,
  // which bars any input (dividend or divisor) from being in dx).
  // That is, (i)div needs at least 3 registers to compute a quotient or
  // remainder regardless of how few registers are needed to compute its
  // dividend and divisor. Otherwise (i)div needs the same number of
  // registers as e.g. add, sub, etc.
  int rmin = MinRegCnt();
  return (lrmax < rmin) ? rmin : lrmax;
}

// Recursively assigns virtual register numbers to this->vr_
// in every node (from the leaves towards the root).
// this->user_vr_ is assigned parent node's vr_.
void Node::AssignVRegs(int* p_vr_cnt)
{
  int vr_cnt = 0;
  p_vr_cnt = p_vr_cnt ? p_vr_cnt : &vr_cnt;
  // Every node gets its own output VReg and
  // that's also the order of evaluation / code generation.
  // Each VReg is used as an input only once.
  if (child_[1])
  {
    // Generally prefer recursing left if all else is equal.
    // For shifts prefer recursing right if all else is equal.
    int first_idx = (PrefersRight()
                     ? (first_ == 0)
                     : (first_ <= 0)) ? 0 : 1;

    child_[first_idx]->AssignVRegs(p_vr_cnt);
    child_[!first_idx]->AssignVRegs(p_vr_cnt);
    // Record where (at which node) inputs are used/consumed.
    child_[first_idx]->SetUserVReg(*p_vr_cnt);
    child_[!first_idx]->SetUserVReg(*p_vr_cnt);
  }
  else if (child_[0])
  {
    child_[0]->AssignVRegs(p_vr_cnt);
    // Record where (at which node) input is used/consumed.
    child_[0]->SetUserVReg(*p_vr_cnt);
  }
  AssignVReg((*p_vr_cnt)++);
  // Unknown location for this VReg for now.
  // Also don't know yet if this output is going to be used/consumed.
  // That is, root's user_vr_ will remain -1.
}

// Free the given hardware register with or without spilling.
void Free(HReg hr, bool spill = false)
{
  CHECK(SpecificHReg(hr));
  Node* n = NodeFromHReg[hr];
  CHECK(n);
  if (spill)
  {
    // N.B. It should be safe to push/pop instead of storing/loading at
    // bp+offset.
    // Reasons:
    // - furthest used VReg won't be needed earlier and won't have a chance to
    //   be mistakenly used earlier
    // - there will not be 2 VRegs spilled that are used by the same
    //   node/instruction because if one VReg has been spilled, the other VReg
    //   at that node/instruction is still being computed in the sibling branch;
    //   this is true for unary and binary operators.
    n->SetLocSpilled();

    std::ostringstream oss;
    oss << "push " << hr;
    CurrentOutputNode->instructions.push_back(oss.str());
  }
  else
  {
    n->SetLocNowhere();
  }
  NodeFromHReg[hr] = nullptr;
}

// Allocate a hardware register to hold the result of the given node.
// May be different from the desired register.
HReg Allocate(Node* n, HReg desired = HRegAny)
{
  CHECK(n);
  int furthest = -1;
  bool spill_needed = true;
#if 01
  for (int hr = 0; hr < HRegCnt; hr++)
    CHECK(NodeFromHReg[hr] != n);
#endif
  if (SpecificHReg(desired) && !NodeFromHReg[desired])
  {
    furthest = desired;
    spill_needed = false;
  }
  else
  {
    const HReg* order = RegsOrderedForAllocSearch(desired);
    for (int i = 0; i < HRegCnt; i++)
    {
      HReg hr = order[i];
      if (!NodeFromHReg[hr])
      {
        furthest = hr;
        spill_needed = false;
        break;
      }
      if (furthest == -1)
        furthest = hr;
      CHECK(NodeFromHReg[furthest]->user_vr_ != -1);
      CHECK(NodeFromHReg[hr]->user_vr_ != -1);
      if (NodeFromHReg[furthest]->user_vr_ < NodeFromHReg[hr]->user_vr_)
        furthest = hr;
    }
  }
  CHECK(furthest != -1);
  HReg hr = HReg(furthest);
  if (spill_needed)
    Free(hr, /*spill*/true);
  n->SetLocReg(hr);
  NodeFromHReg[hr] = n;
  CHECK(SpecificHReg(hr));
  return hr;
}

// Make sure the value of the given node is in a hardware register.
// May be different from the desired register.
HReg Ensure(Node* n, HReg desired = HRegAny)
{
  CHECK(n);
  HReg hr = HRegAny;
  if (n->IsNowhere())
  {
    hr = Allocate(n, desired);
  }
  else if (n->InReg())
  {
    hr = n->loc_hr_;
  }
  else
  {
    CHECK(n->IsSpilled());
    hr = Allocate(n, desired);
    // N.B. It should be safe to push/pop instead of storing/loading at
    // bp+offset.
    // Reasons:
    // - furthest used VReg won't be needed earlier and won't have a chance to
    //   be mistakenly used earlier
    // - there will not be 2 VRegs spilled that are used by the same
    //   node/instruction because if one VReg has been spilled, the other VReg
    //   at that node/instruction is still being computed in the sibling branch;
    //   this is true for unary and binary operators.

    std::ostringstream oss;
    oss << "pop  " << hr;
    CurrentOutputNode->instructions.push_back(oss.str());
  }
  CHECK(SpecificHReg(hr));
  return hr;
}

// When something isn't in the desired HReg,
// move there or exchange.
void MoveToDesired(HReg hr_desired, HReg hr_actual)
{
  CHECK(SpecificHReg(hr_desired));
  CHECK(SpecificHReg(hr_actual));
  CHECK(hr_desired != hr_actual);
  Node* n_desired = NodeFromHReg[hr_desired];
  Node* n_actual = NodeFromHReg[hr_actual];
  CHECK(n_actual);

  std::ostringstream oss;

  if (!n_desired)
  {
    Free(hr_actual);
    HReg hr = Allocate(n_actual, hr_desired);
    CHECK(hr == hr_desired);
    oss << "mov  " << hr_desired OCO hr_actual;
  }
  else
  {
    NodeFromHReg[hr_desired] = n_actual;
    NodeFromHReg[hr_actual] = n_desired;
    n_desired->SetLocReg(hr_actual);
    n_actual->SetLocReg(hr_desired);
    oss << "xchg " << hr_desired OCO hr_actual;
  }

  CurrentOutputNode->instructions.push_back(oss.str());
}

// Commonly used helper for Node::AllocHRegs().
void RecurseToAndEnsureIns(Node* n, const HReg desired[/*1 or 2*/])
{
  CHECK(n->child_[0]);
  bool binary = n->child_[1] != nullptr;

  int first_idx =
    binary ? ((n->child_[0]->vr_ <= n->child_[1]->vr_) ? 0 : 1) : 0;

  n->child_[first_idx]->AllocHRegs(desired[first_idx]);
  if (binary)
    n->child_[!first_idx]->AllocHRegs(desired[!first_idx]);

  CurrentOutputNode = n; // Associate generated instructions with this node.

  n->hr_[first_idx] = Ensure(n->child_[first_idx], desired[first_idx]);
  if (binary)
    n->hr_[!first_idx] = Ensure(n->child_[!first_idx], desired[!first_idx]);
}

// Commonly used helper for Node::AllocHRegs().
void FreeInsAllocOut(Node* n)
{
  CHECK(n->child_[0]);
  bool binary = n->child_[1] != nullptr;

  Free(n->hr_[0]);
  if (binary)
    Free(n->hr_[1]);

  n->hr_[2] = Allocate(n, n->hr_[0]);

  CHECK(n->hr_[2] == n->hr_[0]);
  if (binary)
    CHECK(n->hr_[2] != n->hr_[1]);
}

// Generic implementation of the register allocator.
void Node::AllocHRegs(HReg desired)
{
  HReg desired2[2] = { desired, desired };
  if (child_[1])
  {
    // Binary.
    RecurseToAndEnsureIns(this, desired2);

    // If the operation is symmetric and
    // the desired out register is hr_[1],
    // swap it with hr_[0] so that hr_[0] is in/out.
    if (IsSymmetric() && (hr_[1] == desired))
    {
      hr_[1] = hr_[0];
      hr_[0] = desired;
    }

    FreeInsAllocOut(this);
  }
  else if (child_[0])
  {
    // Unary.
    RecurseToAndEnsureIns(this, desired2);
    FreeInsAllocOut(this);
  }
  else
  {
    // Leaf.
    CurrentOutputNode = this; // Associate generated instructions with this node.
    hr_[2] = Allocate(this, desired);
  }

  std::ostringstream oss;
  if (child_[1])
    oss << PrintInstruction() << ' ' << hr_[2] OCO hr_[1];
  else if (child_[0])
    oss << PrintInstruction() << ' ' << hr_[2];
  else
    oss << "mov  " << hr_[2] OCO PrintInstruction(); // NodeInt
  CurrentOutputNode->instructions.push_back(oss.str());
}

// Generates instructions to set the memory values
// that the expression code will load.
void Node::GenMemValues()
{
  CHECK(vr_ != -1);

  if (child_[1])
  {
    int first_idx = (child_[0]->vr_ <= child_[1]->vr_) ? 0 : 1;
    child_[first_idx]->GenMemValues();
    child_[!first_idx]->GenMemValues();
  }
  else if (child_[0])
  {
    child_[0]->GenMemValues();
  }

  if (!vr_)
    CurrentOutputNode = this;
  CHECK(CurrentOutputNode);
  GenMemValue();
}

// Generates instructions to check the memory values
// that the expression code will store.
void Node::GenMemChecks()
{
  CHECK(vr_ != -1);

  if (child_[1])
  {
    int first_idx = (child_[0]->vr_ <= child_[1]->vr_) ? 0 : 1;
    child_[first_idx]->GenMemChecks();
    child_[!first_idx]->GenMemChecks();
  }
  else if (child_[0])
  {
    child_[0]->GenMemChecks();
  }

  CHECK(CurrentOutputNode);
  CHECK(vr_ <= CurrentOutputNode->vr_);
  GenMemCheck();
}

// Generates instructions to check the register value
// that the expression code will produce for the root node.
void Node::GenRegCheck()
{
  CHECK(CurrentOutputNode);
  std::ostringstream oss, oss2;
  oss << "cmp  " << hr_[2] OCO val_;
  CurrentOutputNode->instructions.push_back(oss.str());
  oss2 << "jne  failure";
  CurrentOutputNode->instructions.push_back(oss2.str());
}

// Prints the expression tree.
void Node::PrintExprTree(std::ostream& os, int level)
{
  if (child_[1])
    child_[1]->PrintExprTree(os, level + 4);

  os << "; " << std::string(level, ' ') << PrintOperation();
  if (vr_ >= 0)
  {
    os << "    (vr" << vr_;
#if 0
    os << "; u@" << n->user_vr_;
#endif
    os << ")";
  }
  os << '\n';

  if (child_[0])
    child_[0]->PrintExprTree(os, level + 4);
}

// Prints all generated instructions.
void Node::PrintInstructions(std::ostream& os)
{
  CHECK(vr_ != -1);
  if (child_[1])
  {
    int first_idx = (child_[0]->vr_ <= child_[1]->vr_) ? 0 : 1;
    child_[first_idx]->PrintInstructions(os);
    child_[!first_idx]->PrintInstructions(os);
  }
  else if (child_[0])
  {
    child_[0]->PrintInstructions(os);
  }
  for (const auto& s : instructions)
  {
    os << "    ";
    os << s;
    os << std::string(28 - s.length(), ' ');
    os << "; vr" << vr_;
    os << '\n';
  }
}

// 16-bit integer (leaf node).
struct NodeInt : Node
{
  NodeInt() = delete;
  NodeInt(unsigned short val) { val_ = val; }
  virtual std::string PrintOperation() const
  {
    std::ostringstream oss;
    oss << val_;
    return oss.str();
  }
  virtual void Eval() {}
};

struct NodeNeg : Node
{
  NodeNeg() = delete;
  NodeNeg(Node* left) : Node(left) {}
  virtual std::string PrintOperation() const { return "neg "; }
  virtual void Eval()
  {
    child_[0]->Eval();
    val_ = -child_[0]->val_;
  }
};

struct NodeNot : Node
{
  NodeNot() = delete;
  NodeNot(Node* left) : Node(left) {}
  virtual std::string PrintOperation() const { return "not "; }
  virtual void Eval()
  {
    child_[0]->Eval();
    val_ = ~child_[0]->val_;
  }
};

// Zero extension from 8 to 16 bits.
struct NodeZext : Node
{
  NodeZext() = delete;
  NodeZext(Node* left) : Node(left) {}
  virtual std::string PrintOperation() const { return "zext "; }
  virtual void Eval()
  {
    child_[0]->Eval();
    val_ = child_[0]->val_ & 0xFF;
  }
  virtual void AllocHRegs(HReg desired)
  {
    child_[0]->AllocHRegs(desired);

    CurrentOutputNode = this; // Associate generated instructions with this node.

    hr_[0] = Ensure(child_[0], desired);

    Free(hr_[0]);
    hr_[2] = Allocate(this, hr_[0]);

    std::ostringstream oss;
    if (ByteHReg(hr_[2]))
      oss << "xor  " << HRegHi(hr_[2]) OCO HRegHi(hr_[2]);
    else
      oss << "and  " << hr_[2] OCO 255;
    CurrentOutputNode->instructions.push_back(oss.str());
  }
};

// Sign extension from 8 to 16 bits.
struct NodeSext : Node
{
  NodeSext() = delete;
  NodeSext(Node* left) : Node(left) {}
  virtual std::string PrintOperation() const { return "sext "; }
  virtual void Eval()
  {
    child_[0]->Eval();
    val_ = child_[0]->val_ & 0xFF;
    val_ -= (val_ & 0x80) << 1;
  }
  virtual void AllocHRegs(HReg desired)
  {
    (void)desired;
    HReg desired2 = HRegAX;
    child_[0]->AllocHRegs(desired2);

    CurrentOutputNode = this; // Associate generated instructions with this node.

    hr_[0] = Ensure(child_[0], desired2);

    if (hr_[0] != desired2)
    {
      MoveToDesired(desired2, hr_[0]);
      hr_[0] = desired2;
    }

    Free(hr_[0]);
    hr_[2] = Allocate(this, hr_[0]);

    CurrentOutputNode->instructions.push_back("cbw");
  }
};

struct NodeAnd : Node
{
  NodeAnd() = delete;
  NodeAnd(Node* left, Node* right) : Node(left, right) {}
  virtual bool IsSymmetric() const { return true; }
  virtual std::string PrintOperation() const { return "and "; }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    val_ = child_[0]->val_ & child_[1]->val_;
  }
};

struct NodeOr : Node
{
  NodeOr() = delete;
  NodeOr(Node* left, Node* right) : Node(left, right) {}
  virtual bool IsSymmetric() const { return true; }
  virtual std::string PrintOperation() const { return "or  "; }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    val_ = child_[0]->val_ | child_[1]->val_;
  }
};

struct NodeXor : Node
{
  NodeXor() = delete;
  NodeXor(Node* left, Node* right) : Node(left, right) {}
  virtual bool IsSymmetric() const { return true; }
  virtual std::string PrintOperation() const { return "xor "; }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    val_ = child_[0]->val_ ^ child_[1]->val_;
  }
};

struct NodeAdd : Node
{
  NodeAdd() = delete;
  NodeAdd(Node* left, Node* right) : Node(left, right) {}
  virtual bool IsSymmetric() const { return true; }
  virtual std::string PrintOperation() const { return "add "; }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    val_ = child_[0]->val_ + child_[1]->val_;
  }
};

struct NodeSub : Node
{
  NodeSub() = delete;
  NodeSub(Node* minuend, Node* subtrahend) : Node(minuend, subtrahend) {}
  virtual std::string PrintOperation() const { return "sub "; }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    val_ = child_[0]->val_ - child_[1]->val_;
  }
};

void AllocHRegs_ShiftX(Node* n, HReg desired)
{
  HReg (&hr_)[3] = n->hr_;

  // Simulate the shl instruction requiring
  // its right input in HRegCX.
  HReg desired2[2] = { desired, HRegCX };
  switch (desired)
  {
  case HRegAX:
  case HRegDX:
  case HRegBX:
#if USE_REGS >= 5
  case HRegSI:
#endif
#if USE_REGS >= 6
  case HRegDI:
#endif
  case HRegNotCX:
  case HRegNotDXNotCXNotAX:
  case HRegByteNotCX:
  case HRegAddr:
    break;
  case HRegCX:
  case HRegAny:
    desired2[0] = HRegNotCX;
    break;
  case HRegNotDXNotAX:
    desired2[0] = HRegNotDXNotCXNotAX;
    break;
  case HRegByte:
    desired2[0] = HRegByteNotCX;
    break;
  default:
    CHECK(0);
    break;
  }

  // N.B. For shifts we prefer recursing right if all else is equal.
  // The idea is to get HRegCX for the count operand ASAP.
  RecurseToAndEnsureIns(n, desired2);

  if (hr_[1] != desired2[1])
  {
    MoveToDesired(desired2[1], hr_[1]);
    if (hr_[0] == desired2[1])
      hr_[0] = hr_[1];
    hr_[1] = desired2[1];
  }

  FreeInsAllocOut(n);

  std::ostringstream oss;
  oss << n->PrintInstruction() << ' ' << hr_[2] OCO HRegLo(hr_[1]);
  CurrentOutputNode->instructions.push_back(oss.str());
}

// Shift left.
struct NodeShLft : Node
{
  NodeShLft() = delete;
  NodeShLft(Node* value, Node* count) : Node(value, count) {}
  virtual bool PrefersRight() const { return true; }
  virtual std::string PrintOperation() const { return "shl "; }
  virtual void AllocHRegs(HReg desired) { AllocHRegs_ShiftX(this, desired); }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    val_ = child_[0]->val_ << (child_[1]->val_ & 0xF);
  }
};

// Logical shift right.
struct NodeShRht : Node
{
  NodeShRht() = delete;
  NodeShRht(Node* value, Node* count) : Node(value, count) {}
  virtual bool PrefersRight() const { return true; }
  virtual std::string PrintOperation() const { return "shr "; }
  virtual void AllocHRegs(HReg desired) { AllocHRegs_ShiftX(this, desired); }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    val_ = child_[0]->val_ >> (child_[1]->val_ & 0xF);
  }
};

// Arithmetic/sign-extending shift right.
struct NodeShArRht : Node
{
  NodeShArRht() = delete;
  NodeShArRht(Node* value, Node* count) : Node(value, count) {}
  virtual bool PrefersRight() const { return true; }
  virtual std::string PrintOperation() const { return "sar "; }
  virtual void AllocHRegs(HReg desired) { AllocHRegs_ShiftX(this, desired); }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    unsigned short sign = -(child_[0]->val_ >> 15);
    int count = child_[1]->val_ & 0xF;
    val_ = child_[0]->val_ >> count;
    val_ |= (unsigned)sign << (15 - count) << 1;
  }
};

// Mul works for both signed and unsigned values.
struct NodeMul : Node
{
  NodeMul() = delete;
  NodeMul(Node* left, Node* right) : Node(left, right) {}
  virtual bool IsSymmetric() const { return true; }
  virtual std::string PrintOperation() const { return "mul "; }
  virtual void AllocHRegs(HReg desired)
  {
    // Simulate the mul instruction requiring its
    // output and one of its inputs in HRegAX.
    desired = HRegAX;
    HReg desired1[2] = { HRegAX, HRegAX };

    RecurseToAndEnsureIns(this, desired1);
    bool swapped = (hr_[1] == desired);

    // Also simulate modification of HRegDX (or, rather, avoid trashing
    // something useful in HRegDX; mul modifies it).
    // If HRegDX holds some value, swap HRegDX with the HReg holding
    // the right multiplicand (N.B. the left is in HRegAX).
    // The right multiplicand can be HRegDX and isn't needed after mul.
    HReg desired2 = HRegDX;
    bool has_ax = (hr_[0] == desired) || (hr_[1] == desired);
    bool has_dx = (hr_[0] == desired2) || (hr_[1] == desired2);
    bool need_to_save_dx = !has_dx && NodeFromHReg[desired2];
    //
    //  ax  dx  nothing
    //  dx  ax    ditto
    //  ax !dx  possibly preserve dx by swapping !dx with dx
    // !dx  ax    ditto
    // !ax  dx  swap !ax with ax
    //  dx !ax    ditto
    // !ax !dx  swap !ax with ax; possibly preserve dx by swapping !dx with dx
    // !dx !ax    ditto
    //
    if (!has_ax)
    {
      bool idx = (hr_[0] == desired2);
      MoveToDesired(desired, hr_[int(idx)]);
      hr_[idx] = desired;
      swapped = idx;
    }
    // The operation is symmetric, so,
    // if the desired out register is hr_[1],
    // swap it with hr_[0] so that hr_[0] is in/out.
    if (swapped)
    {
      HReg t = hr_[1];
      hr_[1] = hr_[0];
      hr_[0] = t;
    }
    CHECK(hr_[0] == desired);
    if (need_to_save_dx)
    {
      MoveToDesired(desired2, hr_[1]);
      hr_[1] = desired2;
    }
    CHECK((hr_[1] == desired2) || !NodeFromHReg[desired2]);

    FreeInsAllocOut(this);

    std::ostringstream oss;
    oss << PrintInstruction() << ' ' << hr_[1];
    CurrentOutputNode->instructions.push_back(oss.str());
  }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    val_ = (unsigned long)child_[0]->val_ * child_[1]->val_;
  }
};

void AllocHRegs_DivRemX(Node* n, bool rem_not_div, bool signed_)
{
  HReg (&hr_)[3] = n->hr_;

  // Simulate the idiv instruction requiring its
  // output and its left input in HRegAX.
  HReg desired2[2] = { HRegAX, HRegNotDXNotAX };

  RecurseToAndEnsureIns(n, desired2);

  if (hr_[0] != desired2[0])
  {
    MoveToDesired(desired2[0], hr_[0]);
    if (hr_[1] == desired2[0])
      hr_[1] = hr_[0];
    hr_[0] = desired2[0];
  }
  CHECK(hr_[0] == desired2[0]);

  // Also simulate modification of HRegDX
  // (or, rather, avoid trashing something useful in HRegDX;
  // (i)div's user must modify dx before (i)div).
  //
  //  ax  dx  alloc tmp and move dx there, div by tmp
  //  ax !dx  possibly alloc tmp and move dx there, div by right
  //
  HReg undesired = HRegDX;
  if ((hr_[1] == undesired) || NodeFromHReg[undesired])
  {
    HReg t = Allocate(n); // This is a temp HReg.
    Free(t); // And it is free now.
    MoveToDesired(t, undesired); // This finally frees up HRegDX.
    if (hr_[1] == undesired)
      hr_[1] = t;
  }
  CHECK(hr_[1] != undesired);
  CHECK(!NodeFromHReg[undesired]);
  if (rem_not_div)
  {
    Free(hr_[0]);
    hr_[0] = Allocate(n, undesired);
    CHECK(hr_[0] == undesired);
  }

  FreeInsAllocOut(n);

  {
    std::ostringstream oss;
    // This is what would trash HRegDX.
    if (signed_)
      oss << "cwd";
    else
      oss << "xor  " << undesired OCO undesired;
    CurrentOutputNode->instructions.push_back(oss.str());
  }
  {
    std::ostringstream oss;
    oss << n->PrintInstruction() << ' ' << hr_[1];
    CurrentOutputNode->instructions.push_back(oss.str());
  }
}

// Signed division.
struct NodeIDiv : Node
{
  NodeIDiv() = delete;
  NodeIDiv(Node* dividend, Node* divisor) : Node(dividend, divisor) {}
  virtual int MinRegCnt() const { return 3; } // HRegDX is clobbered early.
  virtual std::string PrintOperation() const { return "idiv"; }
  virtual void AllocHRegs(HReg desired)
  {
    (void)desired;
    AllocHRegs_DivRemX(this, /*rem_not_div*/false, /*signed_*/true);
  }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    unsigned short dividend = child_[0]->val_;
    unsigned short divisor = child_[1]->val_;
    CHECK(divisor);
    CHECK((dividend != 0x8000) || (divisor != 0xFFFF));
    bool neg = false;
    if (dividend & 0x8000)
    {
      dividend = -dividend;
      neg = true;
    }
    if (divisor & 0x8000)
    {
      divisor = -divisor;
      neg = !neg;
    }
    val_ = dividend / divisor;
    val_ = neg ? -val_ : val_;
  }
};

// Signed remainder.
struct NodeIRem : Node
{
  NodeIRem() = delete;
  NodeIRem(Node* dividend, Node* divisor) : Node(dividend, divisor) {}
  virtual int MinRegCnt() const { return 3; } // HRegDX is clobbered early.
  virtual std::string PrintOperation() const { return "irem"; }
  virtual std::string PrintInstruction() const { return "idiv"; }
  virtual void AllocHRegs(HReg desired)
  {
    (void)desired;
    AllocHRegs_DivRemX(this, /*rem_not_div*/true, /*signed_*/true);
  }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    unsigned short dividend = child_[0]->val_;
    unsigned short divisor = child_[1]->val_;
    CHECK(divisor);
    CHECK((dividend != 0x8000) || (divisor != 0xFFFF));
    bool neg = false;
    if (dividend & 0x8000)
    {
      dividend = -dividend;
      neg = true;
    }
    if (divisor & 0x8000)
      divisor = -divisor;
    val_ = dividend % divisor;
    val_ = neg ? -val_ : val_;
  }
};

// Unsigned division.
struct NodeDiv : Node
{
  NodeDiv() = delete;
  NodeDiv(Node* dividend, Node* divisor) : Node(dividend, divisor) {}
  virtual int MinRegCnt() const { return 3; } // HRegDX is clobbered early.
  virtual std::string PrintOperation() const { return "div "; }
  virtual void AllocHRegs(HReg desired)
  {
    (void)desired;
    AllocHRegs_DivRemX(this, /*rem_not_div*/false, /*signed_*/false);
  }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    CHECK(child_[1]->val_);
    val_ = child_[0]->val_ / child_[1]->val_;
  }
};

// Unsigned remainder.
struct NodeRem : Node
{
  NodeRem() = delete;
  NodeRem(Node* dividend, Node* divisor) : Node(dividend, divisor) {}
  virtual int MinRegCnt() const { return 3; } // HRegDX is clobbered early.
  virtual std::string PrintOperation() const { return "rem "; }
  virtual std::string PrintInstruction() const { return "div "; }
  virtual void AllocHRegs(HReg desired)
  {
    (void)desired;
    AllocHRegs_DivRemX(this, /*rem_not_div*/true, /*signed_*/false);
  }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    CHECK(child_[1]->val_);
    val_ = child_[0]->val_ % child_[1]->val_;
  }
};

enum LoadKind : int
{
  LoadKindWord,
  LoadKindByte, // not extended to 16 bits: top 8 bits are undefined
  LoadKindByteSignExtended,
  LoadKindByteZeroExtended
};

// Helper for loads from memory into a register.
void AllocHRegs_LoadX(Node* n, HReg desired, LoadKind kind)
{
  HReg (&hr_)[3] = n->hr_;
  Node* (&child_)[2] = n->child_;

  child_[0]->AllocHRegs(HRegAddr);

  CurrentOutputNode = n; // Associate generated instructions with this node.

  hr_[0] = Ensure(child_[0], HRegAddr);

  if (!AddrHReg(hr_[0]))
  {
    HReg t = HRegBX;
    MoveToDesired(t, hr_[0]);
    hr_[0] = t;
  }
  CHECK(AddrHReg(hr_[0]));

  Free(hr_[0]);
  if (kind == LoadKindWord)
  {
    HReg desired2 = hr_[0];
    switch (desired)
    {
    case HRegAX:
    case HRegCX:
    case HRegDX:
    case HRegBX:
#if USE_REGS >= 5
    case HRegSI:
#endif
#if USE_REGS >= 6
    case HRegDI:
#endif
      if (!NodeFromHReg[desired])
        desired2 = desired;
      break;
    case HRegAny:
    case HRegAddr:
    case HRegNotCX:
    case HRegNotDXNotAX:
    case HRegNotDXNotCXNotAX:
      break;
    case HRegByte:
    case HRegByteNotCX:
      desired2 = desired;
      break;
    default:
      CHECK(0);
      break;
    }
    hr_[2] = Allocate(n, desired2);
  }
  else
  {
    if (kind == LoadKindByteSignExtended)
    {
      HReg desired2 = HRegAX;
      hr_[2] = Allocate(n, desired2);
      if (hr_[2] != desired2)
      {
        Free(hr_[2]); // This is a free/temp HReg.
        MoveToDesired(hr_[2], desired2); // This frees up HRegAX.
        CHECK(!NodeFromHReg[desired2]);
        hr_[2] = Allocate(n, desired2); // We can now use HRegAX.
      }
      CHECK(hr_[2] == desired2);
    }
    else
    {
      HReg desired2 = HRegByte;
      switch (desired)
      {
      case HRegAX:
      case HRegCX:
      case HRegDX:
      case HRegBX:
        if (!NodeFromHReg[desired])
          desired2 = desired;
        break;
#if USE_REGS >= 5
      case HRegSI:
#endif
#if USE_REGS >= 6
      case HRegDI:
#endif
      case HRegAny:
      case HRegByte:
        if (ByteHReg(hr_[0]))
          desired2 = hr_[0];
        break;
      case HRegNotCX:
      case HRegByteNotCX:
        desired2 = HRegByteNotCX;
        break;
      case HRegNotDXNotAX:
        if (!NodeFromHReg[HRegCX])
          desired2 = HRegCX;
        else if (!NodeFromHReg[HRegBX])
          desired2 = HRegBX;
        break;
      case HRegNotDXNotCXNotAX:
      case HRegAddr:
        if (!NodeFromHReg[HRegBX])
          desired2 = HRegBX;
        break;
      default:
        CHECK(0);
        break;
      }
      hr_[2] = Allocate(n, desired2);
      if (!ByteHReg(hr_[2]))
      {
        desired2 = HRegAX;
        Free(hr_[2]); // This is a free/temp HReg.
        MoveToDesired(hr_[2], desired2); // This frees up HRegAX.
        CHECK(!NodeFromHReg[desired2]);
        hr_[2] = Allocate(n, desired2); // We can now use HRegAX.
        CHECK(hr_[2] == desired2);
      }
    }
    CHECK(ByteHReg(hr_[2]));
  }

  std::ostringstream oss, oss2;
  if (kind == LoadKindWord)
    oss << n->PrintInstruction()
        << ' ' << hr_[2] OCO '[' << hr_[0] << ']';
  else
    oss << n->PrintInstruction()
        << ' ' << HRegLo(hr_[2]) OCO '[' << hr_[0] << ']';
  CurrentOutputNode->instructions.push_back(oss.str());

  if ((kind == LoadKindByteSignExtended) ||
      (kind == LoadKindByteZeroExtended))
  {
    if (kind == LoadKindByteSignExtended)
      oss2 << "cbw";
    else
      oss2 << "xor  " << HRegHi(hr_[2]) OCO HRegHi(hr_[2]);
    CurrentOutputNode->instructions.push_back(oss2.str());
  }
}

// Loads 16 bits from memory.
struct NodeLw : Node
{
  NodeLw() = delete;
  NodeLw(unsigned short test_val, Node* address) : Node(address)
  {
    val_ = test_val;
  }
  virtual std::string PrintOperation() const { return "lw  "; }
  virtual std::string PrintInstruction() const { return "mov "; }
  virtual void AllocHRegs(HReg desired)
  {
    AllocHRegs_LoadX(this, desired, LoadKindWord);
  }
  virtual void Eval()
  {
    child_[0]->Eval();
  }
  virtual void GenMemValue()
  {
    std::ostringstream oss;
    oss << "mov  word [" << child_[0]->val_ << "]" OCO val_;
    CurrentOutputNode->instructions.push_back(oss.str());
  }
};

// Loads 8 bits from memory, doesn't extend to 16 bits.
struct NodeLb : Node
{
  NodeLb() = delete;
  NodeLb(unsigned short test_val, Node* address) : Node(address)
  {
    val_ = test_val & 0xFF;
  }
  virtual std::string PrintOperation() const { return "lb  "; }
  virtual std::string PrintInstruction() const { return "mov "; }
  virtual void AllocHRegs(HReg desired)
  {
    AllocHRegs_LoadX(this, desired, LoadKindByte);
  }
  virtual void Eval()
  {
    child_[0]->Eval();
  }
  virtual void GenMemValue()
  {
    std::ostringstream oss;
    oss << "mov  byte [" << child_[0]->val_ << "]" OCO (val_ & 0xFF);
    CurrentOutputNode->instructions.push_back(oss.str());
  }
};

// Loads 8 bits from memory, sign-extends to 16 bits.
struct NodeLbs : Node
{
  NodeLbs() = delete;
  NodeLbs(unsigned short test_val, Node* address) : Node(address)
  {
    CHECK(!(test_val >> 7) || ((test_val >> 7) == 0x1FF));
    val_ = test_val;
  }
  virtual std::string PrintOperation() const { return "lbs "; }
  virtual std::string PrintInstruction() const { return "mov "; }
  virtual void AllocHRegs(HReg desired)
  {
    AllocHRegs_LoadX(this, desired, LoadKindByteSignExtended);
  }
  virtual void Eval()
  {
    child_[0]->Eval();
  }
  virtual void GenMemValue()
  {
    std::ostringstream oss;
    oss << "mov  byte [" << child_[0]->val_ << "]" OCO (val_ & 0xFF);
    CurrentOutputNode->instructions.push_back(oss.str());
  }
};

// Loads 8 bits from memory, zero-extends to 16 bits.
struct NodeLbz : Node
{
  NodeLbz() = delete;
  NodeLbz(unsigned short test_val, Node* address) : Node(address)
  {
    CHECK(test_val <= 0xFF);
    val_ = test_val;
  }
  virtual std::string PrintOperation() const { return "lbz "; }
  virtual std::string PrintInstruction() const { return "mov "; }
  virtual void AllocHRegs(HReg desired)
  {
    AllocHRegs_LoadX(this, desired, LoadKindByteZeroExtended);
  }
  virtual void Eval()
  {
    child_[0]->Eval();
  }
  virtual void GenMemValue()
  {
    std::ostringstream oss;
    oss << "mov  byte [" << child_[0]->val_ << "]" OCO (val_ & 0xFF);
    CurrentOutputNode->instructions.push_back(oss.str());
  }
};

enum StoreKind : int
{
  StoreKindWord,
  StoreKindByte
};

// Helper for stores to memory from a register.
void AllocHRegs_StoreX(Node* n, HReg desired, StoreKind kind)
{
  HReg (&hr_)[3] = n->hr_;

  HReg desired2[2] = { desired, HRegAddr };
  if (kind == StoreKindByte)
  {
    switch (desired)
    {
    case HRegAX:
    case HRegCX:
    case HRegDX:
    case HRegBX:
      break;
#if USE_REGS >= 5
    case HRegSI:
#endif
#if USE_REGS >= 6
    case HRegDI:
#endif
    case HRegAny:
    case HRegAddr:
    case HRegByte:
      desired2[0] = HRegByte;
      break;
    case HRegNotCX:
    case HRegByteNotCX:
      desired2[0] = HRegByteNotCX;
      break;
    case HRegNotDXNotAX:
      desired2[0] = HRegCX;
      break;
    case HRegNotDXNotCXNotAX:
      desired2[0] = HRegBX;
      break;
    default:
      CHECK(0);
      break;
    }
  }

  RecurseToAndEnsureIns(n, desired2);

  if (!AddrHReg(hr_[1]))
  {
    desired2[1] = HRegBX;
    MoveToDesired(desired2[1], hr_[1]);
    if (hr_[0] == desired2[1])
      hr_[0] = hr_[1];
    hr_[1] = desired2[1];
  }
  CHECK(AddrHReg(hr_[1]));

  if (kind == StoreKindByte)
  {
    if (!ByteHReg(hr_[0]))
    {
      desired2[0] = HRegAX;
      MoveToDesired(desired2[0], hr_[0]);
      CHECK(hr_[1] != desired2[0]);
      hr_[0] = desired2[0];
    }
    CHECK(ByteHReg(hr_[0]));
  }

  FreeInsAllocOut(n);

  std::ostringstream oss;
  if (kind == StoreKindWord)
    oss << n->PrintInstruction()
        << " [" << hr_[1] << "]" OCO hr_[2];
  else
    oss << n->PrintInstruction()
        << " [" << hr_[1] << "]" OCO HRegLo(hr_[2]);
  CurrentOutputNode->instructions.push_back(oss.str());
}

// Stores 16 bits to memory.
struct NodeSw : Node
{
  NodeSw() = delete;
  NodeSw(Node* value, Node* address) : Node(value, address) {}
  virtual std::string PrintOperation() const { return "sw  "; }
  virtual std::string PrintInstruction() const { return "mov "; }
  virtual void AllocHRegs(HReg desired)
  {
    AllocHRegs_StoreX(this, desired, StoreKindWord);
  }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    val_ = child_[0]->val_;
  }
  virtual void GenMemCheck()
  {
    std::ostringstream oss, oss2;
    oss << "cmp  word [" << child_[1]->val_ << "]" OCO val_;
    CurrentOutputNode->instructions.push_back(oss.str());
    oss2 << "jne  failure";
    CurrentOutputNode->instructions.push_back(oss2.str());
  }
};

// Stores 8 bits to memory.
struct NodeSb : Node
{
  NodeSb() = delete;
  NodeSb(Node* value, Node* address) : Node(value, address) {}
  virtual std::string PrintOperation() const { return "sb  "; }
  virtual std::string PrintInstruction() const { return "mov "; }
  virtual void AllocHRegs(HReg desired)
  {
    AllocHRegs_StoreX(this, desired, StoreKindByte);
  }
  virtual void Eval()
  {
    child_[0]->Eval();
    child_[1]->Eval();
    val_ = child_[0]->val_;
  }
  virtual void GenMemCheck()
  {
    std::ostringstream oss, oss2;
    oss << "cmp  byte [" << child_[1]->val_ << "]" OCO (val_ & 0xFF);
    CurrentOutputNode->instructions.push_back(oss.str());
    oss2 << "jne  failure";
    CurrentOutputNode->instructions.push_back(oss2.str());
  }
};

void Run(Node* n)
{
  std::cout << '\n';

  // Reinitialize the globals.
  for (int hr = 0; hr < HRegCnt; hr++)
    NodeFromHReg[hr] = nullptr;
  CurrentOutputNode = nullptr;

  // Preprocess the expression tree.
  int regs_needed = n->SelectFirst();
  n->AssignVRegs();

  // Print the expression tree.
  n->PrintExprTree(std::cout);
  std::cout << "; ----\n";
  std::cout << "; Regs needed (approximately): " << regs_needed << '\n';
  std::cout << "; --------\n";

  // Evaluate the expression and generate instructions to
  // initialize input memory values.
  n->Eval();
  CHECK(!CurrentOutputNode);
  n->GenMemValues();
  CHECK(CurrentOutputNode);
  CurrentOutputNode->instructions.push_back(";");

  // Allocate hardware registers and generate code
  // for the expression tree.
#if 01
  n->AllocHRegs();
#else
  // If needed, we may force the result into a specific register.
  HReg desired = HRegAX;
  n->AllocHRegs(desired);
  if (SpecificHReg(desired) && (n->hr_[2] != desired))
  {
    MoveToDesired(desired, n->hr_[2]);
    n->hr_[2] = desired;
  }
#endif
  // Some more sanity checks.
  HReg out_reg = n->hr_[2];
  CHECK(SpecificHReg(out_reg));
  for (int hr = 0; hr < out_reg; hr++)
    CHECK(!NodeFromHReg[hr]);
  for (int hr = out_reg + 1; hr < HRegCnt; hr++)
    CHECK(!NodeFromHReg[hr]);
  CHECK(NodeFromHReg[out_reg] == n);

  // Generate register and memory checks.
  CHECK(CurrentOutputNode == n);
  CurrentOutputNode->instructions.push_back(";");
  n->GenRegCheck();
  n->GenMemChecks();

  // Print generated instructions.
  n->PrintInstructions(std::cout);

  delete n;
}

int main()
{
  std::cout << "; Compile this file with nasm:\n"
               ";   nasm file.asm -o file.com\n"
               "; Run file.com in DOS, 32-bit Windows or DOSBox.\n\n";

  std::cout << "bits 16\ncpu 8086\norg 0x100\n\n";

  std::cout << "; Shrink/extend the PSP block to 64KB.\n"
               "    mov  ah, 0x4a\n"
               "    mov  bx, 4096\n"
               "    int  0x21\n"
               "    jc   no_memory\n"
               "    mov  sp, 0 ; stack at end of 64KB block\n";

  Run(new NodeInt(5));
  Run(new NodeNeg(new NodeInt(7)));
  Run(new NodeNot(new NodeInt(7)));

  Run(new NodeAdd(new NodeInt(3), new NodeInt(4)));
  Run(new NodeXor(new NodeAnd(new NodeInt(1), new NodeInt(3)),
                  new NodeOr(new NodeInt(2), new NodeInt(4))));

  Run(new NodeAdd(new NodeInt(2), new NodeMul(new NodeInt(3), new NodeInt(5))));
  Run(new NodeAdd(new NodeMul(new NodeInt(2), new NodeInt(3)),
                  new NodeMul(new NodeInt(5), new NodeInt(7))));
  Run(new NodeAdd(
    new NodeAdd(new NodeAdd(new NodeAdd(new NodeInt(1), new NodeInt(2)),
                            new NodeAdd(new NodeInt(3), new NodeInt(4))),
                new NodeAdd(new NodeAdd(new NodeInt(5), new NodeInt(6)),
                            new NodeAdd(new NodeInt(7), new NodeInt(8)))),
    new NodeAdd(new NodeAdd(new NodeAdd(new NodeInt(9), new NodeInt(10)),
                            new NodeAdd(new NodeInt(11), new NodeInt(12))),
                new NodeAdd(new NodeAdd(new NodeInt(13), new NodeInt(14)),
                            new NodeAdd(new NodeInt(15), new NodeInt(16))))
  ));
  Run(new NodeSub(
    new NodeSub(new NodeSub(new NodeSub(new NodeInt(1), new NodeInt(2)),
                            new NodeSub(new NodeInt(3), new NodeInt(4))),
                new NodeSub(new NodeSub(new NodeInt(5), new NodeInt(6)),
                            new NodeSub(new NodeInt(7), new NodeInt(8)))),
    new NodeSub(new NodeSub(new NodeSub(new NodeInt(9), new NodeInt(10)),
                            new NodeSub(new NodeInt(11), new NodeInt(12))),
                new NodeSub(new NodeSub(new NodeInt(13), new NodeInt(14)),
                            new NodeSub(new NodeInt(15), new NodeInt(16))))
  ));

  Run(new NodeMul(new NodeInt(2),
                  new NodeMul(new NodeInt(3),
                              new NodeMul(new NodeInt(4), new NodeInt(5)))));
  Run(new NodeMul(new NodeAdd(new NodeMul(new NodeInt(1), new NodeInt(2)),
                              new NodeMul(new NodeInt(3), new NodeInt(4))),
                  new NodeAdd(new NodeMul(new NodeInt(5), new NodeInt(6)),
                              new NodeMul(new NodeInt(7), new NodeInt(8)))));
  Run(new NodeShLft(new NodeInt(4), new NodeInt(3)));
  Run(new NodeShRht(new NodeInt(63), new NodeInt(3)));
  Run(new NodeShArRht(new NodeInt(-57), new NodeInt(3)));
  Run(new NodeShLft(new NodeShLft(new NodeInt(4), new NodeInt(3)),
                    new NodeInt(5)));
  Run(new NodeShLft(new NodeInt(5),
                    new NodeShLft(new NodeInt(4), new NodeInt(3))));
  Run(new NodeMul(new NodeInt(3),
                  new NodeShLft(new NodeInt(1), new NodeInt(2))));
  Run(new NodeShLft(new NodeMul(new NodeInt(1), new NodeInt(2)),
                    new NodeInt(3)));
  Run(new NodeShLft(new NodeInt(3),
                    new NodeMul(new NodeInt(1), new NodeInt(2))));
  Run(new NodeShLft(new NodeMul(new NodeInt(1), new NodeInt(2)),
                    new NodeMul(new NodeInt(3), new NodeInt(4))));
  Run(new NodeMul(new NodeShLft(new NodeInt(1), new NodeInt(2)),
                  new NodeShLft(new NodeInt(3), new NodeInt(4))));
  Run(new NodeShLft(new NodeAdd(new NodeInt(1), new NodeInt(2)),
                    new NodeAdd(new NodeInt(3), new NodeInt(4))));
  Run(new NodeMul(
    new NodeMul(new NodeAdd(new NodeMul(new NodeInt(1), new NodeInt(2)),
                            new NodeMul(new NodeInt(3), new NodeInt(4))),
                new NodeAdd(new NodeMul(new NodeInt(5), new NodeInt(6)),
                            new NodeMul(new NodeInt(7), new NodeInt(8)))),
    new NodeMul(new NodeAdd(new NodeMul(new NodeInt(9), new NodeInt(10)),
                            new NodeMul(new NodeInt(11), new NodeInt(12))),
                new NodeAdd(new NodeMul(new NodeInt(13), new NodeInt(14)),
                            new NodeMul(new NodeInt(15), new NodeInt(16))))
  ));
  Run(new NodeMul(
    new NodeMul(new NodeSub(new NodeMul(new NodeInt(1), new NodeInt(2)),
                            new NodeMul(new NodeInt(3), new NodeInt(4))),
                new NodeSub(new NodeMul(new NodeInt(5), new NodeInt(6)),
                            new NodeMul(new NodeInt(7), new NodeInt(8)))),
    new NodeMul(new NodeSub(new NodeMul(new NodeInt(9), new NodeInt(10)),
                            new NodeMul(new NodeInt(11), new NodeInt(12))),
                new NodeSub(new NodeMul(new NodeInt(13), new NodeInt(14)),
                            new NodeMul(new NodeInt(15), new NodeInt(16))))
  ));

  Run(new NodeIDiv(new NodeInt(-8), new NodeInt(3)));
  Run(new NodeIDiv(new NodeInt(8), new NodeInt(-3)));
  Run(new NodeDiv(new NodeInt(8), new NodeInt(3)));
  Run(new NodeIDiv(new NodeIDiv(new NodeInt(3*4*5), new NodeInt(-5)),
                   new NodeInt(4)));
  Run(new NodeIDiv(new NodeInt(-3*4*5),
                   new NodeIDiv(new NodeInt(3*4*5), new NodeInt(-4))));
  Run(new NodeIDiv(new NodeInt(2*3*5*7),
                   new NodeIDiv(new NodeInt(2*3*5),
                                new NodeIDiv(new NodeInt(2*5),
                                             new NodeInt(2)))));
  Run(new NodeIDiv(new NodeIDiv(new NodeIDiv(new NodeInt(-2*3*5*7),
                                             new NodeInt(7)),
                                new NodeInt(5)),
                   new NodeInt(3)));
  Run(new NodeIDiv(new NodeAdd(new NodeIDiv(new NodeInt(2*7), new NodeInt(2)),
                               new NodeIDiv(new NodeInt(3*5), new NodeInt(3))),
                   new NodeAdd(new NodeIDiv(new NodeInt(2*3), new NodeInt(3)),
                               new NodeIDiv(new NodeInt(2*11),
                                            new NodeInt(11)))));
  Run(new NodeIDiv(new NodeInt(3*4),
                   new NodeShLft(new NodeInt(-1), new NodeInt(2))));
  Run(new NodeShLft(new NodeIDiv(new NodeInt(2*3), new NodeInt(3)),
                    new NodeInt(10)));
  Run(new NodeShLft(new NodeInt(2),
                    new NodeIDiv(new NodeInt(-5*7), new NodeInt(-7))));
  Run(new NodeShLft(new NodeIDiv(new NodeInt(9), new NodeInt(3)),
                    new NodeIDiv(new NodeInt(8), new NodeInt(4))));
  Run(new NodeIDiv(new NodeShLft(new NodeInt(-2*3*5), new NodeInt(5)),
                   new NodeShLft(new NodeInt(2*3*5), new NodeInt(3))));

  Run(new NodeIRem(new NodeInt(5), new NodeInt(3)));
  Run(new NodeIRem(new NodeInt(-5), new NodeInt(3)));
  Run(new NodeIRem(new NodeInt(5), new NodeInt(-3)));
  Run(new NodeIRem(new NodeInt(-5), new NodeInt(-3)));
  Run(new NodeRem(new NodeInt(5), new NodeInt(3)));
  Run(new NodeIRem(new NodeInt(7),
                   new NodeShLft(new NodeInt(1), new NodeInt(2))));
  Run(new NodeShLft(new NodeIRem(new NodeInt(1), new NodeInt(2)),
                    new NodeInt(3)));
  Run(new NodeShLft(new NodeInt(-3),
                    new NodeIRem(new NodeInt(1), new NodeInt(2))));
  Run(new NodeShLft(new NodeIRem(new NodeInt(1), new NodeInt(2)),
                    new NodeIRem(new NodeInt(3), new NodeInt(4))));
  Run(new NodeIRem(new NodeShLft(new NodeInt(1), new NodeInt(2)),
                   new NodeShLft(new NodeInt(3), new NodeInt(4))));

  Run(new NodeAdd(new NodeInt(1000), new NodeLw(-1, new NodeInt(32768))));
  Run(new NodeShLft(new NodeInt(123),
                    new NodeLw(32768,
                               new NodeLw(32768, new NodeInt(32768)))));
  Run(new NodeSw(new NodeInt(12345), new NodeInt(40000)));
  Run(new NodeSw(new NodeLw(54321, new NodeInt(32768)), new NodeInt(40000)));
  Run(new NodeSw(new NodeSw(new NodeLw(0x55AA, new NodeInt(50000)),
                            new NodeInt(32768)),
                 new NodeInt(40000)));
  Run(new NodeMul(new NodeLw(-3*5, new NodeInt(40000)),
                  new NodeLw(-4*7, new NodeInt(50000))));
  Run(new NodeSw(new NodeSw(new NodeMul(new NodeLw(1000, new NodeInt(32768)),
                                        new NodeLw(-1, new NodeInt(49152))),
                            new NodeInt(40000)),
                 new NodeInt(50000)));
  Run(new NodeSw(new NodeAdd(new NodeLbz(255, new NodeInt(32768)),
                             new NodeLbs(-1, new NodeInt(49152))),
                 new NodeInt(40000)));
  Run(new NodeSw(new NodeAdd(new NodeLbs(-1, new NodeInt(50000)),
                             new NodeLbz(255, new NodeInt(49152))),
                 new NodeInt(32768)));
  Run(new NodeSb(new NodeLbs(0x5A, new NodeInt(40000)), new NodeInt(50000)));
  Run(new NodeSb(new NodeLbs(0xFFA5, new NodeInt(32768)), new NodeInt(49152)));
  Run(new NodeSb(new NodeLbz(0xA5, new NodeInt(40000)), new NodeInt(50000)));
  Run(new NodeZext(new NodeSb(new NodeLb(0x5A, new NodeInt(40000)),
                              new NodeInt(50000))));
  Run(new NodeSext(new NodeSb(new NodeLb(0xFF, new NodeInt(40000)),
                              new NodeInt(50000))));
  Run(new NodeLw(55555,
                 new NodeAdd(new NodeLw(40000, new NodeInt(32768)),
                             new NodeShLft(new NodeLw(10, new NodeInt(50000)),
                                           new NodeInt(1)))));

  Run(new NodeAdd(new NodeShLft(new NodeLbz(10,
                                            new NodeAdd(new NodeInt(32768),
                                                        new NodeInt(0))),
                                new NodeInt(4)),
                  new NodeIDiv(new NodeInt(2), new NodeInt(1))));

  std::cout << "\n"
               "    mov  dx, msg_success\n"
               "    mov  ah, 9\n"
               "    int  0x21\n"
               "    mov  ax, 0x4C00\n"
               "    int  0x21\n";
  std::cout << "\n"
               "no_memory:\n"
               "    mov  dx, msg_memory\n"
               "    mov  ah, 9\n"
               "    int  0x21\n"
               "    mov  ax, 0x4C01\n"
               "    int  0x21\n";
  std::cout << "\n"
               "failure:\n"
               "    mov  dx, msg_failure\n"
               "    mov  ah, 9\n"
               "    int  0x21\n"
               "    mov  ax, 0x4C01\n"
               "    int  0x21\n";
  std::cout << "\n"
               "msg_success:\n"
               "    db   \"SUCCESS!\", 13, 10, \"$\"\n";
  std::cout << "\n"
               "msg_memory:\n"
               "    db   \"OUT OF MEMORY!\", 13, 10, \"$\"\n";
  std::cout << "\n"
               "msg_failure:\n"
               "    db   \"FAILURE!\", 13, 10, \"$\"\n";

  return 0;
}
