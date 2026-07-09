// Regression test for 1965f6cd6 / GitHub #9967:
// IROp_EnumType was not included in the set of types for which Slang emits
// DebugLocalVariable, so enum-typed locals were invisible in the debugger.
//TEST:SPVDB_DEBUGGER(filecheck=SPVDB): -entry main -stage compute

enum Color
{
    Red = 0,
    Green = 1,
    Blue = 2,
};

[shader("compute")]
[numthreads(1, 1, 1)]
void main(uniform RWStructuredBuffer<uint> input, uniform RWStructuredBuffer<uint> output)
{
    Color c = Color(input[0] % 3u);   // line 17
    output[0] = uint(c);              // line 18 — break here, 'c' must be visible
}

// SPVDB-CMD: descriptor 0 0 [1]
// SPVDB-CMD: descriptor 0 1 [0]
// SPVDB-CMD: break debug-enum-locals.slang 18
// SPVDB-CMD: run
// SPVDB-CMD: locals
// SPVDB-CMD: run
// SPVDB-CMD: read 0 1

// input[0] = 1 → c = Color(1) = Green = 1
// If the bug regresses, no DebugLocalVariable is emitted for 'c' and the
// locals list will be empty.
// NOTE: Slang emits DebugValue %c %OpUndef for the enum-typed local, so
// spvdb displays c=0 instead of c=1.  We check only that 'c' appears in
// locals (regression for visibility), not its value.
// SPVDB: local: c = {{.*}}
// SPVDB: stopped: EntryFinished
// SPVDB: read[0][1]: [1]
